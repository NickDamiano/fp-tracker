class NotificationsController < ApplicationController

	skip_before_action :verify_authenticity_token

	def notify
		sid = ENV["TWILIO_ACCOUNT_SID"]
		token = ENV["TWILIO_AUTH_TOKEN"]
		client = Twilio::REST::Client.new(sid, token)
		message = client.account.messages.create from: '+19037513020', to: '+19032749986', body: 'Learning to send SMS you are.', media_url: 'http://linode.rabasa.com/yoda.gif'
		render plain: message.status
	end

end