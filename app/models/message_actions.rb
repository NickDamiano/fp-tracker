
class MessageActions

	# Covered



	def self.get_depart_info(message)
		names = parse_names(message)
		to = parse_location_to(message)
		result = { names: names, to: to }
	end

	# Covered
	def self.parse_arrived_long(message)
		# parse by commas and arrived to get who and where. 
		# send back to message.rb to update database with arrived
		names = parse_names(message)
		names_without_duplicates = checkDuplicateLastName(names)
		location = message.split("arrived")[-1].split(" at ")[-1].lstrip
		names_without_duplicates.each do | employee |
			employee.location = location 
			employee.save 
		end
	end

	# Covered
	# There are transit employee records for anyone who has departed but not yet
	# arrived. Transit employees are saved with an employee id and a phone number
	# related to who sent the departure message. Here, transit employees are looked
	# up by sender phone number and iterated over. During the iteration, the employee
	# is looked up, their destination is updated with the one in transit employee, and
	# then they are saved back to the database. The transit record is then destroyed.
	def self.updateDatabaseArrive(sender)
		transit_employees = TransitEmployee.where(sender: sender)
		transit_employees.each do | employee | 
			temp_employee = Employee.find(employee.employee_id)
			temp_employee.location = employee.destination
			temp_employee.save
			employee.destroy
		end
	end

	# Covered
	def self.updateDatabaseDepart(employees, destination)
		# takes names and loops through updating database with new location for each one
		# names is array of hashes of employee objects
		employees.each do | employee | 
			employee_temp = Employee.find_by(first_name: employee["first_name"], last_name: employee["last_name"])
			employee_temp.location = "driving to #{destination}"
			employee_temp.save
		end
	end

	# Covered
	def self.parse_location_to(message)
		# if the message contains the word to 
		if message =~ /\sto\s/
			return message.split(' to ')[-1]
		end

	end

	def self.emergency(message, sender, twilio_number)
		saudi_employees = Employee.where(in_saudi: true)
		saudi_employees.each do | employee | 
			to = employee.phone_num1
			employee_name = employee.first_name + " " + employee.last_name
			body = "Important message from #{employee_name}: #{message}"
			Message.send_message(to, body, twilio_number)
		end
	end

	# 
	def self.sitrep(sender)
	end

	def self.add_employee(message)
	end

	# Covered
	def self.checkDuplicateLastName(names)
		duplicates = []
		employees = []
		names.each do | name | 
			# check for duplicates, if there are, push them into
			employee_check = Employee.where(last_name: name, in_saudi: true)
			
			# If there is more than one person in saudi with the same last name, push the possible 
			# duplicate into duplicates array
			if employee_check.count > 1
				puts "There are duplicates!"
				duplicates.push(name)
			elsif employee_check == []
				puts "there was a problem and employee wasn't found"
				# call employee_spell_checker to get a list of names it could possibly be and send a text asking
			else
				# If the name is unique to people in saudi, retrieve employee, and 
				 # store in array to be returned
				employee = Employee.find_by(last_name: name, in_saudi: true)
				employees.push(employee)
			end
		end
		# if there are duplicate names then see if they exceed the number of names in database
				# i.e. if there are only two johnsons in saudi, and two johnsons were put down in text
				# then no need to check which ones. If there are three johnsons then get the right ones
		puts "Duplicates are #{duplicates}"
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
					# should there be a wait while it confirms message was sent?
					handle_duplicates(name, count)
					# so this is going to send off one name, but what if there are two smiths going
					# but there are three smiths in country. It currently asks which smith
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

	# Takes duplicate name, and how many were sent in the text (two smiths or five jacksons)
	def self.handle_duplicates(name, count)
		# take name, compose message with all first names of that last name, have them respond and if multiple
		# build message
		# send message
		# save sent message somehow with pending status. handle incoming text in controller so 
		# it doesn't get misrouted. 
		# when response is received, it should route to pending message method
	end

	def self.history(message, sender)
	end

	# Covered
	def self.parse_names(message)
		# message is ["bart, lisa, marge left al yamama to psab"]
		# remove "and"
		message_without_ands = message.gsub(/and/, '')
		first = message_without_ands.split(',')
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


	# def self.arrive(message, sender)
	# 	if message == "arrived"
	# 		updateDatabaseArrive(sender)
	# 	else
	# 		parse_arrived_long(message)
	# 	end
	# end

	# def self.parse_arrived_short(message, sender)
	# 	# finds the last message sent by the sender (except the one just sent saying arrived)
	# 	depart_message = Message.where(from: sender).last(2)[0]
	# 	# returns hash with keys names and to 
	# 	result = get_depart_info(depart_message["body"])
	# end