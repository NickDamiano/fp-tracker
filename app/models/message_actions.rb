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
		# filter out if it says all arrived who the sender is, look at the last
		# message from the sender to see the names and mark all as being at the 
		# destination
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

	def self.add_employee(message)
	end

	def self.checkDuplicateLastName(names)
		duplicates = []
		employees = []
		names.each do | name | 
			# check for duplicates, if there are, push them into
			if Employee.where(last_name: "#{name}", in_saudi: true).count > 1
				duplicates.push(name)
			end
			# retrieve employee, convert to hash, store in array to be returned
			employee = Employee.find_by(last_name: name).as_json
			employees.push(employee)
		end
		# if there are duplicate names then see if they exceed the number of names in database
				# i.e. if there are only two johnsons in saudi, and two johnsons were put down in text
				# then no need to check which ones. If there are three johnsons then get the right ones
		if duplicates[0]
			# sort out unique names from duplicates, get number of ocurrence in duplicates array
			# call duplicate message that takes the last names, creates a text message
			# sends it back to the origin number
			unique_names = duplicates.uniq 
			unique_names.each do | name |
				number_occur = duplicates.count(name)
				# if there are more in country with last name than listed
				if number_occur > Employee.where(last_name: "#{name}", in_saudi: true).count
					# call duplicate message for last name to get which of those guys it is
				else
					# all instances of that last name in country are leaving, get all of that name and push those results to the database
					duplicate_names_to_push = Employee.where(last_name: "#{name}", in_saudi: true).as_json
					employees.push(duplicate_names_to_push)
				end
			end
		end
		# return the objects of non-duplicates
		employees
	end

	def self.send_duplicate_check_message(name)
		# take name, compose message with all first names of that last name, have them respond and if multiple
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