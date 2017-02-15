
# This class flows like this: first we separate the unique names from the ones that are duplicates by doing 
#   check_duplicate_last_name and handle_duplicates. We return an array of AR objects for unique names and 
#   continue to process the duplicates with duplicate message builder. Duplicate message builder takes each name
#   that we need to figure out who the sender meant and builds a message asking "Which name did you mean...". It marks
#   them as pending messages and calls retrieve and send message. Retrieve and send message is called and pulls out a 
#   pending message previously built and sends it to the user. When the user responds with a number for which duplicate name
#   it calls duplicate message responder and if more names need to be clarified from that user's original depart/arrive message,
#   it calls the retrieve and send message again. It repeates these last two steps until all names reported are updated in database

class DuplicateMessageAction

	# Takes array of last names, and strings for sender number and destination. Parses out
	#   duplicate names, calls handle duplicates which returns unique names for certain situations
	#   and returns an array of employee objects back to method that called it
	def self.check_duplicate_last_name(names, sender, destination)
		# For duplicate names
		duplicates = []
		# For non-duplicate (unique) names
		employees = []
		names.each do | name | 
			employee_check = Employee.where(last_name: name, in_country: true)
			if employee_check.count == 1
				employee = employee_check[0]
				employees.push(employee)
			elsif employee_check.count > 1
				duplicates.push(name)
			elsif employee_check == []
				not_found_message = "#{name} was not found. Please check your spelling" \
					" or contact your system administrator."
				Message.send_message(sender, not_found_message)
			end
		end
		if duplicates[0]
			result = handle_duplicates(duplicates, sender, destination)
			employees.push(result).flatten!
		end
		if employees.empty? then employees = nil end
		employees
	end

	# Takes an array of last names ["solo", "fett"], Takes sender which is the number who 
	#   sent the text and takes destination. Returns array of unique names to check_duplicate_last_name
	def self.handle_duplicates(duplicates, sender, destination)
		employee_array = []
		sender = Employee.find_by(phone_num1: sender)
		duplicate_names = []
		# Outputs {"skywalker"=>2, "fett"=>1} if there are two skywalkers in text and 1 fett (and there are more in db)
		duplicate_count = duplicates.each_with_object(Hash.new(0)) {|name, counts | counts[name] +=1 }
		duplicate_count.each do | name, count |
			employees = Employee.where(last_name: "#{name}", in_country: true)
			# If the number of employees listed in the text matches the number in country, no need to send
			#  follow up text (two Smiths mentioned in text and only two smiths in country)
			if employees.count == count 
				employee_array.push(employees)
			#elsif there is only one duplicate instance of that name and the last name
			# matches the sender, push that employee(sender) into the array
			elsif count == 1 and name == sender.last_name
				employee_array.push(sender)
			elsif count >= 1 
				# if we are here, then the count is 1 and the sender is not the duplicate, OR the count is greater than 1 and we don't care if 
				# the sender is one of the duplicates because it's simpler to treat them the same. 
				duplicate_names.push([name,count])
			end
		end
		duplicate_message_builder(duplicate_names, sender, destination) unless duplicate_names.empty?
		employee_array.flatten
	end

	# takes a an array of arrays [[smith, 1],[jones,2]] of last name for name, the object for the sender, and a string
	#   for destination. Builds and stores message in the database. Calls Retrieve and send message to begin interrogation
	#   sequence of texts to determine who the duplicates are
	def self.duplicate_message_builder(names, sender, destination)
		names.each do | name_array |
			name = name_array[0]
			number_of_unique_name = name_array[1] 
			# delay it for a second to let confirmation hit first for others in party
			sleep(2)
			message="Which #{name} do you mean?\n"
			employees = Employee.where(last_name: name) 
			employees.each.with_index(1) do | employee, index | 

				message += "#{index}. #{employee.first_name.capitalize} #{employee.last_name.capitalize}\n"
			end

			message += "\nRespond with the corresponding number " 
			if number_of_unique_name > 1 then message +=  "for the #{number_of_unique_name} #{name}'s separated by commas" end
			# We load the database with a message for each name to be verified under pending status. Later we will find these by pending status 
			#   to send follow up inquiry's after the previous inquiry was answered. 
			Message.create(to: sender.phone_num1, body: message, status: "pending", location: destination)
		end
		# set the query pending flag
		sender.queries_pending = true
		sender.save
		retrieve_and_send_message(sender)

	end

	# gets pending messages for duplicate inquiries and sends them. sender is active record object
	#   called by duplicate message builder for initial inquiry and by duplicate message responder after
	#   sender answers first inquiry (if more are queued)
	def self.retrieve_and_send_message(sender)
		# pulls the message out of the db and converts it to be sent by message and sends it. 
		messages = Message.where(status: "pending")
		message = messages[0]
		body = message.body
		to = sender.phone_num1
		location = message.location
		message.destroy # destroy the 'pending message' since it was a placeholder for the actual message sent below which is also saved

		if messages.size == 1 # if there is only one pending message
			sender.queries_pending = false # set the flag to false so future messages from sender are handled correctly
			sender.save
		end

		message_result = Message.send_message(to, body)

		#Update the sent message with true pending status since we are awaiting a response from the sender
		sent_message = Message.find_by(messageSid: message_result.messageSid)
		sent_message.pending_response = true
		sent_message.location = location # add location reference to be accessed during response handling
		sent_message.save
	end

		# original_message is one asking about duplicates, response is the parameters from the response, 
		# 	this method is called by the MesssageParser.parse if a response is identified to pending response
		#   calls retrieve and send message if more messages need to be sent about additional duplicate names
	def self.duplicate_message_responder(original_message, response)
		names = []
		employee_objects = []
		sender_number = original_message.to
		sender_object = Employee.find_by(phone_num1: sender_number)
		location = original_message.location

		names_with_numbers = original_message.body.split("\n")[1..-3]
		names_with_numbers.each do |name|
			names.push(name[3..-1])
		end
		selections = response.split(',').map{|num| num.to_i }
		selections.each do | selection |
			name = names[ selection - 1 ]
			if name == nil 
				Message.send_reject_message(original_message, response)
				return
			end
			first_and_last = name.split(' ') 
			employee = Employee.find_by( first_name: first_and_last[0].downcase,
			last_name: first_and_last[1].downcase )
			employee_objects.push(employee)
		end
		# get the last message inidicating arrived or departed
		senders_message = Employee.find_by(phone_num1: original_message.to).messages.reverse_order.where("body ~* ?", "(going|arrived)").first
		if senders_message && senders_message.body =~ /arrive/
			# process arrived - the only way to do this with existing flow is to create a transit
			# employee and then call update_database_arrive
			employee_objects.each do | employee |
				TransitEmployee.create(sender: sender_number, destination: location, employee_id: employee["id"])
			end
			MessageArrive.update_database_arrive(sender_number)
		elsif senders_message.body =~ /going/
			MessageDepart.update_database_depart(employee_objects, location, sender_number)
		end
		# change the pending response for this particular message so when it pulls out the next one it gets the right one
		original_message.pending_response = false
		original_message.save
		# so now we've received the response and processed it by saving the employee records to the database
		# next we need to send a follow-up if there are queued messages
		if sender_object.queries_pending
			retrieve_and_send_message(sender_object)
		end
	end
end
