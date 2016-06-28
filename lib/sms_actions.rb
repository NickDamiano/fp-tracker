require 'twilio-ruby'

class SmsActions
	# should this be a hash as one variable
	def self.compose_message(to, from, body)
		account_sid = Rails.application.secrets.twilio_account_sid
		auth_token = Rails.application.secrets.twilio_auth_token
		@client = Twilio::REST::Client.new(account_sid, auth_token)

		@client.account.messages.create({body: body, to: to, from: from})
	end
end