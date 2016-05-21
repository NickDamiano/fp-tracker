class MessageActions

	def self.get_depart_info(message)
		names = parse_names(message)
		to = parse_location_to(message)
		result = { names: names, to: to }
	end

	def self.arrive(message, sender)
		if message == "arrived"
			parse_arrived_short(message, sender)
		else
			parse_arrived_long(message)
		end
	end

	def self.parse_arrived_short(message, sender)
		depart_message = Message.where(from: sender).last(2)[0]
		# returns hash with keys names and to 
		get_depart_info(depart_message["body"])

	end

	def self.parse_arrived_long(message)
		# parse by commas and arrived to get who and where. 
		# send back to message.rb to update database with arrived
		names = parse_names(message)
		
	end

	def self.updateDatabaseArrive(sender)
		transit_employees = TransitEmployee.where(sender: sender)
		transit_employees.each do | employee | 
			temp_employee = Employee.find(employee.employee_id)
			temp_employee.location = employee.destination
			temp_employee.save
		end
	end

	def self.updateDatabaseDepart(employees, destination)
		# takes names and loops through updating database with new location for each one
		# names is array of hashes of employee objects
		employees.each do | employee | 
			employee_temp = Employee.find_by(first_name: employee["first_name"], last_name: employee["last_name"])
			employee_temp.location = "driving to #{destination}"
			employee_temp.save
		end
	end

	# def self.createTransitRecord(employees, destination, sender)
	# 	employees.each do | employee | 
	# 		TransitEmployee.create(sender: sender, destination: destination, employee_id: employee["id"])
	# 	end
	# end

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
		p message 
		p "message abooveee!!!!!"
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