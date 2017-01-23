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

      # create user
      # call method to unregister
      # verify they were deleted
      # verify correct message
   end

   test "should let user know when deregistration fails" do 
      # no idea how to test this
   end

end
