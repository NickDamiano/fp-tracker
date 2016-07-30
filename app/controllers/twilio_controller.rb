
require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'This is the Force Protection Tracker Application, created by Nick Damiano. 
      For help in using this application please text the word help to the number you just 
      dialed. Goodbye ', :voice => 'alice'
    end
  	render_twiml response
  end

  def callback
    # capture message status (comes as parameter MessageStatus)
    messageSid = params["MessageSid"]
    status = params["MessageStatus"]
    message = Message.find_by(messageSid: messageSid)
    message.status = status 
    result = message.save

    render :nothing => true
  end


end
