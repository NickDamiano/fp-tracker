require 'test_helper'
require 'pry-byebug'

class MessageTest < ActiveSupport::TestCase

   test "should save a message with message and sender" do 
   	message = "skywalker, vader, and solo going to psab"
   	sender = "1112223333"
   	saved_message = Message.save_message(message, sender)
   	assert saved_message.id
   	assert saved_message["from"], "1112223333"
   end

   test "should store a departure" do
      message = "skywalker, vader, and solo going to al yamama"
      sender = "1112223333"

      # Assert skywalker is at psab
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal luke["location"], "psab"
   	
      # Call method store_departure and it should change the location for employees
      # showing them in transit to that point, and create transit employee records
      Message.store_departure(message, sender)
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal "driving to al yamama", luke["location"]

      # Assert that there are three employees in transit (as sent by luke)
      transit_employee_count = TransitEmployee.where(sender: "1112223333").count
      # 6 is expected because there are 3 hard-coded fixtures already
      assert_equal 6, transit_employee_count

   end

   test 'updateDatabaseArrive method' do 
      # test that vader is at psab
      vader = Employee.find_by(last_name: "vader")
      assert_equal "psab", vader["location"]

      # call updatedatabaseArrive to have have his location updated through
      # transit messages
      MessageActions.updateDatabaseArrive("1112223333")
      assert_equal "dantooine", Employee.find_by(last_name: "vader").location
   end

   test 'should update database for short arrival' do 
      message = "arrived"
      sender = "1112223333"
      Message.store_arrival(message, sender)

      assert_equal "dantooine", Employee.find_by(last_name: "vader").location

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

   test "should parse arrived location when simply 'arrived' " do
      message = "arrived"
      sender = Employee.find_by(first_name: "luke")
      p 'test'
   end

end







   # test "should store short arrival" do 
   #    # Note, two messages are saved in database under luke id 
   #       # The first message shows him leaving to dantooine, the second shows arrived
   #       # Those two messages would have been created by controller and the tested method
   #       # for short arrival looks up the second to the last message to see where they were
   #       # going. 
   #    message = "skywalker, vader, and solo going to dantooine"
   #    sender = "1112223333"
   #    sender_id = Employee.find_by(phone_num1: sender).id

   #    # Assert skywalker is at psab
   #    luke = Employee.find_by(last_name: "skywalker")
   #    assert_equal "psab", luke["location"]

   #    # store arrival
   #    arrived_message = "arrived"
   #    Message.store_arrival(arrived_message, sender)

   #    # check to see if arrival is done
   #    luke = Employee.find_by(last_name: "skywalker")
   #    assert_equal "dantooine", luke["location"]

   # end


   # test "should save a message" do 
   #  message = Message.create(from: "123", body: "test message buddy")
   #  assert message.save
   #  mes = Message.find_by(from: "123")
   #  assert_equal message, mes
   # end
