require 'twilio-ruby'
require 'pry-byebug'

class SmsActions
	# should this be a hash as one variable
	def self.compose_message(to, from, body)
		p "in compose message"
		account_sid = Rails.application.secrets.twilio_account_sid
		auth_token = Rails.application.secrets.twilio_auth_token

		@client = Twilio::REST::Client.new(account_sid, auth_token)

		message = @client.account.messages.create({
			body: body, 
			to: to, 
			from: from,
			statusCallback: "http://fptracker.herokuapp.com/twilio/callback"
		})

		#TODO 
		# log the message here something like
		Message.create(body: message.body, messageSid: message.sid, from: message.from,
		to: message.to, status: "unknown" )

		

		# then when the message is delivered the callback hits 
		# the route and updates the message by SID as delivered


	end
end