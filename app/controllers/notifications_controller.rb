class NotificationsController < ApplicationController

	skip_before_action :verify_authenticity_token

	def notify
		client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
		message = client.account.messages.create from: '+19037513020', to: '+19032749986', body: 'Learning to send SMS you are.', media_url: 'http://linode.rabasa.com/yoda.gif'
		render plain: message.status
	end

end