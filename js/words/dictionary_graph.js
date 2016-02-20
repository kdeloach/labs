var split = require('split'),
    process = require('process');

var graph = {};

function append(graph, chunk) {
    var head = chunk[0],
        tail = chunk.substr(1);
    if (head) {
        if (!graph[head]) {
            graph[head] = {};
        }
        if (tail) {
            append(graph[head], tail);
        } else {
            graph[head].word = true;
        }
    }
}

function handle(line) {
    if (line) {
        append(graph, line.trim());
    }
}

function dump() {
    console.log(JSON.stringify(graph));
}

process.stdin
    .pipe(split())
    .on('data', handle)
    .on('end', dump);
