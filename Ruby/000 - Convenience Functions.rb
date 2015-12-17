def arrayinit (length, data)
	myarray = Array.new(length)
	myarray.map! {|n| n = data}
	return myarray
end