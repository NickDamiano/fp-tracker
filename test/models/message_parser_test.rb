require 'test_helper'
require 'pry-byebug'

class MessageParserTest < ActiveSupport::TestCase
	# hit all parser possible actions
	register_mock = Minitest::Mock.new
	# save_mock = Minitest::Mock.new
	def register_mock.register_employee(number); nil; end

	Employee.stub :new, register_mock do 
		# MessageParser.parse("register", "5129603333")
		assert MessageParser.parse("register", "+15122223333")
	end

	assert_mock register_mock
end



