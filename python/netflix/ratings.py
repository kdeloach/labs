from netflix import Netflix
from ConfigParser import ConfigParser
from oauth.oauth import OAuthToken
import pprint as pp
import sys

config = ConfigParser()
config.read('config.ini')

NETFLIX_API_KEY = config.get('netflix', 'NETFLIX_API_KEY')
NETFLIX_API_SECRET = config.get('netflix', 'NETFLIX_API_SECRET')
NETFLIX_APPLICATION_NAME = config.get('netflix', 'NETFLIX_APPLICATION_NAME')

flix = Netflix(key=NETFLIX_API_KEY, secret=NETFLIX_API_SECRET, application_name=NETFLIX_APPLICATION_NAME)

# 1. Copy oauth_token from callback URL after logging in with auth_url
#auth_url, auth_token = flix.get_authorization_url(callback='http://google.com/')
#print auth_url
#print auth_token
#exit()

# 2. Pass in auth tokens to receive user id for next step; Update string with real token values
#oauth_token = OAuthToken.from_string('oauth_token_secret=&oauth_token=&oauth_verifier=')
#id, token = flix.authorize(oauth_token)
#print id
#print token
#exit()

# 3. Set userid to id from last step; Update string with real token values
userid = None
token = OAuthToken.from_string('oauth_token_secret=&oauth_token=')

# Example of an authorized request
#result = flix.request('/users/%s' % userid, token=token)
#pp.pprint(vars(result))

# 4. Use to retrieve full catalog of netflix titles...This should fail (see commands-used.txt)
#result = flix.request('/catalog/titles/full')
#print result
#exit()

# Print filename for monitoring progress
print sys.argv[1]

with open(sys.argv[1]) as fd:
    title_refs = ','.join([line.strip() for line in fd.readlines()])
    result = flix.request('/users/%s/ratings/title' % userid, token=token, title_refs=title_refs, http_method='POST')
    items = result['ratings']['ratings_item'] 
    items = items if type(items) is list else [items]
    for item in items:
        if not item:
            continue
        if 'user_rating' not in item:
            continue
        print item

