
require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
 
  skip_before_action :verify_authenticity_token
 
  def voice
  	response = Twilio::TwiML::Response.new do |r|
  	  r.Say 'Pew Pew pew pew.PEYYYOOOOOOOH!.', :voice => 'alice'
         r.Play 'http://66.90.91.26/ost/best-of-nintendo-music/jfvbkyklty/53.-mega-man-2-wood-man.mp3'
  	end
 
  	render_twiml response
  end

  def testola
    account_sid = Rails.application.secrets.twilio_account_sid
    auth_token = Rails.application.secrets.twilio_auth_token


    @client = Twilio::REST::Client.new(account_sid, auth_token)
    p 'client created'

    message = @client.account.messages.create({
      from: from,
      to: to,
      body: body,
      statusCallback: "http://fptracker.herokuapp.com/twilio/callback"
    })
  end

  def callback
    # capture message status (comes as parameter MessageStatus)
    p StatusCallbackEvent
    p 'raw status above'
    p params["StatusCallbackEvent"]
    p 'params - StatusCallbackEvent above'
    status = params["MessageStatus"]
    p params 
    p "params above"
    p status 
    p "status above!!!!!!!!!!!"
    

  end
end
