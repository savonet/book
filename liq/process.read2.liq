#!./liquidsoap
# header
n = list.length(file.ls(recursive=true, "~/Music"))
# footer
print("We have #{n} files in the library.")
