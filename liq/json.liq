#!./liquidsoap
j = json()
j.add("title", "my song")
j.add("artist", "myself")
print(json.stringify(j))