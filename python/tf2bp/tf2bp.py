import httplib
import json
from collections import defaultdict

steamID = 76561197991410761

conn = httplib.HTTPConnection('api.steampowered.com')
conn.request('GET', '/IEconItems_440/GetSchema/v0001/?key=E51B282600BD48835E7E0AFCB95768C6')
r1 = conn.getresponse()
schema = json.loads(r1.read())['result']

conn = httplib.HTTPConnection('api.steampowered.com')
conn.request('GET', '/IEconItems_440/GetPlayerItems/v0001/?key=E51B282600BD48835E7E0AFCB95768C6&SteamID=%d' % steamID)
r2 = conn.getresponse()
bp = json.loads(r2.read())['result']

weapons = dict([(item['defindex'], item) for item in schema['items'] 
    if 'craft_class' in item
    and item['craft_class'] == 'weapon'])
bpWeapons = [item for item in bp['items'] if item['defindex'] in weapons]

bpWeaponCount = defaultdict(int)
for item in bpWeapons:
    bpWeaponCount[item['defindex']] += 1

items = [item for item in bpWeapons if bpWeaponCount[item['defindex']] > 1]
extras = [item for item in items
    if 'flag_cannot_trade' not in item
    and 'flag_cannot_craft' not in item
    and item['quality'] != 3 # vintage
    and item['quality'] != 11 # strange
    ]

extrasWeaponCount = defaultdict(int)
for item in extras:
    extrasWeaponCount[item['defindex']] += 1    
    
def preserveAtLeastOne(items):
    """ Always want to retain at least 1 of each type of weapon """
    for item in items:
        i = item['defindex']
        if extrasWeaponCount[i] == bpWeaponCount[i]:
            extrasWeaponCount[i] -= 1
            continue
        yield item

extras = list(preserveAtLeastOne(extras))
     
byClass = defaultdict(list)
for item in extras:
    weapon = weapons[item['defindex']]
    for className in weapon['used_by_classes']:
        byClass[className].append(weapon['name'])

for className, lst in byClass.iteritems():
    print "%s:" % className
    pairs = zip(lst[:len(lst)/2], lst[len(lst)/2:])
    for p in pairs:
        print "    %s, %s" % p
    leftover = lst[len(lst)/2*2:]
    if len(leftover) > 0:
        print "    Leftover: %s" % ', '.join(leftover)


    
