require 'test_helper'

class MessageTest < ActiveSupport::TestCase
   test "the truth" do
     assert true
   end


   test "should save a message" do 
   	message = Message.create(from: "123", body: "test message buddy")
   	assert message.save
   	mes = Message.find_by(from: "123")
   	assert_equal message, mes
   end
end
