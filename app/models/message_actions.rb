# class MessageActions
# 	# parses out names, location from, and to (if included in message)
# 	# returns hash {names: names, from: from, to: to }
# 	def self.depart
# 		puts 'depart was totally called broski'
# 		names = parse_names(message)
# 		from = parse_location_from(message)
# 		to = parse_location_to(message)
# 		result = { names: names, from: from, to: to }
# 		p "result izzzz #{result}"
# 	end

# 	def self.arrive(message)
# 		puts "is this thing working? damn man."
# 	end

# 	def self.emergency
# 	end

# 	def self.sitrep
# 	end

# 	def parse_names(message)
# 		['nick', 'fred', 'bart']
# 	end

# 	def parse_location_from(message)
# 		'al yamama'
# 	end

# 	def parse_location_to(message)
# 		'psab'
# 	end
# end