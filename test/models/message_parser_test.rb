require 'minitest/autorun'
require 'test_helper'

# This tests the message parser which has a large case statement that parses a text using regex
#   to determine what the intent of the message is, then calls the appropriate method to handlee that
#   these tests mostly just test to make sure when a certain text comes in, the right method is called
#   these tests are not concerned with the return of the methods as the message parser class starts a sequence
#   of methods to handle the text rather than taking returns from methods. 
class MessageParserTest < ActiveSupport::TestCase

	test "case statement calls register employee" do 
		Employee.stub :register_employee, ("register_employee") do 
			result = MessageParser.parse("register", "+15122223333")
			assert_equal "register_employee", result
		end
	end

	test "case statement calls unregister_employee" do 

		Employee.stub :unregister_employee, ("unregister_employee") do 
			result = MessageParser.parse("unregister", "+15122223333")
			assert_equal "unregister_employee", result
		end
	end

	test "case statement calls report emergency" do 

		Message.stub :report_emergency, ("report_emergency") do 
			result = MessageParser.parse("911", "+15122223333")
			assert_equal "report_emergency", result
		end

	end

	test "case statement calls send sitrep" do 

		Message.stub :send_sitrep, ("send_sitrep") do 
			result = MessageParser.parse("sitrep", "+15122223333")
			assert_equal "send_sitrep", result
		end

	end

	test "case statement calls store departure" do 

		MessageDepart.stub :store_departure, ("store_departure") do 
			result = MessageParser.parse("fett going to cloud city", "+15122223333")
			assert_equal "store_departure", result
		end

	end

	test "case statement calls store arrival" do 

		MessageArrive.stub :store_arrival, ("store_arrival") do 
			result = MessageParser.parse("arrived", "+15122223333")
			assert_equal "store_arrival", result
		end

	end

	test "case statement calls give instructions" do 

		Message.stub :give_instructions, ("give_instructions") do 
			result = MessageParser.parse("instructions", "+15122223333")
			assert_equal "give_instructions", result
		end

	end

	test "case statement calls duplicate message responder" do 
		sender = "+15122223333"
		DuplicateMessageAction.stub :duplicate_message_responder, "duplicate_message_responder" do
			Message.create(to: sender, pending_response: true, body: "message" )
			result = MessageParser.parse("1", sender)
			assert_equal "duplicate_message_responder", result
		end

	end

	test "rejection message sent when not registered" do 
		sender = "+19013224949"
		MessageParser.parse("Yub Nub", sender)

		assert_match /^You are not registered/, Message.last.body
		refute Employee.find_by(phone_num1: sender)
	end

	test "Test that parse registration is called when a follow up " do 
		sender = "+19013224949"
		# Create employee to get past first part of registration
		Employee.create(phone_num1: sender)

		Message.create(to: sender, body: "Registration: ")

		Employee.stub :parse_registration, ("parse_registration") do
			result = MessageParser.parse("fisto", sender)
			assert_equal "parse_registration", result
		end
	end

	test "rejection message sent when unparsable message from existing user" do 
		MessageParser.parse("yub nub", "+15122223333")
		last_message = Message.last.body
		assert_match /^I didn't understand your message/, last_message
	end
end

