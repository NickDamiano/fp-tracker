require 'test_helper'

class DuplicateMessageActionTest < ActiveSupport::TestCase 

	# organa and fett have more than one entry in db. should get solo and skywalker
	test "should parse out names where more than one person has that name in the db" do 
      names = ["solo", "organa", "skywalker", "fett"]
      sender = "+15125556666" #han
      destination = "dagobah"
      result = DuplicateMessageAction.check_duplicate_last_name(names, sender, destination)

      assert_equal "han", result[0]["first_name"]
      assert_equal "luke", result[1]["first_name"]   
    end

    test "should send rejection message if name not in database" do 
    	message = "solo and porkins going to the death star"
    	MessageDepart.store_departure(message, "+15125556666")

    	assert Message.find_by(body: "porkins was not found. Please check your spelling" \
    		" or contact your system administrator.")
    end

    test 'should respond to duplicate response with duplicate_message_responder method' do 
	  # takes original message - the one sent by twilio asking which duplicate
	  # takes the response message that is a number or series of numbers 
	     # identifying which duplicate
	  # calls update_database_depart with the array of employee objects, destination
	     # and sender of original text report. This in turn updates the database
	     # with transit employees and Employee.location
	  sender = "+15129998888"
	  employee = Employee.find_by(phone_num1: sender )
	  employee.messages.create(from: sender, body: "organa going to hoth")
	  original_message = Message.create(from: "+15005550006", to: sender, 
	     body:  "Which organa did you mean?\n1. Leia Organa\n2. Bail Organa\n\nRespond with the corresponding number", 
	     employee_id: 9, pending_response: true,
	     location: "hoth")

	  response_message = "2"

	  result = DuplicateMessageAction.duplicate_message_responder(original_message, response_message)
	  bail = Employee.find_by(first_name: "bail")
	  transit_employee = TransitEmployee.find_by(employee_id: 11)

	  assert_equal "going to hoth", bail.location
	  assert transit_employee 
	  refute original_message.pending_response
	end

    test 'should handle duplicates for long arrival' do 
    	sender = "+15122223333"
    	employee = Employee.find_by(phone_num1: sender)
    	# create the senders message pulled half-way through test method
    	employee.messages.create(from: sender, body: "skywalker and fett arrived at dagobah")

    	original_message = Message.create(body: "Which fett do you mean?\n1. Jango Fett\n2. Boba Fett\n\nRespond with the corresponding number ",
    		to: sender, pending_response: true, location: "dagobah")
    	response = "1"
    	DuplicateMessageAction.duplicate_message_responder(original_message, response)
    	refute original_message.pending_response
    end

    test 'should handle two groups of duplicates with 1 duplicate and two duplicates' do 
    	duplicates = ["organa", "fett"]  
    	sender = "+15122223333"
    	destination = "hoth"

    	DuplicateMessageAction.handle_duplicates(duplicates, sender, destination)

    	assert_match /^Which organa/, Message.last.body
    	assert_match /^Which fett/, Message.find_by(status: "pending").body
	end

	test 'should send rejection message if duplicate response is incorrect' do 
    	duplicates = ["organa", "fett"]  
    	sender = "+15122223333"
    	destination = "hoth"

    	DuplicateMessageAction.handle_duplicates(duplicates, sender, destination)

    	original_message = Message.where(to: sender, pending_response: true).last
    	message = "5"
    	DuplicateMessageAction.duplicate_message_responder(original_message, message)

    	assert_match /5 is not one of the listed options/, Message.last.body

	end

	test 'should handle duplicates if there is one in text and multiples in country and
	the senders phone number matches the duplicate name' do
	#for example - if fett, solo, and skywalker are going somewhere and boba fett texts
	# the message, it should assume that boba fett is the fett in the message 
	  # message = "fett and solo going to jabbas place"
	  message = "fett, solo, and skywalker going to the death star"
	  from = "+15126667778" #boba fett
	  MessageDepart.store_departure(message, from)

	  boba = Employee.find_by(first_name: "boba", last_name: "fett")

	  assert_equal "going to the death star", boba.location
	end

	test 'should handle duplicates in text if there is equal number in country' do 
	  message = "organa, solo, and organa are going to naboo"
	  sender = "+15126667777" # Leia

	  MessageDepart.store_departure(message, sender)
	  organas = Employee.where(last_name: "organa")

	  assert_equal "going to naboo", organas[0].location 
	  assert_equal "going to naboo", organas[1].location 
	end

	test 'should handle duplicates when equal number in text as in database' do 
	  duplicates = ["organa", "organa"]
	  sender = "+15129998890"
	  destination = "coruscant"
	  # returns an array of objects for the employees - normally passed back to checkDuplicates
	  results = DuplicateMessageAction.handle_duplicates(duplicates, sender, destination)
	  organas = Employee.where(last_name: "organa")
	  # Should return an array of active record objects for each organa. 
	  assert_equal organas, results
	end

	test 'should handle duplicates when the only name in the text message is the duplicate' do 
	  duplicates = ["organa"] #bail
	  sender = "+15129998890" # bail
	  destination = "not alderaan"

	  result = DuplicateMessageAction.handle_duplicates(duplicates, sender, destination)
	  organa = Employee.where(last_name: "organa", first_name: "bail")
	  # should return an array with one active record object matching bail organa
	  assert_equal organa, result
	end

	test 'should handle one duplicate when there are more in db than in message by '\
	'sending a text with selection information' do 
	  duplicates = ["organa"] # bail/leia
	  sender = "+15129998889" # harry fett!
	  destination = "hoth"

	  message = Message.find_by(pending_response: true)
	  assert_nil message

	  DuplicateMessageAction.handle_duplicates(duplicates, sender, destination)
	  message = Message.find_by(pending_response: true)
	  refute_nil message
	end
end