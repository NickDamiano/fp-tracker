require 'test_helper'

class TwiliosControllerTest < ActionDispatch::IntegrationTest

	test 'should get a good response on parse path' do 
		post '/twilio/text', {Body: "911 I'm stuck on dagobah", 
			From: "+15122223333"}
		assert_response :success
	end

end
# class NotificationsControllerTest < ActionController::Testcase
# 	test 'should parse 911 message' do 
# 		get :

