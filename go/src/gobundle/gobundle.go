package gobundle

import (
    "bufio"
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

type ModRefBundle struct {
    AllRefs []*ModRef
    EntryIds []int
}

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

var RequireStmt = regexp.MustCompile(`(?i)` + // Set case-insensitive flag
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

func Bundle(entryFiles []string) *ModRefBundle {
    //var allRefs []*ModRef
    entryIds := make([]int, 0)
    queue := make([]*ModRef, 0)

    cache := make(ModRefCache)

    rootPath := longestCommonPath(entryFiles...)
    log.Println("rootPath", rootPath)

    for _, path := range entryFiles {
        ref := cache.getModuleRef(rootPath, path)
        log.Println(ref)
        queue = append(queue, ref)
        entryIds = append(entryIds, ref.ID)
    }

    for len(queue) > 0 {
        ref := queue[0]
        queue = queue[1:]
        files := scanModule(ref)
        for _, path := range files {
            child := cache.getModuleRef(rootPath, path)
            log.Println(child)
            queue = append(queue, child)
        }
    }

    return &ModRefBundle{}
}

func scanModule(ref *ModRef) []string {
    result := make([]string, 0)

    fp, err := os.Open(ref.Path)
    if err != nil {
        log.Println("Unable to open module", ref.Path)
        return result
    }
    defer fp.Close()

    scanner := bufio.NewScanner(bufio.NewReader(fp))
    scanner.Split(bufio.ScanLines)

    for scanner.Scan() {
        matches := RequireStmt.FindAllStringSubmatch(scanner.Text(), -1)
        for _, match := range matches {
            result = append(result, match[1:]...)
        }
    }

    return result
}

func (cache ModRefCache) getModuleRef(rootPath, path string) *ModRef {
    baseDir := filepath.Dir(path)
    moduleName := filepath.Base(path)
    key := makeKey(baseDir, moduleName)
    ref, ok := cache[key]
    if ok {
        return ref
    }
    cache[key] = getModuleRef(rootPath, path)
    return cache[key]
}

func getModuleRef(rootPath, refPath string) *ModRef {
    baseDir := filepath.Dir(refPath)
    moduleName := filepath.Base(refPath)

    path := pathJoin(baseDir, moduleName + ".js")
    if ref := getLocalModuleRef(rootPath, path); ref != nil {
        return ref
    }

    path = pathJoin(baseDir, moduleName)
    if ref := getLocalModuleRef(rootPath, path); ref != nil {
        return ref
    }

    if pkg := getNpmPackage(path); pkg != nil {
        if ref := getNpmModuleRef(pkg); ref != nil {
            return ref
        }
    }

    panic("Module not found: " + refPath)
}

func getLocalModuleRef(rootPath, path string) *ModRef {
    if _, err := os.Stat(path); os.IsNotExist(err) {
        return nil
    }

    moduleName, err := filepath.Rel(rootPath, path)
    if err != nil {
        log.Fatal(err)
        return nil
    }

    moduleName = "./" + filepath.ToSlash(moduleName)

    return &ModRef{
        ID: newId(),
        Name: moduleName,
        Path: path,
        Version: "<NA>",
    }
}

func getNpmPackage(path string) *NpmPackage {
    baseDir := filepath.Dir(path)
    moduleName := filepath.Base(path)

    pkgPath := pathJoin(baseDir, "node_modules", moduleName, "package.json")

    if _, err := os.Stat(pkgPath); os.IsNotExist(err) {
        return nil
    }

    data, err := ioutil.ReadFile(pkgPath)
    if err != nil {
        return nil
    }

    var pkg NpmPackage
    if err := json.Unmarshal(data, &pkg); err != nil {
        log.Fatal(err)
        return nil
    }

    // TODO: pkg.Path = Join(path, pkg.Main)

    return &pkg
}

func getNpmModuleRef(pkg *NpmPackage) *ModRef {
    log.Println("NPM Package:", pkg)
    return &ModRef{
        ID: newId(),
        Name: pkg.Name,
        Path: "npm path", // pkg.Path // pkg.Main
        Version: pkg.Version,
    }
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
           strings.HasPrefix(moduleName, "../")
}

func hasExtension(moduleName string) bool {
    return strings.HasSuffix(moduleName, ".js")
}

func makeKey(baseDir, moduleName string) string {
    name := moduleName
    if isLocalModule(moduleName) && !hasExtension(moduleName) {
        name = name + ".js"
    }
    return pathJoin(baseDir, name)
}

func pathJoin(path ...string) string {
    return filepath.ToSlash(filepath.Join(path...))
}

func pathSplit(path string) []string {
    return strings.Split(path, string(os.PathSeparator))
}

func longestCommonPath(paths...string) string {
    if len(paths) == 0 {
        return ""
    }

    result := make([]string, 0)
    parts := pathSplit(filepath.Dir(paths[0]))

loop:
    for i, part := range parts {
        // Append part to result if that part value and location
        // is the same in all given paths.
        for _, path := range paths[1:] {
            otherParts := pathSplit(filepath.Dir(path))
            if i >= len(otherParts) {
                break loop
            }
            if parts[i] != otherParts[i] {
                break loop
            }
        }
        result = append(result, part)
    }

    return filepath.ToSlash(filepath.Join(result...))
}

func WriteDependencyGraph(f *os.File, bundle *ModRefBundle) {
    // TODO: Remove (for debugging only)
    for _, ref := range bundle.AllRefs {
        log.Printf("%v. %s (%s)\n", ref.ID, ref.Name, ref.Version)
    }

    for _, id := range bundle.EntryIds {
        ref := bundle.AllRefs[id]
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

func WriteBundle(f *os.File, bundle *ModRefBundle) {
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

    for i, ref := range bundle.AllRefs {
        ref.WriteTo(f)
        if i < len(bundle.AllRefs) - 1 {
            f.WriteString(",\n")
        }
    }

    f.WriteString("}, [")

    for i, entryId := range bundle.EntryIds {
        f.WriteString(strconv.Itoa(entryId))
        if i < len(bundle.EntryIds) - 1 {
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
