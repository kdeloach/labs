import simplejson as json

movies = [
# Copy lines from final-ratings.txt 
]

result = []
for item in movies:
    title = item['title']['regular']
    cover = item['box_art']['large']
    rating = item['user_rating']
    year = item['release_year']
    url = [ln for ln in item['link'] if ln['rel'] == 'alternate'][0]['href']
    result.append(dict(title=title, year=year, rating=rating, cover=cover, url=url))
print json.dumps(result, indent=4)
