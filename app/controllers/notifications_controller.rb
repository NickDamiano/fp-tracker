require 'twilio-ruby'

class NotificationsController < ApplicationController
	include Webhookable

	after_filter :set_header

	skip_before_action :verify_authenticity_token

	def parse
		# log message to history
		p params["Body"]
		message = params["Body"]
		sender = params["From"]
		message.downcase! 
		# gets the last message matching this criteria
		original_message = Message.where(to: sender, pending_response: true).last
		Message.save_message(message, sender)

		case message
		when /^register/
			p 'User is registering a new number'
			Message.register_user(sender)
		when /^unregister/
			p 'User wants to unregister themselves'
			Message.unregister_user(sender)
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
			Message.store_departure(message, sender)
		when /arrive/
			p "it's arrive"
			Message.store_arrival(message, sender)
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
			p 'reporting location for specific person'
			Message.report_location(message, sender)
		when /^test/
			p "test path called"
			my_num = Rails.application.secrets.twilio_number
			Message.auto_reply(sender, message)
		when /^[0-9]/
			if original_message
				p "responding to a duplicate message"
				MessageActions.duplicate_message_responder(original_message, message)
			end
		else
			# TODO if the original message matches the word registration then it's responding
			# call a messageActions method that parses first name, last name, location additionally but also regexes out
			# special characters. only numbers, letters, dashes, and spaces
			p 'send error message'
			Message.send_message(sender, "I didn't understand your message.\n If you need help, text me the word 'instructions'.")
			Message.forward_unparsed(message, sender)
		end

		# necessary because no page is rendered with this controller method
		render :nothing => true

	end
end