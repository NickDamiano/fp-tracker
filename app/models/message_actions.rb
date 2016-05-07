class MessageActions
	# parses out names, location from, and to (if included in message)
	# returns hash {names: names, from: from, to: to }
	def self.depart(message)
		puts 'depart was totally called broski'
		names = parse_names(message)
		to = parse_location_to(message)
		result = { names: names, to: to }
	end

	def self.arrive(message)
		puts "arrival message_actions called"
	end

	def self.parse_location_to(message)
		# if the message contains the word to 
		if message =~ /\sto\s/
			return message.split('to')[-1].strip!
		end
	end

	def self.emergency(message, sender)
	end

	def self.sitrep(sender)
	end

	def self.history(message, sender)
	end

	def self.parse_names(message)
		# message is ["bart, lisa, marge left al yamama to psab"]
		# remove "and"
		message = message.gsub!(/and/, '')
		first = message.split(',')
		# gets last name and pushes them all together. 
		# Returns ["bart, lisa, marge"]
		last = first[-1]
		last_name = last.lstrip.split(' ')[0]
		first[0...-1].each{ | name | name.strip!}.push(last_name)
	end

	def self.forward_unparsed(message, sender)
		# build and send message with TwiML back to sender
	end

	
end