require_relative 'cryptopals'

PlainText = "kick it, BB"
KeyBitLength = 768
MessageByteLength = KeyBitLength/8
PublicKey, PrivateKey = generateRSAKeys(KeyBitLength)

def paddingoracle(cipherinteger)
    ciphertext = cipherinteger.to_s(16)
    plainbytes = decryptRSAstring(ciphertext, PrivateKey)
    return true if ( (plainbytes[0] == 0) and (plainbytes[1] == 2) )
    return false
end

def compute_s_lowerbound(r, upperbound)
    return (TwoB + r * PublicKey[1]) / upperbound
end

def compute_s_upperbound(r, lowerbound)
    return (ThreeB + r * PublicKey[1]) / lowerbound
end

def compute_r(s, upperbound)
    return 2 * ( (upperbound * s - TwoB) / PublicKey[1] )
end

def compute_r_lowerbound(s, lowerbound)
    return (lowerbound * s - ThreeB + 1) / PublicKey[1]
end

def compute_r_upperbound(s, upperbound)
    return (upperbound * s - TwoB) / PublicKey[1]
end

def compute_interval(r, s, lowerbound, upperbound)
    newlowerbound = (TwoB + r * PublicKey[1]) / s
    newupperbound = (ThreeB - 1 + r * PublicKey[1]) / s

    lowerbound = [newlowerbound, lowerbound].max
    upperbound = [newupperbound, upperbound].min

    return [lowerbound, upperbound]
end

def compute_next_intervals(previous_intervals, s)
    #Step 3
    new_intervals = []
    previous_intervals.each do |lowerbound, upperbound|
        r_lowerbound = compute_r_lowerbound(s, lowerbound)
        r_upperbound = compute_r_upperbound(s, upperbound)
        (r_lowerbound..r_upperbound).each do |r|
            new_interval = compute_interval(r, s, lowerbound, upperbound)
            new_intervals << new_interval if new_interval[0] <= new_interval[1]
        end
    end
    return new_intervals
end

def find_s(c_zero, s_lowerbound)
    s = s_lowerbound - 1
    valid = false
    while !valid
        s += 1
        new_c = c_zero * modexp(s, PublicKey[0], PublicKey[1])
        valid = paddingoracle(new_c)
    end

    return s if s
    return nil
end

def find_s_bounded(c_zero, s_lowerbound, s_upperbound)
    s = s_lowerbound - 1
    valid = false
    while !valid and (s <= s_upperbound)
        s += 1
        new_c = c_zero * modexp(s, PublicKey[0], PublicKey[1])
        valid = paddingoracle(new_c)
    end

    return s if s <= s_upperbound
    return nil
end

#Make ciphertext and test our oracle
print "Public Key: "; puts PublicKey.to_s
paddedplainbytes = padbytearraywithPKCS1type2(PlainText.bytes, KeyBitLength/8)
paddedplaininteger = bytearraytohexstring(paddedplainbytes).to_i(16)
print "Plaintext: "; puts paddedplaininteger

CipherInteger = cryptRSAraw(paddedplaininteger, PublicKey)
valid = paddingoracle(CipherInteger)
print "Confirming Padding Oracle Works: "; testoutput(true, valid)

#START PROBLEM
TwoB = bytearraytohexstring([0,2]+Array.new(MessageByteLength-2, 0)).to_i(16)
ThreeB = bytearraytohexstring([0,3]+Array.new(MessageByteLength-2, 0)).to_i(16)

#Step 1
#As stated in the "Remarks" section of the paper, we don't need to do step 1
#   for real if we know we have proper padding already.
s_zero = 1
c_zero = CipherInteger
i = 1

#Step 2a
#We could start from zero, but starting from n/3B makes this first step shorter
s = find_s(c_zero, (PublicKey[1]/ThreeB))
intervals = [ [TwoB, ThreeB-1] ]

while true
    puts "s: #{s}"
    puts "Intervals: #{intervals.length}"
    intervals.each do |lowerbound, upperbound|
        puts "Interval length: #{upperbound - lowerbound}"
    end

    if intervals.length == 1
        lowerbound, upperbound = intervals[0]
        if (upperbound - lowerbound) < 2
            puts upperbound
            puts "Finished!"
            m = (upperbound * invmod(s_zero, PublicKey[1])) % PublicKey[1]
            messagebytes = removePKCS1type2padding(hexstringtobytearray(m.to_s(16)))
            message = bytearraytostring(messagebytes)
            print "Plaintext: "; puts message
            testoutput(message, PlainText)
            exit
        else
            #Step 2c
            r = compute_r(s, upperbound) - 1
            begin
                r += 1
                s_lowerbound = compute_s_lowerbound(r, upperbound)
                s_upperbound = compute_s_upperbound(r, lowerbound)
                s = find_s_bounded(c_zero, s_lowerbound, s_upperbound)
            end while !s
            #Step 3
            intervals = compute_next_intervals(intervals, s)
        end
    else
        #Step 2b
        s = find_s(c_zero, s + 1)
        intervals = compute_next_intervals(intervals, s)
    end
end
