require 'test_helper'
require 'pry-byebug'

class MessageTest < ActiveSupport::TestCase

   Twilio_number_test = "+15005550006"


   test "should get depart info from a depart text" do 
      message = "boba, jango, and jarjar going to naboo"

      result = MessageActions.get_depart_info(message)
      assert_equal ["boba", "jango", "jarjar"], result[:names]
      assert_equal "naboo", result[:to]
   end

   test 'should handle duplicates if there is one in text and multiples in country and
   the senders phone number matches the duplicate name' do
   #for example - if fett, solo, and skywalker are going somewhere and boba fett texts
   # the message, it should assume that boba fett is the fett in the message 
      # message = "fett and solo going to jabbas place"
      message = "fett, solo, and skywalker going to the death star"
      from = "+15126667778" #boba fett
      Message.store_departure(message, from)

      boba = Employee.find_by(first_name: "boba", last_name: "fett")

      assert_equal "driving to the death star", boba.location
   end

   test 'should handle duplicates in text if there is equal number in country' do 
      message = "fett, solo, and fett are going to naboo"
      sender = "+15126667778"

      Message.store_departure(message, sender)
      fetts = Employee.where(last_name: "fett")

      assert_equal "driving to naboo", fetts[0].location 
      assert_equal "driving to naboo", fetts[1].location 
   end

   test "should build a text message" do 
      # Twilio provided number passes all validations for from
      to = Employee.find_by(last_name: "fett", first_name: "jango").phone_num1
      body = "Hi Jango!."

      sms = Message.send_message(to, body)

      assert_equal "Sent from your Twilio trial account - " + body, sms.body
      assert_equal Twilio_number_test, sms.from
      assert_equal to, sms.to
   end

   test "should parse out names where more than one person has that name in the db" do 
      names = ["solo", "organa", "skywalker", "fett"]
      sender = "+15125556666" #han
      result = MessageActions.checkDuplicateLastName(names, sender)

      assert_equal "han", result[0]["first_name"]
      assert_equal "leia", result[1]["first_name"]
      assert_equal "luke", result[2]["first_name"]

      # add a duplicate name to the names above and assert that the dup location is same
   end

   test "should save a message with message and sender" do 
   	message = "skywalker, vader, and solo going to psab"
   	sender = "+15122223333"
   	saved_message = Message.save_message(message, sender)
   	assert saved_message.id
   	assert saved_message["from"], "+15122223333"
   end

   test "should store a departure" do
      message = "skywalker, vader, and solo going to al yamama"
      sender = "+15122223333"

      # Assert skywalker is at psab
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal luke["location"], "psab"
   	
      # Call method store_departure and it should change the location for employees
      # showing them in transit to that point, and create transit employee records
      Message.store_departure(message, sender)
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal "driving to al yamama", luke["location"]

      # Assert that there are three employees in transit (as sent by luke)
      transit_employee_count = TransitEmployee.where(sender: "+15122223333").count
      # 6 is expected because there are 3 hard-coded fixtures already
      assert_equal 6, transit_employee_count

   end

   test 'updateDatabaseArrive method' do 
      # test that vader is at psab
      vader = Employee.find_by(last_name: "vader")
      assert_equal "psab", vader["location"]

      # call updatedatabaseArrive to have have his location updated through
      # transit messages
      MessageActions.updateDatabaseArrive("+15122223333")
      assert_equal "dantooine", Employee.find_by(last_name: "vader").location
   end

   # when sender just puts "arrived"
   test 'should update database for short arrival' do 
      message = "arrived"
      sender = "+15122223333"
      Message.store_arrival(message, sender)

      assert_equal "dantooine", Employee.find_by(last_name: "vader").location
   end

   test 'parse_arrived_long method' do 
      # should take a message, parse out names and to location and return hash
      # {names: "leia, luke, chew, han", to: "the death star"}
      # should 
      message = "organa, skywalker, baca, and solo arrived at the death star"
      sender = "15125556666" #solo

      MessageActions.parse_arrived_long(message, sender)
      han = Employee.find_by(last_name: "solo")
      leia = Employee.find_by(last_name: "organa")
      luke = Employee.find_by(last_name: "skywalker")
      chew = Employee.find_by(last_name: "baca")

      assert_equal "the death star", han.location
      assert_equal "the death star", leia.location
      assert_equal "the death star", luke.location
      assert_equal "the death star", chew.location
   end

   # when sender sends a message like "luke, leia, and han arrived at the death star"
   test 'should update database for long arrival' do 
      # message_action
   end

   test "should parse names" do 
   	message = "skywalker, vader, and solo going to psab"
   	result = MessageActions.parse_names(message)
   	assert_equal ["skywalker", "vader", "solo"], result
   end

   test "should parse location to" do 
      message = "skywalker going to endor"
      result = MessageActions.parse_location_to(message)
      assert_equal result, "endor"
   end

   test 'Should forward the message to all personnel in saudi' do 

      message = "you did it kid, now let's go home!"
      sender = "+15005550006" # han solo
      initial_count = Message.count

      result = MessageActions.emergency(message, sender )
      final_count = Message.count

      assert_equal initial_count, final_count - 7
   end

end
