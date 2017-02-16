require 'twilio-ruby'

class Message < ActiveRecord::Base
	belongs_to :employee

	@@account_sid = Rails.application.secrets.twilio_account_sid
	@@auth_token = Rails.application.secrets.twilio_auth_token

	# Default Twilio test number for successful returns
	if Rails.env.test? 
		Twilio_number = "+15005550006" 
	else
		Twilio_number = Rails.application.secrets.twilio_number.to_s
	end

	def self.save_message(message, sender)
		sender_employee = Employee.find_by(phone_num1: sender) || Employee.find_by(first_name: "not in the system") #TODO add seed for this
		Message.create(from: sender, body: message, employee_id: sender_employee.id, status: "parsed")
	end

	def self.send_message(to, body)
		@client = Twilio::REST::Client.new(@@account_sid, @@auth_token)

		message = @client.account.messages.create({
			from: Twilio_number,
			to: to,
			body: body,
			statusCallback: "http://fptracker.herokuapp.com/twilio/callback"

		})

		# Capture sent text message information into messages associated with my Twilio App
		employee = Employee.find_by(first_name: "twilio_app")
		employee.messages.create( messageSid: message.sid, from: Twilio_number, to: to, 
			body: message.body, status: "webhook sent" )
	end

	def self.give_instructions(sender)
		employee = Employee.find_by(phone_num1: sender)
		depart = "Departing: When departing, text 'lastname, lastname going to location'\n\n"
		arrive = "Arriving: If a depart message was sent, text 'arrived' & FP-tracker will update based off depart message. If no depart was sent, text 'lastname, lastname arrived at location'\n\n"
		emergency = "Emergency: In an emergency, text '911 your message here' & your message will be forwarded to everyone in country.\n\n"
		sitrep = "Sitrep: to request a list of all employees and their location text 'sitrep' (situation report)"
		# if user has admin privledge to receive sitrep, send that additional line
		employee.admin ? message = depart + arrive + emergency + sitrep : message = depart + arrive + emergency
		Message.send_message(sender, message)
	end

	# Forwards message to all personnel 'in-country'
	def self.report_emergency(message, sender)
		in_country_employees = Employee.where(in_country: true)
		in_country_employees.each do | employee | 
			to = employee.phone_num1
			employee_name = employee.first_name + " " + employee.last_name
			body = "Important message from #{employee_name}: #{message}"
			Message.send_message(to, body)
		end
	end

	# Respond to sender with list of personnel and their locations
	def self.send_sitrep(sender)
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
		send_message(sender, message)
	end

	def self.send_reject_message(original_message, response)
		message = "#{response} is not one of the listed options. Please try again."
		to = original_message.to 
		send_message(to, message)
	end

	def self.sendAckMessage(employees, sender, message)
		employees = employees.uniq
		first_employee = employees.shift
		names_string = "#{first_employee.first_name} #{first_employee.last_name}"
		employees.each do | employee | 
			names_string+= ", #{employee.first_name} #{employee.last_name}"
		end
		body = "I copy #{names_string} #{message}"
		send_message(sender, body)
	end

	def self.parse_names(message)
		# message is ["bart, lisa, marge going to psab"]
		#   remove "and" and replace with ',' which solves when it's two names like
		#   fett and skywalker without a comma since it splits it on the next line
		#   split by arrived or going
		if message =~ /going/ then message = message.split("going") end
		if message =~ /arrive/ then message = message.split("arrived") end
		message_without_ands = message[0].gsub(/\sand\s/, ',')
		first = message_without_ands.split(',')
		# necessary because of the fix above to handle and without commas in message 
		first = first.reject { |name | name.blank? }
		# gets last name and pushes them all together. 
		# Returns ["bart, lisa, marge"]
		last = first[-1]
		last_name = last.lstrip.split(' ')[0]
		first[0...-1].each{ | name | name.strip!}.push(last_name)
	end
end
