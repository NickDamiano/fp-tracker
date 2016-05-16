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
		# sometimes people forget to text a departure. should handle both "all arrived" follow-up
			# as well as damiano, smith, blah, arrived at al yamama
		# if it starts with arrived - look at who sent it, find last message from them, parse out names and location from 
		# the departed message and update database with them being located there. (or if an acknowledging text is sent, parse
			# the last text sent to that number and update database)
				# call parse_arrived_short
		# if it doesn't start with arrive, then it should be a list of names (nick, bart, butt arrived at al yamama) - strip
		# off any punctuation marks at the end. also strip out preopositions following arrived like on/at/in. 
			# call parse_arrived_long
	end

	def self.parse_arrived_short(message)
		# look at message history for sending number for most recent containing the word depart
		# parse that message again through the parser and return a result. result will be updated in db
	end

	def self.parse_arrived_long(message)
		# parse by commas and arrived to get who and where. 
		# send back to message.rb to update database with arrived
	end

	def self.updateDatabase(employees, destination)
		# takes names and loops through updating database with new location for each one
		# names is array of hashes of employee objects
		employees.each do | employee | 
			employee_temp = Employee.find_by(first_name: employee["first_name"], last_name: employee["last_name"])
			employee_temp.location = "driving to #{destination}"
			employee_temp.save
		end
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
			
			puts "name is #{name}"
			puts "count is "
			puts Employee.where(last_name: "#{name}", in_saudi: true).count
			puts "end of count"
			if Employee.where(last_name: "#{name}", in_saudi: true).count > 1
				puts "There are duplicates!"
				duplicates.push(name)
			else
				# If the name is unique to people in saudi, retrieve employee, convert to hash, and 
					# store in array to be returned
				employee = Employee.find_by(last_name: name).as_json
				employees.push(employee)
			end
		end
		# if there are duplicate names then see if they exceed the number of names in database
				# i.e. if there are only two johnsons in saudi, and two johnsons were put down in text
				# then no need to check which ones. If there are three johnsons then get the right ones
		puts "Duplicatessssss are #{duplicates}"
		puts "Names should not include butt. Here are employee names: #{employees}"
		if duplicates[0]
			# sort out unique names from duplicates, get number of ocurrence in duplicates array
			# call duplicate message that takes the last names, creates a text message
			# sends it back to the origin number
			unique_names = duplicates.uniq 
			unique_names.each do | name |
				number_occur_text = duplicates.count(name)
				puts "number_occur is #{number_occur_text}!!!!!!!!!!!!!!!!!!!!!!"
				# if there are more in country with last name than listed
				if number_occur_text < Employee.where(last_name: "#{name}", in_saudi: true).count
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