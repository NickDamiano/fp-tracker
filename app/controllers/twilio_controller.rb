
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

  def callback
    # capture message status (comes as parameter MessageStatus)
    status = params["MessageStatus"]
    

  end
end
