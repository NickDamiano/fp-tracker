
class MessageActions

	# Covered
	def self.get_depart_info(message)
		names = parse_names(message)
		to = parse_location_to(message)
		result = { names: names, to: to }
	end

	# Covered
	def self.parse_arrived_long(message, sender)
		# parse by commas and arrived to get who and where. 
		# send back to message.rb to update database with arrived
		names = parse_names(message)
		names_without_duplicates = checkDuplicateLastName(names, sender, nil)
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
	def self.updateDatabaseDepart(employees, destination, sender)
		# takes names and loops through updating database with new location for each one
		# employees is array of hashes of employee objects
		employees.each do | employee | 
			employee_temp = Employee.find_by(first_name: employee["first_name"], last_name: employee["last_name"])
			employee_temp.location = "driving to #{destination}"
			employee_temp.save
			TransitEmployee.create(sender: sender, destination: destination, employee_id: employee["id"])
		end
	end

	# Covered
	def self.parse_location_to(message)
		# if the message contains the word to 
		if message =~ /\sto\s/
			return message.split(' to ')[-1]
		end
	end

	# Covered
	def self.emergency(message, sender)
		saudi_employees = Employee.where(in_saudi: true)
		saudi_employees.each do | employee | 
			to = employee.phone_num1
			employee_name = employee.first_name + " " + employee.last_name
			body = "Important message from #{employee_name}: #{message}"
			Message.send_message(to, body)
		end
	end

	# 
	def self.sitrep(sender)
	end

	def self.add_employee(message)
	end

	# Covered
	def self.checkDuplicateLastName(names, sender, destination)
		duplicates = []
		employees = []
		names.each do | name | 
			employee_check = Employee.where(last_name: name, in_saudi: true)
			
			if employee_check.count > 1
				puts "There are duplicates!"
				duplicates.push(name)
			elsif employee_check == []
				puts "there was a problem and employee wasn't found"
				#TODO call employee_spell_checker to get a list of names it 
				# could possibly be and send a text asking
			else
				employee = Employee.find_by(last_name: name, in_saudi: true)
				employees.push(employee)
			end
		end
		
		if duplicates[0]
			result = handle_duplicates(duplicates, sender, destination)
			employees.push(result).flatten!
		end
		#TODO push the result into employees
		employees
	end

	# needs test
	# Takes array of last names, sender's phone number, and destination
	def self.handle_duplicates(duplicates, sender, destination)
		employee_array = []
		sender = Employee.find_by(phone_num1: sender)
		duplicate_names = []
		# Outputs {"skywalker"=>2, "fett"=>1} if there are two skywalkers in text and 1 fett (and there are more in db)
		duplicate_count = duplicates.each_with_object(Hash.new(0)) {|name, counts | counts[name] +=1 }
		duplicate_count.each do | name, count |
			employees = Employee.where(last_name: "#{name}", in_saudi: true)
			# If the number of employees listed in the text matches the number in country, no need to send
			#  follow up text (two Smiths mentioned in text and only two smiths in country)
			if employees.count == count 
				employee_array.push(employees)
			#elsif there is only one duplicate instance of that name and the last name
			# matches the sender, push that employee(sender) into the array
			elsif count == 1 and name == sender.last_name
				employee_array.push(sender)
			#if there is one instance of duplicate, and sender is not the duplicate
			elsif count ==1 and name != sender.last_name
				# call duplicate_message_handler(name)
				duplicate_names.push(name)
				duplicate_message_sender(name, sender, destination)
			# if there is more than 1 instance of name - like 2 smiths in this group,
				# but 3 smiths in country. 
			# elsif count > 1 and name != sender.last_name
			# 	# send a message with the name and a list and you return with the numbers 
			# 	# separated by space like 1 3 selects 1st name and 3rd name
			end
		end
		employee_array.flatten
	end

	# Needs test
	def self.duplicate_message_sender(name, sender, destination)
		message="Which #{name} did you mean?\n"
		employees = Employee.where(last_name: name)
		employees.each.with_index(1) do | employee, index | 
			message += "#{index}. #{employee.first_name.capitalize} #{employee.last_name.capitalize}\n"
		end

		message = message + "\nRespond with the corresponding number"
		message_result = Message.send_message(sender.phone_num1, message)

		#Update the sent message with true pending status
		sent_message = Message.find_by(messageSid: message_result.messageSid)
		sent_message.pending_response = true
		# get response_sid from message just sent by sender
		sent_message.location = destination # add location reference
		
		sent_message.save
	end

	def self.duplicate_message_responder(original_message, response)
		# original_message is one asking about duplicates
		# response is response to original message
		names = []
		employee_objects = []
		sender = original_message.to
		location = original_message.location
		# location = parse_location_to(original_message)
		names_with_numbers = original_message.body.split("\n")[1..-3]
		original_message.pending_response = false
		original_message.save
		names_with_numbers.each do |name|
			names.push(name[3..-1])
		end
		selections = response.split(',').map{|num| num.to_i }
		selections.each do | selection |
			name = names[ selection - 1 ]
			# get first and last name
			first_and_last = name.split(' ') 
			employee = Employee.find_by( first_name: first_and_last[0].downcase,
				last_name: first_and_last[1].downcase )
			employee_objects.push(employee)
		end
		updateDatabaseDepart(employee_objects, location, sender)
		p ' stuff'
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