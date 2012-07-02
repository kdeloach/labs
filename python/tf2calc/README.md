This tool allows you to find and compare the relative metal values of TF2 items for use in trading.

The prices are based on the standard [TF2 Spreadsheet Prices](http://tf2spreadsheet.blogspot.com/).

Example usage:

    $ python tf2calc.py "strange rocket" "strange submachine" "bill's" max earbuds
    Strange Rocket Launcher 2.55
    Strange Submachine Gun 0.66
    Unique / Ltd. Bill's Hat 25.50
    Unique / Ltd. Max's Severed Head 122.40
    Unique / Ltd. Earbuds 61.20
    Total: 212.31 refined (83.26 keys)

To use this you need to download the prices spreadsheet separately:

    curl https://spreadsheets.google.com/feeds/cells/0AnM9vQU7XgF9dFM2cldGZlhweWFEUURQU2pmOGJVMlE/od6/public/basic?alt=json > prices.json

