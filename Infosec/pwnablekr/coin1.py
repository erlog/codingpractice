import string
import socket
from time import sleep

def parse_input(coinsandtries):
    coins = int(coinsandtries.split()[0][2:])
    tries = int(coinsandtries.split()[1][2:])
    return (coins, tries)

def splitarray(array):
    midpoint = len(array)/2
    return (array[:midpoint], array[midpoint:])

def formatarray(array):
    return string.join(array, " ")

def containsfake(weight):
   return (weight % 10) != 0

def sendsocket(sock, data):
    print "CLIENT: " + data + "\n"
    sock.sendall(data + "\n")
    response = sock.recv(4096)
    print "SERVER: " + response
    return response

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(("localhost", 9007))
print sock.recv(4096)

foundcoins = 0

while foundcoins < 100:
    coins, tries = parse_input(sock.recv(4096))
    coingroups = splitarray(map(str, range(coins)))
    while tries > 0:
        tries = tries - 1
        weight = int(sendsocket(sock, formatarray(coingroups[0])))
        if containsfake(weight):
            coingroups = splitarray(coingroups[0])
        else:
            coingroups = splitarray(coingroups[1])

    if len(coingroups[0]) > 0:
        response = sendsocket(sock, formatarray(coingroups[0]))
    else:
        response = sendsocket(sock, formatarray(coingroups[1]))

    if response[0:8] == "Correct!":
        foundcoins += 1
    else:
        break

print sock.recv(4096)
