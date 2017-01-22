require 'minitest/autorun'
require 'test_helper'
require 'pry-byebug'

class MessageParserTest < ActiveSupport::TestCase

	test "switch statement works" do 
		Employee.stub :register_employee, ("register_employee") do 
			result = MessageParser.parse("register", "+15122223333")
			assert_equal result, "register_employee"
		end

		Employee.stub :unregister_employee, ("unregister_employee") do 
			result = MessageParser.parse("unregister", "+15122223333")
			assert_equal result, "unregister_employee"
		end

		Message.stub :report_emergency, ("report_emergency") do 
			result = MessageParser.parse("911", "+15122223333")
			assert_equal result, "report_emergency"
		end

		Message.stub :send_sitrep, ("send_sitrep") do 
			result = MessageParser.parse("sitrep", "+15122223333")
			assert_equal result, "send_sitrep"
		end

		MessageDepart.stub :store_departure, ("store_departure") do 
			result = MessageParser.parse("fett going to cloud city", "+15122223333")
			assert_equal result, "store_departure"
		end

		MessageArrive.stub :store_arrival, ("store_arrival") do 
			result = MessageParser.parse("arrived", "+15122223333")
			assert_equal result, "store_arrival"
		end

		Message.stub :give_instructions, ("give_instructions") do 
			result = MessageParser.parse("instructions", "+15122223333")
			assert_equal result, "give_instructions"
		end
	end
end

