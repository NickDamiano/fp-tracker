class MessageParser

	def self.parse(message, sender)
		# gets the last message matching this criteria
		original_message = Message.where(to: sender, pending_response: true).last
		# this_message = Message.save_message(message, sender)

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
		when /instructions/
			# Employee requesting instructions on app
			Message.give_instructions(sender)
		when /^where/
			# asking for location of a specific person
			Message.report_location(message, sender)
		when /^[0-9]/
			if original_message
				# The Employee is responding to a message asking about duplicate names
				DuplicateMessageAction.duplicate_message_responder(original_message, message)
			end
		else
			if original_message =~ /registration/
				Employee.parse_registration(message, sender, original_message)
			end
			this_message.status = 'unable to parse'
			this_message.save
			# Send back error message
			Message.send_message(sender, "I didn't understand your message.\n If you need help, text me the word 'instructions'.")
		end
	end
end