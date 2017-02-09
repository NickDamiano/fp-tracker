require 'minitest/autorun'
require 'test_helper'

class MessageParserTest < ActiveSupport::TestCase

	test "case statement calls register employee" do 
		Employee.stub :register_employee, ("register_employee") do 
			result = MessageParser.parse("register", "+15122223333")
			assert_equal result, "register_employee"
		end
	end

	test "case statement calls unregister_employee" do 

		Employee.stub :unregister_employee, ("unregister_employee") do 
			result = MessageParser.parse("unregister", "+15122223333")
			assert_equal result, "unregister_employee"
		end
	end

	test "case statement calls report emergency" do 

		Message.stub :report_emergency, ("report_emergency") do 
			result = MessageParser.parse("911", "+15122223333")
			assert_equal result, "report_emergency"
		end

	end

	test "case statement calls send sitrep" do 

		Message.stub :send_sitrep, ("send_sitrep") do 
			result = MessageParser.parse("sitrep", "+15122223333")
			assert_equal result, "send_sitrep"
		end

	end

	test "case statement calls store departure" do 

		MessageDepart.stub :store_departure, ("store_departure") do 
			result = MessageParser.parse("fett going to cloud city", "+15122223333")
			assert_equal result, "store_departure"
		end

	end

	test "case statement calls store arrival" do 

		MessageArrive.stub :store_arrival, ("store_arrival") do 
			result = MessageParser.parse("arrived", "+15122223333")
			assert_equal result, "store_arrival"
		end

	end

	test "case statement calls give instructions" do 

		Message.stub :give_instructions, ("give_instructions") do 
			result = MessageParser.parse("instructions", "+15122223333")
			assert_equal result, "give_instructions"
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
			assert_equal result, "parse_registration"
		end
	end

	test "rejection message sent when unparsable message from existing user" do 
		MessageParser.parse("yub nub", "+15122223333")
		last_message = Message.last.body
		assert_match /^I didn't understand your message/, last_message
	end
end

