class MessageArrive

	def self.store_arrival(message, sender)
		if message == "arrived"
			update_database_arrive(sender)
		else
			result = parse_arrived_long(message, sender)
		end
	end

	# There are transit employee records for anyone who has departed but not yet
	# arrived. Transit employees are saved with an employee id and a phone number
	# related to who sent the departure message. Here, transit employees are looked
	# up by sender phone number and iterated over. During the iteration, the employee
	# is looked up, their destination is updated with the one in transit employee, and
	# then they are saved back to the database. The transit record is then destroyed.
	def self.update_database_arrive(sender)
		successes = []
		temp_employee = ''
		transit_employees = TransitEmployee.where(sender: sender)
		transit_employees.each do | employee | 
			temp_employee = Employee.find(employee.employee_id)
			temp_employee.location = employee.destination
			if temp_employee.save then successes.push(temp_employee) end
			employee.destroy
		end
		if transit_employees.empty?
			Message.send_message(sender, "No departure reported. Please send a full arrive message with names.")
		else
			Message.sendAckMessage(successes, sender, "arrived at #{temp_employee.location}")
		end
	end

	# Parses if message is "vader and fett arrived at the death star"
	def self.parse_arrived_long(message, sender)
		successes = []
		names = Message.parse_names(message)
		location = message.split("arrived")[-1].split(" at ")[-1].lstrip
		names_without_duplicates = DuplicateMessageAction.check_duplicate_last_name(names, sender, location)
		if names_without_duplicates.empty?
			return
		end
		names_without_duplicates.each do | employee |
			# if the employee doesn't eist. send message that says not found. 
			employee.location = location 
			if employee.save then successes.push(employee) end
		end
		Message.sendAckMessage(successes, sender, "arrived at #{location}")
	end
end