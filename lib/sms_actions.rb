require 'twilio-ruby'

class SmsActions
	include Webhookable

	after_filter :set_header

	skip_before_action :verify_authenticity_token
	# should this be a hash as one variable
	def self.compose_message(to, from, body)

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



		p 'end of smsactions'

		#TODO 
		# log the message here something like
		# Message.create(body: message.body, messageSid: message.sid, from: message.from,
		# to: message.to, status: "unknown" )



		# then when the message is delivered the callback hits 
		# the route and updates the message by SID as delivered


	end
end