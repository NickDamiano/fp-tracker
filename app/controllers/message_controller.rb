require 'twilio-ruby'

class MessageController < ApplicationController
	include Webhookable

	after_filter :set_header

	skip_before_action :verify_authenticity_token

	def receive
		message = params["Body"]
		sender = params["From"]
		message.downcase! 

		MessageParser.parse(message, sender)

		render :nothing => true
	end
end