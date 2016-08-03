
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

	# Takes an array of last names ["solo", "fett"]
	# Takes sender which is the number who sent the text
	# Takes destination 
	# If the count of duplicate employees in text is the same as the number
	   # in the db, it returns an array of employee objects
	# If there is only one name reported in text and it's duplicate
	   # it should match the phone number to the name without having to ask
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
			#if there is one instance of duplicate, and sender is not the duplicate and there
				# are no other conflicts with other names (only one duplicate in message)
			elsif count == 1 and name != sender.last_name and duplicate_count.size == 1
				duplicate_names.push(name)
				duplicate_message_sender(name, sender, destination)
			# if there is more than 1 unique name in the duplicates from that message, we
				# will need to send multiple texts for each person. We need to queue up
				# a message to be delivered upon receipt of the first answer BUT WHAT IF ONE OF THOSE SETS OF DUPLICATES
				# CAN BE RESOLVED WITHOUT A MESSAGE OR BOTH? WHAT IF BOTH HAVE IT WHERE LIKE 1 DUPLICATE IS THE SENDER AND
				# THE SECOND DUPLICATES (2) HAVE 2 IN THE DATABASE, THEN IT'S ALL RESOLVED. WE HAVE TO EVALUATE ALL MESSAGES FIRST?

				# OR IF WE DO HIT THE ABOVE AND CALL DUPLICATE MESSAGE SENDER, IT SETS THE FLAG FOR QUEUED TO TRUEE AND AT THE TOP OF THIS EACH LOOP
				# WE CHECK TO SEE IF THERE ARE PENDING MESSAGES. THEN WHEN WE GET THE DUPLICATE MESSAGE SENDER, WE ONLY SEND IT IF THERE AREN'T, BUT IF
				# THERE ARE, THEN WE CREATE A MESSAGE WITH STATUS OF QUEUE.
			elsif duplicate_count.size > 1
				# call multiple duplicates and pass duplicate_count hash, sender, and destination
			elsif count > 1 and name == sender.last_name
				# get the names for the duplicates that are not the sender and somehow pass
				# sender to updateDatabase?
				# identify in the text message who is the person already identified, so
				# besides Nick Damiano, who is the other Damiano?
				employee_array.push(sender) # push the damiano we know it is
				duplicate_message_sender(name, sender, destination)
			elsif count > 1 and name!= sender.last_name
				# send the message with all names and expect an answer with multiple numbers				
			end
		end
		employee_array.flatten
	end

	def self.process_multiple_duplicates(duplicate_count, sender, destination)
		#if there are more than 1 unique duplicate name and we need to queue messages to get
		# clarification on those. 
		sender.queued_responses = true
	end

	def self.respond_for_queued_messages
      # otherwise, if it's greater than 1 and the set queue true on the sender's number 
         # send the first message
         # for remaining messages, create messages for messageQueue
      # when a message reply comes from the sender, handle the response but at the end, if
      # there are still message queues, grab the oldest and send the next one, if not, set the 
      # message queue flag to false THIS
	end


	# Needs test
	# takes a string of last name for name, the original texter's phone number, and a string
		# for destination
	def self.duplicate_message_sender(name, sender, destination)
		message="Which #{name} do you mean?\n"
		employees = Employee.where(last_name: name).where.not(first_name: sender.first_name) #exempts the sender who is arleady found
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
		# response is the paramaters from the response
		names = []
		employee_objects = []
		sender_number = original_message.to
		sender_object = Employee.find_by(phone_num1: sender_number)
		location = original_message.location
		queued_messages = sender_object.messages.where(status: "queued")
		# location = parse_location_to(original_message)
		names_with_numbers = original_message.body.split("\n")[1..-3]
		original_message.pending_response = false if queued_messages
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
		updateDatabaseDepart(employee_objects, location, sender_number)
		
		unless queued_messages.empty?
			# there are queued messages. if there are more than 1, we need to
			# call duplicate_message_sender with the data from queued message
			# delete queued message to prevent duplicate messages 
			# flag pending_response with true
			# 
		end
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