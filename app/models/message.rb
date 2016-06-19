# Entire message = params
# Message = body of text
# Sender = "+19034343121" (example)

class Message < ActiveRecord::Base
	belongs_to :employee

	# Test covered
	def self.save_message(message, sender)
		sender_employee = Employee.find_by(phone_num1: "#{sender}")
		Message.create(from: sender, body: message, employee_id: sender_employee.id)
	end

	# Test covered
	def self.store_departure(message, sender)
		parsed_data = MessageActions.get_depart_info(message)
		names = parsed_data[:names]
		to = parsed_data[:to]
		result = MessageActions.checkDuplicateLastName(names)
		MessageActions.updateDatabaseDepart(result, to)
		# Save a transit record to be referenced for arrive
		result.each do | employee | 
			TransitEmployee.create(sender: sender, destination: to, employee_id: employee["id"])
		end
	end

	# covered
	def self.store_arrival(message, sender)
		if message == "arrived"
			MessageActions.updateDatabaseArrive(sender)
		else
			result = parse_arrived_long(message, sender)
		end
	end

	def self.report_emergency(message, sender)
		p "it's an emergency"
		result = MessageActions.emergency(message, sender)
		# Generally used if employee tries to call manager and gets no response
		# when medical or accident or life threatening thing
		# send out alert to all phone numbers for people in country including
		# sender so they can see it went out. Also sender gets response confirming
		# successful delivery to names
	end

	def self.send_sitrep(sender)
		p 'user is requesting a sitrep'
		result = MessageActions.sitrep(sender)
		# return message with all locations and names for everyone
	end

	def self.message_history(message, sender)
		result = MessageActions.history(message, sender)
		# send all messages back to sender from now until hours back
	end

	def self.add_employee(message)
		result = MessageActions.add_employee(message)
		# maybe this is done by the employee by texting and it asks a series of questions 
			# and then registers them after confirming all information is correct. 
		# admin message
	end

	def self.remove_employee(message)
		# removes employees leaving permanently
		# admin message
	end

	def self.toggle_employee_saudi_presence(employee)
		# if employee leaves the country or arrives, toggle their status so they
		# don't receive alerts and are marked as out of saudi
		# admin message
	end

	def self.toggle_autoforward(sender)
		# look at sender. check autoforward status and toggle
		# check to see if user has autoforward privledges?
	end

	def self.forward_unparsed(message, sender)
		# send unparsed to admin to figure out why
		result = MessageActions.forward_unparsed(message, sender)
	end

	def self.give_instructions(sender)
		# maybe it pulls it from a yaml file and responds to the message
		# 'return a message explaining how to report departure, arrival,
		# 911, autoforward, sitrep (for those who have privledges'
	end

	def self.report_location(message, sender)
		result = MessageActions.report_location(message)
	end

end
