start = Time.now
number = 1.0
(10**8).times do
    thing = number/2.5
    number += 1.0
end
puts (Time.now - start).to_s
