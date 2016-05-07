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

	def self.emergency
		p "it's an emergency"
		# send out alert to all phone numbers for people in country including
		# sender so they can see it went out. Also sender gets response confirming
		# successful delivery to names
	end

	def self.deliver_sitrep(sender)
		p 'user is requesting a sitrep'
		# return message with all locations and names for everyone
	end

	def self.message_history(hours, sender)
		# send all messages back to sender from now until hours back
	end

	def self.toggle_autoforward
		# look at sender. check autoforward status and toggle
		# check to see if user has autoforward privledges?
	end
end
