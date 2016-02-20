var words = require('./dictionary.json');
var letters = 'abcdefghijklmnopqrstuvwxyz'.split('');

function is_word(graph, word) {
    var head = word[0],
        tail = word.substr(1);
    if (!graph) {
        return false;
    }
    if (!head) {
        return graph.word;
    }
    return is_word(graph[head], tail);
}

function combs(word) {
    var result = [];
    if (word.length <= 1) {
        return explodeChar(word);
    }
    for (var i = 0; i < word.length; i++) {
        var prefixes = explodeChar(word[i]),
            rest = word.substr(0, i) + word.substr(i + 1, word.length),
            suffixes = combs(rest);
        result = result.concat(suffixes);
        for (var p = 0; p < prefixes.length; p++) {
            for (var s = 0; s < suffixes.length; s++) {
                result.push(prefixes[p] + suffixes[s]);
            }
        }
    }
    return uniq(result);
}

function explodeChar(c) {
    return c === '_' ? letters : [c];
}

function uniq(arr) {
    var obj = {};
    for (var i = 0; i < arr.length; i++) {
        obj[arr[i]] = 1;
    }
    var result = [];
    for (var k in obj) {
        result.push(k);
    }
    return result;
}

function valid_words(word) {
    var result = [],
        candidates = combs(word);
    for (var i = 0; i < candidates.length; i++) {
        var cand = candidates[i];
        if (cand.length < 2) continue;
        if (is_word(words, cand)) {
            result.push(cand);
        }
    }
    result.sort(function(a, b) {
        if (a.length === b.length) {
            return a.localeCompare(b);
        }
        return b.length - a.length;
    });
    return result;
}

var query = 'c_t';
console.log('Valid words using the letters ', query.split(''), ' are...');
console.log(valid_words(query));
