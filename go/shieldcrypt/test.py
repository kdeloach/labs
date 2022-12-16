#!/usr/bin/env python3

import base58, sys

partial = "L5EZftvrYaSudiozVRzTqLcHLNDoVn7H5HSfM9BAN6tMJ"
theansw = "L5EZftvrYaSudiozVRzTqLcHLNDoVn7H5HSfM9BAN6tMJX8oTWz6"
partial_bytes = base58.b58decode(partial + "z" * 7)[:33]
partial_hex = partial_bytes.hex()
print(partial)
print(len(partial_bytes), partial_hex)


results = {}
# for c in "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz":
for i in range(58):

    b = i.to_bytes(1, "big")
    wif_bytes = partial_bytes + b
    wif = base58.b58encode_check(wif_bytes)
    print(len(wif_bytes), [int(x) for x in wif_bytes])

    c = base58.b58encode(b).decode("ascii")
    wif_bytes = base58.b58decode(partial + c * 7)[:33]
    wif = base58.b58encode_check(wif_bytes + b"\x01")
    print(len(wif_bytes), [int(x) for x in wif_bytes + b"\x01"])

    # wif = base58.b58encode_check(
    #     base58.b58decode(partial + c + * 7)[:33] + b"\x01"
    # ).decode("ascii")
    if wif.decode("ascii")[:45] == partial:
        results[wif] = True

for k in results.keys():
    print(k)
