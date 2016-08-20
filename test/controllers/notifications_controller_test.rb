require 'test_helper'

class TwiliosControllerTest < ActionDispatch::IntegrationTest

	test 'should get a good response on parse path' do 
		post '/twilio/text', {Body: "911 I'm stuck on dagobah", 
			From: "+15122223333"}
		assert_response :success
	end

	test 'should send a reject message if the response to duplicate is not one of the options' do 
		#TODO set up the pending messages and employee status to prime it for message receipt
		# send wrong number to controller
		# look for outbound message that shows rejection notice
	end
end

#TODO add methods for parse case statements to see if the correct method gets called. 

