class MessageDepart

	def self.store_departure(message, sender)
		parsed_data = get_depart_info(message)
		names = parsed_data[:names]
		to = parsed_data[:to]
		non_duplicate_names = DuplicateMessageAction.check_duplicate_last_name(names, sender, to)
		if non_duplicate_names then update_database_depart(non_duplicate_names, to, sender) end
	end
	
	def self.get_depart_info(message)
		names = Message.parse_names(message)
		to = parse_location_to(message)
		result = { names: names, to: to }
	end

	def self.update_database_depart(employees, destination, sender)
		# takes names and loops through updating database with new location for each one
		# employees is array of hashes of employee objects
		successes = []
		employees.each do | employee | 
			employee_temp = Employee.find_by(first_name: employee["first_name"], last_name: employee["last_name"])
			employee_temp.location = "going to #{destination}"
			if employee_temp.save then successes.push(employee_temp) end
			TransitEmployee.create(sender: sender, destination: destination, employee_id: employee["id"])
		end
		Message.sendAckMessage(successes, sender, "en route to #{destination}")
	end

	def self.parse_location_to(message)
		#if the message contains the word to
		if message =~ /\sto\s/
			# returns this way in case message is "damiano going to the bank to make a deposit" there are two to's! 
			return message.split(' to ')[1..-1].join(' to ')
		# sometimes it's just a message without to like "skywalker going downtown" or "skywalker going home"
		elsif message =~ /going\s/
			return message.split('going ')[-1]
		end
	end
	
end