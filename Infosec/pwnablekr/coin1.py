import string
import socket
from time import sleep

def parse_input(coinsandtries):
    coins = int(coinsandtries.split()[0][2:])
    tries = int(coinsandtries.split()[1][2:])
    return (coins, tries)

def splitcoins(coinrange):
    midpoint = coinrange[0] + ( (coinrange[1] - coinrange[0]) / 2)
    first = string.join(map(str, range(coinrange[0], midpoint)), " ")
    second = string.join(map(str, range(midpoint, coinrange[1])), " ")
    return [first, second]

def containsfake(weight):
   return (weight % 10) != 0

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
sock.connect(("pwnable.kr", 9007))
print sock.recv(4096)
coins, tries = parse_input(sock.recv(4096))
print coins, tries
coingroups = splitcoins([0, coins])
while tries > 0:
    tries = tries - 1
    group = coingroups.pop()
    sock.sendall(group + "\n")
    weight = int(sock.recv(4096))
    print group
    print weight
    if containsfake(weight):
        coinstart = int(group.split()[0])
        coinend = int(group.split()[-1])
        coingroups = splitcoins([coinstart, coinend])

print coingroups
print sock.recv(4096)
