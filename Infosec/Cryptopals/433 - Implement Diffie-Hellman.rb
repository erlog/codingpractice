require_relative 'cryptopals'

alice = diffiehellman(DiffieHellman_p, DiffieHellman_g)
bob = diffiehellman(alice["p"], 1)

diffiehellmansessionkey(alice, bob["publickey"])
diffiehellmansessionkey(bob, alice["publickey"])

console(alice)
console(bob)

puts alice["sessionkey"].to_s(16) 
puts bob["sessionkey"].to_s(16)
testoutput(alice["sessionkey"], bob["sessionkey"])
