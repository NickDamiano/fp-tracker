# Entire message = params
# Message = body of text
# Sender = "+19034343121" (example)

class Message < ActiveRecord::Base
	belongs_to :employee

	def self.store_departure(message)
		result = MessageActions.depart(message)
		# iterate through each name and update database
		p "result is #{result}"
	end

	def self.store_arrival(message)
		result = MessageActions.arrive(message)
		p "result is #{result}"
		#iterate through each name and update database with arrival
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

end
