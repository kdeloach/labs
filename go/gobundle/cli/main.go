package main

import (
    "docopt"
    "gobundle"
    "log"
    "os"
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

    bundle := gobundle.Bundle(entryFiles)

    if (tree) {
        gobundle.WriteDependencyGraph(writer, bundle)
    } else {
        gobundle.WriteBundle(writer, bundle)
    }
}
