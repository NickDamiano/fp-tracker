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
		when /depart|left|leaving|going/
			p "it's depart"
			Message.store_departure(message)
			# update database
		when /arrive/
			p "it's arrive"
			# call arrive method
			Message.store_arrival(message)
		when /autoforward/
			p 'autoforwarding enabled or disabled'
			Message.toggle_autoforward
		else
			p 'forward the message to nick'
			# call forward to nick method
			Message.forward_unparsed(message)
		end

		# necessary because no page is rendered with this controller method
		render :nothing => true

	end


end