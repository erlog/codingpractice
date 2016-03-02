from subprocess import *
import string
import sys
import os
import socket
from time import sleep
from random import randint

port = randint(49153, 65534)
args = map(str, range(0, 100))
args[65] = "" #stage 1
args[66] = "\x20\x0a\x0d" #stage 1
args[67] = str(port) #port for last stage

#stage 2
f = open("stdin.txt", "w")
f.write("\x00\x0a\x00\xff\x00\x0a\x02\xff")
f.close()
stdinfile = open("stdin.txt", "rb")

#stage 3
os.putenv("\xde\xad\xbe\xef", "\xca\xfe\xba\xbe")

#stage 4
f = open("\x0a", "w")
f.write("\x00\x00\x00\x00\x00")
f.close()

proc = Popen(args, executable="./input", stdin=stdinfile, stdout=sys.stdout, stderr=stdinfile)
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#perform stage 5
sleep(1)
sock.connect(("127.0.0.1", port))
sock.send("\xde\xad\xbe\xef")
sock.close()
proc.wait()
