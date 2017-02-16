require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'This is the Force Protection Tracker Application, created by Nick Damiano. 
      For help in using this application please text the word instructions to the number you just 
      dialed. Goodbye ', :voice => 'alice'
    end
  	render_twiml response
  end

  def callback
    # capture message status (comes as parameter MessageStatus)
    # updates message saved to Twilio user to reflect if it was successful or not
    messageSid = params["MessageSid"]
    status = params["MessageStatus"]
    message = Message.find_by(messageSid: messageSid)
    message.status = status 
    result = message.save

    render :nothing => true
  end


end
