
require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'This is the Force Protection Tracker Application, created by Nick Domiahno', :voice => 'alice'
    end
  	render_twiml response
  end

  def record
    response = Twilio::TwiML::Response.new do |r|
      r.Say 'Record your message'
      # r.Record :maxLength => '6', :action => '/twilio/process_recording' :method => 'post'
    end.text
  end

  def process_recording
    Twilio::TwiML::Response.new do |r|
      recording = params['RecordingUrl']
      r.Play recording 
      r.Say 'That is what you sound like'
    end.text
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
