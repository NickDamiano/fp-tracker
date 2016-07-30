
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
		names_without_duplicates = checkDuplicateLastName(names, sender)
		location = message.split("arrived")[-1].split(" at ")[-1].lstrip
		names_without_duplicates.each do | employee |
			employee.location = location 
			employee.save 
		end
	end

	def self.update_message_status(status)

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
	def self.checkDuplicateLastName(names, sender)
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
			result = handle_duplicates(duplicates, sender)
			employees.push(result).flatten!
		end
		#TODO push the result into employees
		employees
	end

	def self.handle_duplicates(duplicates, sender)
		employee_array = []
		sender = Employee.find_by(phone_num1: sender)

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
			end
		end
		employee_array.flatten
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