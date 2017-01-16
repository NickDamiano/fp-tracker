require 'twilio-ruby'

class MessagesController < ApplicationController
	include Webhookable

	after_filter :set_header

	skip_before_action :verify_authenticity_token

	def receive
		# log message to history
		message = params["Body"]
		sender = params["From"]
		message.downcase! 

		# Call parser
		MessageParser.parse(message, sender)

		# necessary because no page is rendered with this controller method
		render :nothing => true

	end
end