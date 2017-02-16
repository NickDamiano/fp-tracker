class MessageParser

	def self.parse(message, sender)
		# If the employee is not registered and is not sending registration message, reject them.
		if Employee.find_by(phone_num1: sender) == nil && message !~ /^register/i
			Message.send_message(sender, "You are not registered. text 'register' to begin registration.")
			return
		end
		# Original message is required to parse responses to challenges from FP-Tracker. It is the message FP tracker
		#   sent to the employee to ask which employee they meant when there are duplicates
		original_message = Message.where(to: sender, pending_response: true).last
		last_message = Message.where(to: sender).last
		# This code checks to see if a Registration prompt was sent by FP-Tracker, in which 
		#   case it flags registration_message and later calls parse_registration
		if last_message
			last_message.body =~ /^Registration/ ? registration_message = last_message : nil
		end
		this_message = Message.save_message(message, sender)

		case message
		when /^register/
			# New employee is registering themselves via text
			Employee.register_employee(sender)
		when /^unregister/
			# Employee wants to be deleted from database
			Employee.unregister_employee(sender)
		when /^911/
			# Emergency - message is forwarded to all personnel in country
			Message.report_emergency(message, sender)
		when /^sitrep/
			# A list of all names and their locations is sent back (if admin)
			Message.send_sitrep(sender)
		when /going/
			# Employee reporting departure
			MessageDepart.store_departure(message, sender)
		when /arrive/
			# Employee reporting arrival
			MessageArrive.store_arrival(message, sender)
		when /^instructions/
			# Employee requesting instructions on app
			Message.give_instructions(sender)
		when /^[0-9]/
			if original_message
				# The Employee is responding to a message asking about duplicate names
				DuplicateMessageAction.duplicate_message_responder(original_message, message)
			end
		else
			# Matches if sender is responding to a registration message from FP-Tracker
			if registration_message
				Employee.parse_registration(message, sender, registration_message)
			else
				# Message didn't match any, send rejection message
				this_message.status = 'unable to parse'
				this_message.save
				# Send back error message
				Message.send_message(sender, "I didn't understand your message.\n If you need help, text me the word 'instructions'.")
			end
		end
	end
end