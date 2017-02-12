require 'test_helper'

class MessageArriveTest < ActiveSupport::TestCase 

	test 'update_database_arrive method' do 
      # test that vader is at psab
      vader = Employee.find_by(last_name: "vader")
      assert_equal "psab", vader["location"]

      # call updatedatabaseArrive to have have his location updated through
      # transit messages
      MessageArrive.update_database_arrive("+15122223333")
      assert_equal "dantooine", Employee.find_by(last_name: "vader").location
   end

   test "should send rejection message for short arrived message when no departure reported" do 
      sender = "+15123334444"

      MessageArrive.update_database_arrive(sender)

      assert_match /^No departure reported./, Message.last.body
    end

   # when sender just puts "arrived"
   test 'should update database for short arrival' do 
      message = "arrived"
      sender = "+15122223333"
      MessageArrive.store_arrival(message, sender)

      assert_equal "dantooine", Employee.find_by(last_name: "vader").location
   end

   test 'store arrival should call parse_arrived_long when needed' do 
      message = "kenobi, vader, and skywalker arrived at the death star"
      sender = "+15122223333"
      MessageArrive.stub :parse_arrived_long, "parse_arrived_long" do 
         result = MessageArrive.store_arrival(message, sender)
      end
   end

	test 'parse_arrived_long method' do 
      # should take a message, parse out names and to location and return hash
      # {names: "leia, luke, chew, han", to: "the death star"}
      # should 
      message = "kenobi, skywalker, baca, and solo arrived at the death star"
      sender = "+15125556666" #solo

      MessageArrive.parse_arrived_long(message, sender)
      han = Employee.find_by(last_name: "solo")
      obi = Employee.find_by(last_name: "kenobi")
      luke = Employee.find_by(last_name: "skywalker")
      chew = Employee.find_by(last_name: "baca")

      assert_equal "the death star", han.location
      assert_equal "the death star", obi.location
      assert_equal "the death star", luke.location
      assert_equal "the death star", chew.location
   end

end