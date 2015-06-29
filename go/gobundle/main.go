package main

import (
    "bufio"
    "docopt"
    "encoding/json"
    "fmt"
    "io/ioutil"
    "log"
    "os"
    "path/filepath"
    "regexp"
    "strconv"
    "strings"
)

const Version = "0.1"
const Usage = `
Usage:
  main <entry_file>... [-o <file>|--output=<file>] [--tree]
  main (-h | --help)
  main --version

Options:
  <entry_file>                Entry file.
  -o <file> --output=<file>   Output file.
  --tree                      Display dependency graph.
  -h --help                   Show this screen.
  --version                   Show version.`

// Module Reference
type ModRef struct {
    ID int
    Name string
    Path string
    Version string
    //Deps []*ModRefDep
    Deps []int
}

type ModRefDep struct {
    ID int
    Version string
}

// Npm package JSON
type NpmPackage struct {
    Name string
    Main string
    Version string
    //Dependencies []string
}

var RequireStmt = regexp.MustCompile(`` +
        `(?i)` +        // Set case-insensitive flag
        `require\(` +
        `(?:"|')` +     // Single or double quote non-capture group
        `([a-z0-9\./\\-]+)` +
        `(?:"|')` +     // Single or double quote non-capture group
        `\)`)

// Global variables.
var id int = 0
var allRefs []*ModRef
var entryIds []int

func main() {
    args, _ := docopt.Parse(Usage, nil, true, Version, false)
    log.Println(args)

    entryFiles := args["<entry_file>"].([]string)
    tree := args["--tree"].(bool)

    outputFile, ok := args["--output"].(string)
    if !ok {
        outputFile = ""
    }

    writer := os.Stdout
    if len(outputFile) > 0 {
        fp, err := os.Create(outputFile)
        if err != nil {
            log.Fatalln(err)
        }
        defer fp.Close()
        writer = fp
    }

    for _, entryFile := range entryFiles {
        baseDir := filepath.Dir(entryFile)
        fileName := filepath.Base(entryFile)
        ref, err := getLocalModuleRef(baseDir, fileName)
        if err != nil {
            log.Fatalln(err)
            continue
        }
        err = scanModule(ref)
        if err != nil {
            log.Println(err)
            continue
        }
        entryIds = append(entryIds, ref.ID)
    }

    if (tree) {
        writeDependencyGraph(writer)
    } else {
        writeBundle(writer)
    }
}

func loadPackage(fileName string) (NpmPackage, error) {
    var pkg NpmPackage
    data, err := ioutil.ReadFile(fileName)
    if err != nil {
        return pkg, err
    }
    err2 := json.Unmarshal(data, &pkg)
    if err2 != nil {
        return pkg, err2
    }
    return pkg, nil
}

func scanModule(ref *ModRef) error {
    fp, err := os.Open(ref.Path)
    if err != nil {
        return err
    }
    defer fp.Close()

    baseDir := filepath.Dir(ref.Path)

    addGlobalModRef(ref)

    scanner := bufio.NewScanner(bufio.NewReader(fp))
    scanner.Split(bufio.ScanLines)

    for scanner.Scan() {
        matches := RequireStmt.FindAllStringSubmatch(scanner.Text(), -1)
        for _, match := range matches {
            // Skip first match (entire unmatched line).
            for _, moduleName := range match[1:] {
                childRef, err := getModuleRef(baseDir, moduleName)
                if err != nil {
                    log.Println(err)
                    continue
                }
                err = scanModule(childRef)
                if err != nil {
                    log.Println(err)
                    continue
                }
                ref.Deps = append(ref.Deps, childRef.ID)
            }
        }
    }

    return scanner.Err()
}

func getModuleRef(baseDir, moduleName string) (*ModRef, error) {
    if isLocalModule(moduleName) {
        return getLocalModuleRef(baseDir, moduleName)
    } else {
        return getNpmModuleRef(baseDir, moduleName)
    }
}

func getLocalModuleRef(baseDir, moduleName string) (*ModRef, error) {
    fileName := getLocalModuleFileName(moduleName)
    var ref = ModRef{}
    ref.ID = id
    ref.Name = moduleName
    ref.Path = filepath.Join(baseDir, fileName)
    ref.Version = "0"
    id++
    return &ref, nil
}

