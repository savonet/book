#!./liquidsoap
db = sqlite("/tmp/radio.db")
db.table.create(
  "played", preserve=true, [("title", "STRING"), ("at", "INTEGER")]
)
db.insert(table="played", {title = "Sing", at = 1234})
print("#{db.count(table="played")} songs played so far")
