#!./liquidsoap
n = list.length(file.ls(recursive=true, "~/Music"))
print("We have #{n} files in the library.")
