	
class TwiliosControllerTest < ActionDispatch::IntegrationTest
	test 'should update message status with callback status' do 
		initial_message = Message.create(messageSid: '1234', from: "15122223333", body: 'testing the ol twilio controller',
			status: 'webhook sent')
		assert_equal Message.find_by(messageSid: '1234').status, 'webhook sent'

		post '/twilio/callback', {MessageSid: '1234', MessageStatus: 'delivered'}
		assert_response :success

		final_message = Message.find_by(messageSid: '1234')
		assert_equal "delivered", final_message.status
	end

	test 'should notify admin if message fails to send' do 
		# # makme sure it doesn't do it for a failed one to admin so it doesn't go into an endless loop
  #     	to = "+15005550002" # invalid number
  #     	message = "this message shouldn't work"

  #     	result = Message.send_message(to, message) # sends out message, callback should hit

	end

	test 'should get a good response on voice path' do 
		post '/twilio/voice'
		assert_response :success
	end
end