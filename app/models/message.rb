require 'twilio-ruby'

class Message < ActiveRecord::Base
	belongs_to :employee

	if Rails.env.test? 
		Twilio_number = "+15005550006"
	else
		Twilio_number = Rails.application.secrets.twilio_number.to_s
	end


	# Covered
	def self.save_message(message, sender)
		sender_employee = Employee.find_by(phone_num1: sender) || Employee.find_by(first_name: "not in the system") #TODO add seed for this
		Message.create(from: sender, body: message, employee_id: sender_employee.id)
	end

	def self.auto_reply(sender, message)
		from = Twilio_number
		p "in auto reply"
		message = "test received"
		send_message(sender, message, from)
	end

	def self.send_message(to, body)
		callback_address = 
		account_sid = Rails.application.secrets.twilio_account_sid
		auth_token = Rails.application.secrets.twilio_auth_token

		@client = Twilio::REST::Client.new(account_sid, auth_token)
		p "ABOUT TO SEND THE MESSAGE"
		message = @client.account.messages.create({
			from: Twilio_number,
			to: to,
			body: body,
			# statusCallback: "http://fptracker.herokuapp.com/twilio/callback"
			statusCallback: "http://8ad4a1ef.ngrok.io/twilio/callback"
		})
		p "MESSAGE SENT"
		p "MESSAGE SID = #{message.sid}!!!!!!"
		employee = Employee.find_by(first_name: "twilio_app")
		employee.messages.create( messageSid: message.sid, from: Twilio_number, to: to, 
			body: message.body, status: "webhook sent" )

	end
	
	# Covered
	def self.store_departure(message, sender)
		parsed_data = MessageActions.get_depart_info(message)
		names = parsed_data[:names]
		to = parsed_data[:to]
		non_duplicate_names = MessageActions.checkDuplicateLastName(names, sender, to)
		MessageActions.updateDatabaseDepart(non_duplicate_names, to, sender)
	end

	# Covered
	def self.store_arrival(message, sender)
		if message == "arrived"
			MessageActions.updateDatabaseArrive(sender)
		else
			result = parse_arrived_long(message, sender)
		end
	end


	# Generally used if employee tries to call manager and gets no response
		# when medical or accident or life threatening thing
		# send out alert to all phone numbers for people in country including
		# sender so they can see it went out. Also sender gets response confirming
		# successful delivery to names
	def self.report_emergency(message, sender)
		# sender is who needs help in an emergency
		p "it's an emergency"
		result = MessageActions.emergency(message, sender)
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
