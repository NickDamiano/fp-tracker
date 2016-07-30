require 'test_helper'

class TwiliosControllerTest < ActionDispatch::IntegrationTest

	test 'should get a good response on parse path' do 
		post '/twilio/text', {Body: "911 I'm stuck on dagobah", 
			From: "+15122223333"}
		assert_response :success
	end
end

#TODO add methods for parse case statements to see if the correct method gets called. 

