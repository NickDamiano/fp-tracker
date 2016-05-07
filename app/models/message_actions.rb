class MessageActions
	# parses out names, location from, and to (if included in message)
	# returns hash {names: names, from: from, to: to }
	def self.depart(message)
		puts 'depart was totally called broski'
		names = parse_names(message)
		from = parse_location_from(message)
		to = parse_location_to(message)
		result = { names: names, from: from, to: to }
	end

	def self.arrive(message)
		puts "is this thing working? damn"
	end

	def self.emergency
	end

	def self.sitrep
	end

	def self.parse_names(message)
		['nick', 'fred', 'bart']
	end

	def self.parse_location_from(message)
		'al yamama'
	end

	def self.parse_location_to(message)
		'psab'
	end
end