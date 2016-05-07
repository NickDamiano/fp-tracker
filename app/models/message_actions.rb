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
		# message is ["bart, lisa, marge left al yamama"]
		first = message.split(',')
		# gets last name and pushes them all together. 
		# Returns ["bart, lisa, marge"]
		last = first[-1]
		last_name = last.lstrip.split(' ')[0]
		first[0...-1].each{ | name | name.strip!}.push(last_name)
	end

	def self.parse_location_from(message)
		'from location'
	end

	def self.parse_location_to(message)
		'to location'
	end
end