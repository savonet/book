def on_file_change(~state, fname)
  if state == "closed" then
    print("The file #{fname} was created.")
  elsif state == "removed" then
    print("The file #{fname} was removed.")
  end
end