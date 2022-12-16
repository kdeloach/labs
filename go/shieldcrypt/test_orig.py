import base58, sys

partial = "L5EZftvrYaSudiozVRzTqLcHLNDoVn7H5HSfM9BAN6tMJ"
theansw = "L5EZftvrYaSudiozVRzTqLcHLNDoVn7H5HSfM9BAN6tMJX8oTWz6"
print(partial)

results = {}
for c in "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz":
    wif = base58.b58encode_check(
        base58.b58decode(partial + c * 7)[:33] + b"\x01"
    ).decode("ascii")
    if wif[:45] == partial:
        results[wif] = True

for k in results.keys():
    print(k)
