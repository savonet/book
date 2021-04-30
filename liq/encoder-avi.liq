#!./liquidsoap
s = single("test.avi")
output.file(%avi, "/tmp/backup.avi", s)
