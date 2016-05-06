class NotificationsController < ApplicationController

	skip_before_action :verify_authenticity_token

	def parse
		# log message to history
		p params["Body"]
		message = params["Body"]
		message.downcase!
		case message
		when /^911/
			p "It's an emergency"
			# call emergency method
		when /^sitrep/
			p "It's requesting sitrep"
			# call sitrep method from message_parse class
			# respond to sending number with 
		when /depart|left/
			p "it's depart"
			# call depart method
			MessageActions.depart
		when /arrive/
			p "it's arrive"
			# call arrive method
			MessageActions.arrive
		else
			p 'forward the message to nick'
		end
	end


end