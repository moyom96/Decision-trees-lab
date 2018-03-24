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
				values = splitted[2..-1].join.gsub(/[{}]/, '').split(',')
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

	# print atts.inspect
	# puts ""
	# print answer
	# puts ""
	# print data_hash
	# puts ""

	total_entropy = entropy(answer, data_hash)

	split(atts, data_hash, total_entropy, answer, [], 0)	

end

def entropy(answer, data_hash)
	entropy = 0 
	answer.first[1].each do |val|
		count = data_hash.values.count val
		if count > 0
			p = count.to_f / data_hash.values.size.to_f
			entropy += -p * Math::log(p, 2)
		end
	end

	entropy
end

def info_gain(feature_values, feature_index, data_hash, total_entropy, answer)
	sum = 0
	feature_values.each do |val|
		subset = make_subset(data_hash, feature_index, val)
		sum -= (entropy(answer, subset) * subset.length/data_hash.length)
	end

	total_entropy + sum
end

def make_subset(data_hash, feature_index, val)
	subset = Hash.new
	data_hash.each do |k, v|
		if k[feature_index] == val
			subset.merge!({k => v})
		end
	end

	subset
end

def split (atts, data_hash, total_entropy, answer, splitted_indexes, depth)
	max_val = 0
	max_i = 0
	
	atts.each_with_index do |array, i|		# array[0] is the feature, array[1] is an array of the falues
		if !splitted_indexes.include? i
			new_info = info_gain(array[1], i, data_hash, total_entropy, answer)
			if new_info > max_val 
				max_val = new_info
				max_i = i
			end
		end
	end

	selected = atts.to_a[max_i]  # In 0 it holds the name of the att, and in 1 it holds its possible values
	
	selected[1].each do |val|
		puts (" " *2*depth) + selected[0] + ": " + val
		subset = make_subset(data_hash, max_i, val)
		if entropy(answer, subset) == 0
		  puts (" "*2*(depth+1)) + "ANSWER: " + subset.to_a[0][1] 
		else
			split(atts, subset, total_entropy, answer, splitted_indexes.push(max_i), depth+1)
		end
			
	end

	# splitted_indexes.push max_i
end

main