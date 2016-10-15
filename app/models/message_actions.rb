
class MessageActions

	# Covered
	def self.get_depart_info(message)
		names = parse_names(message)
		to = parse_location_to(message)
		result = { names: names, to: to }
	end

	# Covered
	# works for non-duplicates. does not send ack message
	def self.ParseArrivedLong(message, sender)
		# parse by commas and arrived to get who and where. 
		# send back to message.rb to update database with arrived
		# first we parse the names out
		successes = []
		names = parse_names(message)
		#then we parse the location
		location = message.split("arrived")[-1].split(" at ")[-1].lstrip
		# then we run the duplicate checker to get non-duplicates
		names_without_duplicates = checkDuplicateLastName(names, sender, location)
		names_without_duplicates.each do | employee |
			employee.location = location 
			if employee.save then successes.push(employee) end
		end
		sendAckMessage(successes, sender, "arrived at #{location}")
	end

	# Covered
	# There are transit employee records for anyone who has departed but not yet
	# arrived. Transit employees are saved with an employee id and a phone number
	# related to who sent the departure message. Here, transit employees are looked
	# up by sender phone number and iterated over. During the iteration, the employee
	# is looked up, their destination is updated with the one in transit employee, and
	# then they are saved back to the database. The transit record is then destroyed.
	def self.updateDatabaseArrive(sender)
		successes = []
		temp_employee = ''
		transit_employees = TransitEmployee.where(sender: sender)
		transit_employees.each do | employee | 
			temp_employee = Employee.find(employee.employee_id)
			temp_employee.location = employee.destination
			if temp_employee.save then successes.push(temp_employee) end
			employee.destroy
		end
		sendAckMessage(successes, sender, "arrived at #{temp_employee.location}")

	end

	def self.sendAckMessage(employees, sender, message)
		# get the message with names and destination
		# send message with sender to and message "Acknowledge that Nicholas Damiano, Boba Fett, and Leia Organa are going to
		# the mall"
		# Pop off first employee so additional ones can be iterated with a comma after them 
		first_employee = employees.shift
		# binding.pry
		# p 'test'
		names_string = "#{first_employee.first_name} #{first_employee.last_name}"
		employees.each do | employee | 
			names_string+= ", #{employee.first_name} #{employee.last_name}"
		end
		body = "I copy #{names_string} #{message}"
		Message.send_message(sender, body)
	end

	# Covered
	def self.updateDatabaseDepart(employees, destination, sender)
		# takes names and loops through updating database with new location for each one
		# employees is array of hashes of employee objects
		successes = []
		employees.each do | employee | 
			employee_temp = Employee.find_by(first_name: employee["first_name"], last_name: employee["last_name"])
			employee_temp.location = "going to #{destination}"
			if employee_temp.save then successes.push(employee_temp) end
			TransitEmployee.create(sender: sender, destination: destination, employee_id: employee["id"])
		end
		sendAckMessage(successes, sender, "en route to #{destination}")
	end

	# Covered
	def self.parse_location_to(message)
		# if the message contains the word to 
		if message =~ /\sto\s/
			return message.split(' to ')[-1]
		elsif message =~ /going\s/
			return message.split('going ')[-1]
		end
	end

	# Covered
	def self.emergency(message, sender)
		saudi_employees = Employee.where(in_country: true)
		saudi_employees.each do | employee | 
			to = employee.phone_num1
			employee_name = employee.first_name + " " + employee.last_name
			body = "Important message from #{employee_name}: #{message}"
			Message.send_message(to, body)
		end
	end
	
	def self.sitrep(sender)
		if Employee.find_by(phone_num1: sender).admin 
			message = ''
			employees = Employee.where(in_country: true).order(:last_name, :first_name)
			employees.each do |employee|
				first = employee.first_name || "no first name"
				last = employee.last_name || "no last name"
				location = employee.location || "no location listed"
				line = "#{last.capitalize}, #{first.capitalize}: #{location.capitalize}\n"
				message += line
			end
		else
			message = "You need admin privledges to request a sitrep"
		end
		Message.send_message(sender, message)
	end

	def self.add_employee(message)
	end

	# Covered
	def self.checkDuplicateLastName(names, sender, destination)
		duplicates = []
		employees = []
		names.each do | name | 
			employee_check = Employee.where(last_name: name, in_country: true)
			if employee_check.count == 1
				employee = employee_check[0] # only entry in database
				employees.push(employee)
			elsif employee_check.count > 1
				puts "There are duplicates!"
				duplicates.push(name)
			elsif employee_check == []
				puts "there was a problem and employee wasn't found"
				#TODO call employee_spell_checker to get a list of names it 
				# could possibly be and send a text asking
			end
		end
		if duplicates[0]
			result = handle_duplicates(duplicates, sender, destination)
			employees.push(result).flatten!
		end
		employees
	end

	# Takes an array of last names ["solo", "fett"]
	# Takes sender which is the number who sent the text
	# Takes destination 
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

	# Needs test
	# takes a an array of arrays [[smith, 1],[jones,2]] of last name for name, the object for the sender, and a string
		# for destination. Builds and stores message in the database. 
	def self.duplicate_message_builder(names, sender, destination)
		names.each do | name_array |
			name = name_array[0]
			number_of_unique_name = name_array[1] # really this probably doesn't matter

			message="Which #{name} do you mean?\n"
			employees = Employee.where(last_name: name) 
			employees.each.with_index(1) do | employee, index | 

				message += "#{index}. #{employee.first_name.capitalize} #{employee.last_name.capitalize}\n"
			end

			message += "\nRespond with the corresponding number " 
			if number_of_unique_name > 1 then message +=  "for the #{number_of_unique_name} #{name}'s separated by commas" end

			Message.create(to: sender.phone_num1, body: message, status: "pending", location: destination)
		end
		# set the query pending flag
		sender.queries_pending = true
		sender.save
		MessageActions.retrieve_and_send_message(sender)

	end

	# sender is active record object
	def self.retrieve_and_send_message(sender)
		# pulls the message out of the db and converts it to be sent by message and sends it. 
		messages = Message.where(status: "pending")

		message = messages[0]
		body = message.body
		to = sender.phone_num1
		location = message.location
		message.destroy # want to destroy so as to not create duplicates since the message send below creates one

		if messages.size == 1 # if there is only one pending message
			sender.queries_pending = false # set the flag to false so future messages from sender are handled correctly
			sender.save
		end

		# delete the pending message from database
		message_result = Message.send_message(to, body)

		#Update the sent message with true pending status
		sent_message = Message.find_by(messageSid: message_result.messageSid)
		sent_message.pending_response = true
		# get response_sid from message just sent by sender
		sent_message.location = location # add location reference
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

		# location = parse_location_to(original_message)
		names_with_numbers = original_message.body.split("\n")[1..-3]

		names_with_numbers.each do |name|
			names.push(name[3..-1])
		end
		selections = response.split(',').map{|num| num.to_i }
		selections.each do | selection |
			name = names[ selection - 1 ]
			#TODO handle if the number is a higher one than the options provided
			# get first and last name if the name was
			if name == nil 
				send_reject_message(original_message, response)
				return
			end
			first_and_last = name.split(' ') 
			employee = Employee.find_by( first_name: first_and_last[0].downcase,
			last_name: first_and_last[1].downcase )
			employee_objects.push(employee)
		end
		################_____----------!!!!!!!!!!!!!!!!!!
		# get the last message inidicating arrived or departed

		senders_message = Employee.find_by(phone_num1: original_message.to).messages.reverse_order.where("body ~* ?", "(going|arrived)").first
		if senders_message.body =~ /arrive/
			# process arrived - the only way to do this with existing flow is to create a transit
			# employee and then call updateDatabaseArrive which is somewhat hacky but the best hackiest solution
			employee_objects.each do | employee |
				TransitEmployee.create(sender: sender_number, destination: location, employee_id: employee["id"])
			end
			updateDatabaseArrive(sender_number)
		elsif senders_message.body =~ /going/
			updateDatabaseDepart(employee_objects, location, sender_number)
		end
		# change the pending response for this particular message so when it pulls out the 
			# next one it gets the right one
		original_message.pending_response = false
		original_message.save
		# so now we've received the response and processed it by saving the employee records to the database
		# next we need to send a follow-up if there are queued messages
		if sender_object.queries_pending
			retrieve_and_send_message(sender_object)
		end
	end

	def self.send_reject_message(original_message, response)
		message = "#{response} is not one of the listed options. Please try again."
		to = original_message.to 
		Message.send_message(to, message)
	end

	def self.history(message, sender)
	end

	# Covered
	def self.parse_names(message)
		# message is ["bart, lisa, marge left al yamama to psab"]
		# remove "and" and replace with ',' which solves when it's two names like
			#fett and skywalker without a comma since it splits it on the next line
		message_without_ands = message.gsub(/\sand\s/, ',')
		first = message_without_ands.split(',')
		# necessary because of the fix above to handle and without commas in message 
		first = first.reject { |name | name.blank? }
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
