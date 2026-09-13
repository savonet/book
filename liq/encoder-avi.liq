#!./liquidsoap
s = single("test.avi")
# header
output.file(%avi, "/tmp/backup.avi", s)