func getNpmModuleRef(baseDir, moduleName string) (*ModRef, error) {
    var ref = ModRef{}
    modulePath := filepath.Join(baseDir, "node_modules", moduleName)
    packagePath := filepath.Join(modulePath, "package.json")
    pkg, err := loadPackage(packagePath)
    if err != nil {
        return &ref, err
    }
    ref.ID = id
    ref.Name = moduleName
    ref.Path = filepath.Join(modulePath, pkg.Main)
    ref.Version = pkg.Version
    id++
    return &ref, nil
}

func getLocalModuleFileName(moduleName string) string {
    if !strings.HasSuffix(moduleName, "js") {
        return moduleName + ".js"
    } else {
        return moduleName
    }
}

func isLocalModule(moduleName string) bool {
    return strings.HasPrefix(moduleName, "./") ||
           strings.HasPrefix(moduleName, "../") ||
           strings.HasSuffix(moduleName, ".js")
}

// TODO: Do something smarter here.
func addGlobalModRef(ref *ModRef) {
    allRefs = append(allRefs, ref)
}

func writeDependencyGraph(f *os.File) {
    // TODO: Remove (for debugging only)
    for _, ref := range allRefs {
        log.Printf("%v. %s (%s)\n", ref.ID, ref.Name, ref.Version)
    }

    for _, id := range entryIds {
        ref := allRefs[id]
        ref.WriteDependencyGraphIndented(f, 1)
    }
}

func (ref *ModRef) WriteDependencyGraphIndented(f *os.File, indent int) {
    writeIndentation(f, indent)

    if ref.Version != "0" {
        f.WriteString(fmt.Sprintf("%s (%v)\n", ref.Name, ref.Version))
    } else {
        f.WriteString(fmt.Sprintf("%s\n", ref.Name))
    }

    for _, id := range ref.Deps {
        dep := allRefs[id]
        dep.WriteDependencyGraphIndented(f, indent + 1)
    }
}

func writeIndentation(f *os.File, indent int) {
    for i := 0; i < indent - 1; i++ {
        f.WriteString("|  ")
    }
    if indent > 0 {
        f.WriteString("|--")
    }
}

func writeBundle(f *os.File) {
    f.WriteString("(function(deps, ids) {\n")
    f.WriteString("    var cache = {};\n")
    f.WriteString("    function make_require(lookup) {\n")
    f.WriteString("        return function require(name) {\n")
    f.WriteString("            if (!lookup[name]) {\n")
    f.WriteString("                throw 'Module not found: ' + name;\n")
    f.WriteString("            }\n")
    f.WriteString("            return run(lookup[name]);\n")
    f.WriteString("        };\n")
    f.WriteString("    }\n")
    f.WriteString("    function run(id) {\n")
    f.WriteString("        if (cache[id]) {\n")
    f.WriteString("            return cache[id];\n")
    f.WriteString("        }\n")
    f.WriteString("        var module = {exports: {}},\n")
    f.WriteString("            pair = deps[id];\n")
    f.WriteString("        pair[0](make_require(pair[1]), module, module.exports);\n")
    f.WriteString("        cache[id] = module.exports;\n")
    f.WriteString("        return cache[id];\n")
    f.WriteString("    }\n")
    f.WriteString("    for (var i = 0; i < ids.length; i++) {\n")
    f.WriteString("        run(i);\n")
    f.WriteString("    }\n")
    f.WriteString("}({\n")

    for i, ref := range allRefs {
        ref.WriteTo(f)
        if i < len(allRefs) - 1 {
            f.WriteString(",\n")
        }
    }

    f.WriteString("}, [")

    for i, entryId := range entryIds {
        f.WriteString(strconv.Itoa(entryId))
        if i < len(entryIds) - 1 {
            f.WriteString(",")
        }
    }

    f.WriteString("]));\n")
}

func (ref *ModRef) WriteTo(f *os.File) {
    f.WriteString(strconv.Itoa(ref.ID))
    f.WriteString(": [function(require, module, exports) {\n")
    ref.WriteContentsTo(f)
    f.WriteString("}, ")
    ref.WriteDepsTo(f)
    f.WriteString("]")
}

func (ref *ModRef) WriteDepsTo(f *os.File) {
    f.WriteString("{")
    for i, id := range ref.Deps {
        dep := allRefs[id]
        f.WriteString(fmt.Sprintf("'%s': %v", dep.Name, dep.ID))
        if i < len(ref.Deps) - 1 {
            f.WriteString(", ")
        }
    }
    f.WriteString("}")
}

func (ref *ModRef) WriteContentsTo(f *os.File) {
    fp, err := os.Open(ref.Path)
    if err != nil {
        log.Println(err)
        return
    }
    defer fp.Close()
    r := bufio.NewReader(fp)
    r.WriteTo(f)
}
