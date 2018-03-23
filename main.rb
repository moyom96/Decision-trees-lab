# @author Moisés Montaño Copca

def main
	atts = Hash.new
	data_hash = Hash.new
	answer = nil
	reading_data = false
	line = $stdin.readline.chomp

	loop do
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
		line = $stdin.readline.chomp
		break if $stdin.eof?
	end

	print atts.inspect
	puts ""
	print answer
	puts ""
	print data_hash
end

main