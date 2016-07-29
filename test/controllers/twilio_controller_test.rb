	
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

	test 'should get a good response on voice path' do 
		post '/twilio/voice'
		assert_response :success
	end
end