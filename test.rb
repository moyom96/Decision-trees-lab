# @author Moisés Montaño Copca
# Implementation with map function

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
	max_val = -10
	max_i = 0

	# Using a map function instead of a each_with_index loop
	# it works correctly, however when the information gain is the same it 
	# may give a different answer than the one expected by alphagrader
	new_atts = atts.to_a.inject(Hash.new ) {|memo, e|  memo.update(e => info_gain(e[1], atts.find_index { |k,_| k== e[0] }, data_hash, total_entropy, answer))}.sort_by{|_, v| v}.reverse
	i = 0
	while splitted_indexes.include? new_atts[i][0] do
		i += 1		
	end 
	selected = new_atts[i][0]
	
	max_i = atts.find_index { |k,_| k== selected[0] }
	selected[1].each do |val|
		puts (" " *2*depth) + selected[0] + ": " + val
		subset = make_subset(data_hash, max_i, val)
		if entropy(answer, subset) == 0
			if !subset.to_a.any?
				puts (" "*2*(depth+1)) + "ANSWER: ?" # Implemented this for the report test case
			else
				puts (" "*2*(depth+1)) + "ANSWER: " + subset.to_a[0][1] 
			end
		else
			new_splitted = splitted_indexes.clone
			split(atts, subset, total_entropy, answer, new_splitted.push(selected), depth+1)
		end
			
	end

end

main