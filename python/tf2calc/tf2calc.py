import json
import re
import string
from optparse import OptionParser

NUM_COLS = 7
SCRAP_VALUE = 0.11

def col_number(letter):
    return list('ABCDEFG').index(letter)
        
def load_spreadsheet():   
    def item_row(item):
        return int(item['title']['$t'].strip(string.letters))
    def item_col(item):
        return col_number(item['title']['$t'].strip(string.digits))
    def item_index(item):
        return NUM_COLS * item_row(item) + item_col(item)
    def item_content(item):
        return item['content']['$t']
    # TODO: Read directly from website; For now, use:
    # curl https://spreadsheets.google.com/feeds/cells/0AnM9vQU7XgF9dFM2cldGZlhweWFEUURQU2pmOGJVMlE/od6/public/basic?alt=json > prices.json
    data = json.loads(open('prices.json').read())
    spreadsheet = ((item_index(item), item_content(item)) for item in data['feed']['entry'])
    # Use dict instead of array because there may be skipped rows
    return dict(spreadsheet)
    
def to_rows(spreadsheet):
    def cell_value(row, col):
        try:
            return spreadsheet[NUM_COLS * row + col]
        except KeyError:
            return None
    row = 0
    while True:
        row += 1
        # Kind of lazy...
        if row >= len(spreadsheet):
            break
        A = cell_value(row, col_number('A'))
        C = cell_value(row, col_number('C'))
        D = cell_value(row, col_number('D'))
        E = cell_value(row, col_number('E'))
        if not A and not C and not D and not E:
            continue
        yield (A, C, D, E)
        
def parse_value(value):
    result = re.match("(\d+(?:\.\d+)?)(?:x)?(?: - ?(\d+(?:\.\d+)?)(?:x)?)?", value)
    if not result:
        # If no amount specified, assume at least 1
        # Example: "scrap", "bud", "refined" 
        return 1
    a, b = result.groups()
    # Take the highest value if described as a range
    return max(float(a or 0), float(b or 0))
        
def parse_unit(value):
    result = re.search("(keys?|buds?|bills?|ref|refined|wep|weapon|scrap)", value)
    unit = 'metal'
    if result:
        match, = result.groups()
        unit = match if match else unit
    return unit
        
def make_row_funcs(rows):
    def find_unit_value(unit, exact=True):
        if unit not in find_unit_value.cache:
            find_unit = find(unit, exact=exact)
            first = next(find_unit)
            _, _, value, _ = first
            find_unit_value.cache[unit] = metal_value(value)
        return find_unit_value.cache[unit]
    find_unit_value.cache = {}
    
    def metal_value(value):
        amount = parse_value(value)
        unit = parse_unit(value)
        if 'key' in unit:
            return amount * find_unit_value('key')
        if 'bud' in unit:
            return amount * find_unit_value('earbuds')
        if 'bill' in unit:
            return amount * find_unit_value("bill's hat", exact=False)
        if 'scrap' in unit:
            return amount * SCRAP_VALUE
        if 'wep' in unit or 'weap' in unit:
            # Defining weapon as half scrap, which is good enough for our purposes
            return amount * (SCRAP_VALUE / 2)
        return amount
        
    def find(query, exact=False):
        query = query.lower()
        def test(col, term):
            if exact:
                return col and term == col.lower()    
            return col and term in col.lower()
        for row in rows:
            # All search terms should match at least one column
            if all(any(test(col, term) for col in row) for term in query.split(' ')):
                yield row
    
    return find_unit_value, metal_value, find

def run_tests(rows):
    find_unit_value, metal_value, find = make_row_funcs(rows)
    
    key_metal_value = find_unit_value('key')
    bud_metal_value = find_unit_value('earbuds')
    bills_metal_value = find_unit_value("bill's hat", exact=False)
    
    assert metal_value('1 key +/-') == key_metal_value
    assert metal_value('1.33 - 2.33 keys +/-') == key_metal_value * 2.33
    assert metal_value('1x - 2.66x keys +/-') == key_metal_value * 2.66
    assert metal_value('24 keys +/-') == key_metal_value * 24
    assert metal_value('0.66 -') == 0.66
    assert metal_value('0.66 - 1') == 1
    assert metal_value('3 ref') == 3
    assert metal_value('3 refined') == 3
    assert metal_value('1 bud') == bud_metal_value
    assert metal_value('2 buds') == bud_metal_value * 2
    assert metal_value('scrap') == SCRAP_VALUE
    assert metal_value('2 scraps') == SCRAP_VALUE * 2
    assert metal_value('bills') == bills_metal_value
    assert metal_value('2x bills') == bills_metal_value * 2
    assert metal_value('wep') == SCRAP_VALUE / 2
    assert metal_value('0.25 wep') == (SCRAP_VALUE / 2) * 0.25
    assert metal_value('2 weapons') == SCRAP_VALUE
    assert metal_value(' - ') == None

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option('-e', '--exact', action='store_true', dest='exact', default=False)
    parser.add_option('-s', '--skip-tests', action='store_true', dest='skip_tests', default=False)
    opts, args = parser.parse_args()
    
    # Spreadsheet columns:
    # A - Quality
    # B - Class
    # C - Item Name
    # D - Value in refined, keys, buds, or bills
    # E - Value if non-vintage, non-strange, non-genuine, non-haunted, or dirty
    # F - Notes
    # G - Color
    
    spreadsheet = load_spreadsheet()
    rows = list(to_rows(spreadsheet))
    find_unit_value, metal_value, find = make_row_funcs(rows)
    
    if not opts.skip_tests:
        run_tests(rows)

    total = 0
    
    for query in args:            
        result = find(query, exact=opts.exact)
        try:
            first = next(result)
            quality, item_name, value, dirty_value = first
            value = metal_value(value)
            dirty_value = metal_value(dirty_value)
            print "%s %s, %s, %s (dirty)" % (quality, item_name, value, dirty_value)
            total += value
        except StopIteration:
            print "%s -- NOT FOUND" % query
    
    key_metal_value = find_unit_value('key')
    total_keys = total / key_metal_value
    
    print "Total: {0:.2f} refined ({1:.2f} keys)".format(total, total_keys)
