require 'test_helper'
require 'pry-byebug'

class MessageTest < ActiveSupport::TestCase

   Twilio_number_test = "+15005550006"

   test 'should send reject message' do 
      saved_message = Message.create(body: "some string", to:"+15122223333", from: 
         Twilio_number_test)
      Message.send_reject_message(saved_message, "5")

      assert_equal "5 is not one of the listed options. Please try again.", Message.last.body 
   end

   test "should send a text message with instructions" do 
      sender = "+15122223333"
      Message.give_instructions(sender)
      result = Message.where(to: sender).last.body

      assert_match /Departing/, result
      assert_match /Arriving/, result
      assert_match /Emergency/, result
   end

   test "should send a text message" do 
      # Twilio provided number passes all validations for from
      to = Employee.find_by(last_name: "fett", first_name: "jango").phone_num1
      body = "Hi Jango!."

      sms = Message.send_message(to, body)

      assert_equal body, sms.body
      assert_equal Twilio_number_test, sms.from
      assert_equal to, sms.to
   end

   test "should save a message with message and sender" do 
   	message = "skywalker, vader, and solo going to psab"
   	sender = "+15122223333"
   	saved_message = Message.save_message(message, sender)

   	assert saved_message.id
   	assert "+15122223333", saved_message["from"]
   end

   test "should parse names" do 
   	message = "skywalker, vader, and solo going to psab"
   	result = Message.parse_names(message)

   	assert_equal ["skywalker", "vader", "solo"], result
   end

   test "should parse location to" do 
      message = "skywalker going to endor"
      result = MessageDepart.parse_location_to(message)

      assert_equal "endor", result
   end

   test 'Should forward the message to all personnel in saudi' do 

      message = "you did it kid, now let's go home!"
      sender = "+15005550006" # han solo
      initial_count = Message.count
      number_in_country = Employee.where(in_country: true).count
      result = Message.report_emergency(message, sender )
      final_count = Message.count

      assert_equal initial_count, final_count - number_in_country
   end

   test 'should send a sitrep' do 
      luke = Employee.find_by(last_name: "skywalker")
      luke.location = "dagobah"
      luke.save
      number = luke.phone_num1

      Message.send_sitrep(number)
      last_message = Message.where(to: number).last
      
      assert_match "Skywalker, Luke: Dagobah", last_message.body
   end

   test 'should send rejection message for sitrep if not admin' do
      sender = "+15123334444" # Darth Vader is not an admin
      Message.send_sitrep(sender)
      last_message = Message.last

      assert_match "You need admin privledges to request a sitrep", last_message.body
   end

end
