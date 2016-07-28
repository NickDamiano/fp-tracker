# require 'test_helper'
# require 'pry-byebug'

# class SmsTest < ActiveSupport::TestCase
	
# 	test "should build a text message" do 
# 		# Twilio provided number passes all validations for from
# 		from = "+15005550006"
# 		to = Employee.find_by(last_name: "fett", first_name: "jango").phone_num1
# 		body = "Hi Jango!."

# 		sms = SmsActions.compose_message(to, from, body)

# 		assert_equal "Sent from your Twilio trial account - " + body, sms.body
# 		assert_equal from, sms.from
# 		assert_equal to, sms.to
# 	end
# end