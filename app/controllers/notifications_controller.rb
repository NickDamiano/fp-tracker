class NotificationsController < ApplicationController

	skip_before_action :verify_authenticity_token

	def parse
		# log message to history
		p params["Body"]
		message = params["Body"]
		sender = params["From"]
		message.downcase!

		case message
		when /^911/
			p "It's an emergency"
			Message.report_emergency(message, sender)
		when /^add employee/
			p 'adding someone to the database'
			Message.add_employee(message)
		when /^sitrep/
			p "It's requesting sitrep"
			Message.send_sitrep(sender)
		when /depart|left|leaving|going/
			p "it's depart"
			Message.store_departure(message)
		when /arrive/
			p "it's arrive"
			Message.store_arrival(message)
		when /autoforward/
			p 'autoforwarding enabled or disabled'
			Message.toggle_autoforward(sender)
		when /instructions/
			p 'user requested instructions'
			Message.give_instructions(sender)
		when /history/
			p 'give user history of messages within last x amount of hours'
			Message.message_history(message, sender)
		when /where/
			# asking for location of a specific person
			'reporting location for specific person'
			Message.report_location(message, sender)
		else
			p 'forward the message to nick'
			Message.forward_unparsed(message, sender)
		end

		# necessary because no page is rendered with this controller method
		render :nothing => true

	end


end