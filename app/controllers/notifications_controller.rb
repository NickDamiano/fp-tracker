require 'twilio-ruby'

class NotificationsController < ApplicationController
	include Webhookable

	after_filtewr :set_header

	skip_before_action :verify_authenticity_token

	rescue_from StandardError do |exception|
		trigger_sms_alerts(exception)
	end

	def trigger_sms_alerts(e)
		@alert_message = "An error ocurred nick, Exception#{e}."
	end

	def parse
		# log message to history
		p params["Body"]
		message = params["Body"]
		sender = params["From"]
		message.downcase!
		Message.save_message(message, sender)

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
			'reporting location for specific person'
			Message.report_location(message, sender)
		when /^test/
			p "test path called"
			SMS_send
			# Message.auto_reply(message, sender)
		else
			p 'forward the message to nick'
			Message.forward_unparsed(message, sender)
		end

		# necessary because no page is rendered with this controller method
		render :nothing => true

	end

	def SMS_send

		p "in compose message"
		account_sid = Rails.application.secrets.twilio_account_sid
		auth_token = Rails.application.secrets.twilio_auth_token


		@client = Twilio::REST::Client.new(account_sid, auth_token)
		p 'client created'

		message = @client.account.messages.create({
			from: "+19032924343",
			to: "+15129944596",
			body: "this is a test",
			statusCallback: "http://fptracker.herokuapp.com/twilio/callback"
		})


		p 'end of smsactions'

		#TODO 
		# log the message here something like
		# Message.create(body: message.body, messageSid: message.sid, from: message.from,
		# to: message.to, status: "unknown" )



		# then when the message is delivered the callback hits 
		# the route and updates the message by SID as delivered


	end

	end


end