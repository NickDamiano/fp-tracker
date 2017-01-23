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
   		# send a message asking for "first name for registration" and store into "original_message"
   		# call parse registration with first name, sender number, and "original_message"
   		# find user by sender number and save into user
   		# assert user has the same first name as passed
   		# assert that Message.last has the follow up question for last name

   		# call parse registration with last_name, sender, and Message.last
   		# find user by sender and save into user
   		# assert user has last name same as what was sent
   		# assert that Message.last has follow up for location

   		# call parse registration with location, sender, and Message.last
   		# find user and save into variable
   		# assert user has location same as sent
   		# assert that registration successful message has been sent
   end

end
