require 'test_helper'
require 'pry-byebug'

class EmployeeTest < ActiveSupport::TestCase

	test "should create a new employee record by phone number" do 
		sender = "+15122223396"
		Employee.register_employee(sender)

		assert Employee.find_by(phone_num1: sender)
		assert "Please send me your first name for registration", Message.last.body
	end

	test "should notify user if number already exists in database during registration" do 
      	sender = "+15122223333" # Number already exists
		Employee.register_employee(sender)

		assert_equal 1, Employee.where(phone_num1: sender).size
		assert "Your phone number already exists in the database", Message.last.body
   end

   test "should unregister and delete user upon their request" do
   		Employee.create(first_name: "poe", last_name: "dameron", phone_num1: "+15129919343")

   		assert Employee.find_by(last_name: "dameron")

   		Employee.unregister_employee("+15129919343")

   		refute Employee.find_by(phone_num1: "+15129919343")
   end

   test "should parse registration response and send correct follow-up message" do 
   		sender = "+15122223399"
   		employee = Employee.create(phone_num1: sender)
   		message = Message.send_message(sender, "Registration: Please send your first name")
   		Employee.parse_registration("biggs", sender, message)

   		assert_equal "biggs", Employee.find_by(phone_num1: sender).first_name
   		assert_match /last name/, Message.last.body

   		message = Message.last
   		Employee.parse_registration("darklighter", sender, message)

   		assert_equal "darklighter", Employee.find_by(phone_num1: sender).last_name
   		assert_match /location/, Message.last.body

   		message = Message.last
   		Employee.parse_registration("mos eisley", sender, message)

   		assert_equal "mos eisley", Employee.find_by(phone_num1: sender).location
   		assert_match /Registration Complete/, Message.last.body
   end

   test "should filter out suspicious characters from text message " do 
   end

end
