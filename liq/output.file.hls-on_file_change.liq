def on_file_change(~state, fname)
  if state == "created" then
    print("The file #{fname} was created.")
  elsif state == "deleted" then
    print("The file #{fname} was deleted.")
  end
end
