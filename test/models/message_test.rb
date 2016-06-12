require 'test_helper'

class MessageTest < ActiveSupport::TestCase
   # test "the truth" do
   #   assert true
   # end


   # test "should save a message" do 
   # 	message = Message.create(from: "123", body: "test message buddy")
   # 	assert message.save
   # 	mes = Message.find_by(from: "123")
   # 	assert_equal message, mes
   # end

   test "should save a message with message and sender" do 
   	message = "skywalker, vader, and solo going to psab"
   	sender = "1112223333"
   	saved_message = Message.save_message(message, sender)
   	assert saved_message.id
   	assert saved_message["from"], "1112223333"
   end

   # test "should store a departure" do
   # 	message = "skywalker, vader, and solo going to psab"
   # 	sender = "1112223333"

   # end

   test "should parse names" do 
   	message = "skywalker, vader, and solo going to psab"
   	result = MessageActions.parse_names(message)
   	assert_equal ["skywalker", "vader", "solo"], result
   end

   test "should parse location to" do 
      message = "skywalker going to endor"
      result = MessageActions.parse_location_to(message)
      assert "endor", result
   end
end
