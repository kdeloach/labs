package main

import (
    "bufio"
    "docopt"
    "encoding/json"
    //"errors"
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
    Deps []*ModRef
    //Deps []int
}

type ModRefCache map[string]*ModRef

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

var newId = func() func() int {
    i := 0
    return func() int {
        defer func() { i++ }()
        return i
    }
}()

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

    var allRefs []*ModRef
    var entryIds []int
    var cache = make(ModRefCache)

    for _, entryFile := range entryFiles {
        baseDir := filepath.Dir(entryFile)
        fileName := filepath.Base(entryFile)
        ref := cache.getModuleRef(baseDir, fileName)
        fmt.Println(ref)
        continue
        /*
        err = scanModule(ref)
        if err != nil {
            log.Println(err)
            continue
        }
        entryIds = append(entryIds, ref.ID)
        */
    }
    return

    if (tree) {
        writeDependencyGraph(writer, allRefs, entryIds)
    } else {
        writeBundle(writer, allRefs, entryIds)
    }
}

func loadPackage(fileName string) (NpmPackage, error) {
    var pkg NpmPackage
    data, err := ioutil.ReadFile(fileName)
    if err != nil {
        return pkg, err
    }
    err = json.Unmarshal(data, &pkg)
    if err != nil {
        return pkg, err
    }
    return pkg, nil
}

/*
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
*/

func (cache ModRefCache) getModuleRef(baseDir, moduleName string) *ModRef {
    resolvedModuleName := resolveName(baseDir, moduleName)
    key := makeKey(baseDir, resolvedModuleName)
    ref, ok := cache[key]
    if ok {
        return ref
    }
    cache[key] = getModuleRef(baseDir, resolvedModuleName)
    return cache[key]
}

func getModuleRef(baseDir, moduleName string) *ModRef {
    // 1. Try exact match in baseDir
    // 2. Try with .js suffix in baseDir
    // 3. Try exact match in baseDir + node_modules
    // 4. Try with .js suffix in baseDir + node_modules
    if ref := getLocalModuleRef(baseDir, moduleName); ref != nil {
        return ref
    }
    if ref := getLocalModuleRef(baseDir, moduleName + ".js"); ref != nil {
        return ref
    }
    if ref := getNpmModuleRef(baseDir, moduleName); ref != nil {
        return ref
    }
    panic("Module not found")
}

func getLocalModuleRef(baseDir, moduleName string) *ModRef {
    log.Println(baseDir, moduleName)
    fileName := getLocalModuleFileName(moduleName)
    var ref = ModRef{}
    ref.ID = newId()
    ref.Name = moduleName
    ref.Path = filepath.Join(baseDir, fileName)
    ref.Version = "0"
    return &ref
}

func getNpmModuleRef(baseDir, moduleName string) *ModRef {
    var ref = ModRef{}
    modulePath := filepath.Join(baseDir, "node_modules", moduleName)
    packagePath := filepath.Join(modulePath, "package.json")
    pkg, err := loadPackage(packagePath)
    if err != nil {
        log.Println(err)
        return &ref
    }
    ref.ID = newId()
    ref.Name = moduleName
    ref.Path = filepath.Join(modulePath, pkg.Main)
    ref.Version = pkg.Version
    return &ref
}

func getLocalModuleFileName(moduleName string) string {
    if !strings.HasSuffix(moduleName, "js") {
        return moduleName + ".js"
    } else {
        return moduleName
    }
}

func resolveName(baseDir, moduleName string) string {
    if isLocalModule(moduleName) {
        if !strings.HasSuffix(moduleName, ".js") {
            return moduleName + ".js"
        }
    }
    return moduleName
}

func isLocalModule(moduleName string) bool {
    return strings.HasPrefix(moduleName, "./") ||
           strings.HasPrefix(moduleName, "../") ||
           strings.HasSuffix(moduleName, ".js")
}

func makeKey(baseDir, moduleName string) string {
    result, err := filepath.Rel(baseDir, moduleName)
    if err != nil {
        panic("Unable to make key")
    }
    return result
}

func writeDependencyGraph(f *os.File, allRefs []*ModRef, entryIds []int) {
    // TODO: Remove (for debugging only)
    for _, ref := range allRefs {
        log.Printf("%v. %s (%s)\n", ref.ID, ref.Name, ref.Version)
    }

    for _, id := range entryIds {
        ref := allRefs[id]
        ref.writeDependencyGraphIndented(f, 1)
    }
}

func (ref *ModRef) writeDependencyGraphIndented(f *os.File, indent int) {
    writeIndentation(f, indent)

    if ref.Version != "0" {
        f.WriteString(fmt.Sprintf("%s (%v)\n", ref.Name, ref.Version))
    } else {
        f.WriteString(fmt.Sprintf("%s\n", ref.Name))
    }

    for _, dep := range ref.Deps {
        dep.writeDependencyGraphIndented(f, indent + 1)
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

func writeBundle(f *os.File, allRefs []*ModRef, entryIds []int) {
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

func (ref *ModRef) Key() string {
    return fmt.Sprintf("<%s %s>", ref.Name, ref.Version)
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
    for i, dep := range ref.Deps {
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
