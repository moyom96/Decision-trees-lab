# @author Moisés Montaño Copca

def main
	atts = Hash.new
	data_hash = Hash.new
	answer = nil
	reading_data = false

	# Reading the input
	loop do
		line = $stdin.readline.chomp
		splitted = line.split ' '

		if splitted[0] != '%' and !splitted[0].nil?		# If it's not a comment

			if splitted[0].casecmp("@attribute") == 0
				prev = answer
				values = splitted[2..-1].join.gsub('{', '').gsub('}', '').split(',')
				answer = {splitted[1] => values}
				atts.merge!(prev) if !prev.nil?

			elsif splitted[0].casecmp("@data") == 0
				reading_data = true

			elsif reading_data
				data = splitted[0].split ','
				data_hash.merge!({data[0..-2] => data[-1]})

			end
									
		end
		break if $stdin.eof?
	end

	print atts.inspect
	puts ""
	print answer
	puts ""
	print data_hash
	puts ""

	total_entropy = 0 
	answer.first[1].each do |val|
		count = data_hash.values.count val
		p = count.to_f / data_hash.values.size.to_f
		total_entropy += -p * Math::log(p, 2)
	end

	print total_entropy

end

main