package gobundle

import (
    "testing"
    "runtime/debug"
)

func TestMakeKey(t *testing.T) {
    assertEqual(t, "src/foo", makeKey("src", "foo"))
    assertEqual(t, "src/foo.js", makeKey("src", "foo.js"))
    assertEqual(t, "src/foo.js", makeKey("src", "./foo"))
    assertEqual(t, "src/foo.js", makeKey("src", "./foo.js"))
    assertEqual(t, "shim/bar.js", makeKey("src", "../shim/bar"))
    assertEqual(t, "shim/bar.js", makeKey("src", "../shim/bar.js"))
    assertEqual(t, "root/util/a.js", makeKey("root/lang", "../util/a"))
}

func TestLongestCommonPath(t *testing.T) {
    assertEqual(t, "", longestCommonPath())
    assertEqual(t, "src/foo", longestCommonPath("src/foo/a.js"))
    assertEqual(t, "src", longestCommonPath("src/foo/a.js", "src/bar/b.js"))
    assertEqual(t, "src", longestCommonPath("src/a.js", "src/bar/b.js"))
    assertEqual(t, "src", longestCommonPath("src/foo/a.js", "src/b.js"))
}

func assertEqual(t *testing.T, expected, actual string) {
    if expected != actual {
        t.Log("Assertion failed")
        t.Log("Expected:", expected)
        t.Log("Actual:", actual)
        debug.PrintStack()
        t.Fail()
    }
}
