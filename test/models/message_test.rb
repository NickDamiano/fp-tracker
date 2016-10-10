require 'test_helper'
require 'pry-byebug'

class MessageTest < ActiveSupport::TestCase

   Twilio_number_test = "+15005550006"

   test 'should send an update message to user when database is updated with a change' do 
      # send the message with a quick update 
      # database should update and code should run sending out message to user saying the change was made
      # pull out the last message and assert that it's updating that change. 
   end

   test "should get depart info from a depart text" do 
      message = "boba, jango, and jarjar going to naboo"

      result = MessageActions.get_depart_info(message)
      assert_equal ["boba", "jango", "jarjar"], result[:names]
      assert_equal "naboo", result[:to]
   end

   test "should build a text message" do 
      # Twilio provided number passes all validations for from
      to = Employee.find_by(last_name: "fett", first_name: "jango").phone_num1
      body = "Hi Jango!."

      sms = Message.send_message(to, body)

      assert_equal body, sms.body
      assert_equal Twilio_number_test, sms.from
      assert_equal to, sms.to
   end

   test "should save a message with message and sender" do 
   	message = "skywalker, vader, and solo going to psab"
   	sender = "+15122223333"
   	saved_message = Message.save_message(message, sender)
   	assert saved_message.id
   	assert saved_message["from"], "+15122223333"
   end

   test "should store a departure" do
      message = "skywalker, vader, and solo going to al yamama"
      sender = "+15122223333"

      # Assert skywalker is at psab
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal luke["location"], "psab"
   	
      # Call method store_departure and it should change the location for employees
      # showing them in transit to that point, and create transit employee records
      Message.store_departure(message, sender)
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal "going to al yamama", luke["location"]

      # Assert that there are three employees in transit (as sent by luke)
      transit_employee_count = TransitEmployee.where(sender: "+15122223333").count
      # 6 is expected because there are 3 hard-coded fixtures already
      assert_equal 6, transit_employee_count

   end

   test 'updateDatabaseArrive method' do 
      # test that vader is at psab
      vader = Employee.find_by(last_name: "vader")
      assert_equal "psab", vader["location"]

      # call updatedatabaseArrive to have have his location updated through
      # transit messages
      MessageActions.updateDatabaseArrive("+15122223333")
      assert_equal "dantooine", Employee.find_by(last_name: "vader").location
   end

   # when sender just puts "arrived"
   test 'should update database for short arrival' do 
      message = "arrived"
      sender = "+15122223333"
      Message.store_arrival(message, sender)

      assert_equal "dantooine", Employee.find_by(last_name: "vader").location
   end

   test 'parse_arrived_long method' do 
      # should take a message, parse out names and to location and return hash
      # {names: "leia, luke, chew, han", to: "the death star"}
      # should 
      message = "kenobi, skywalker, baca, and solo arrived at the death star"
      sender = "+15125556666" #solo

      MessageActions.parse_arrived_long(message, sender)
      han = Employee.find_by(last_name: "solo")
      obi = Employee.find_by(last_name: "kenobi")
      luke = Employee.find_by(last_name: "skywalker")
      chew = Employee.find_by(last_name: "baca")

      assert_equal "the death star", han.location
      assert_equal "the death star", obi.location
      assert_equal "the death star", luke.location
      assert_equal "the death star", chew.location
   end

   # when sender sends a message like "luke, leia, and han arrived at the death star"
   test 'should update database for long arrival' do 
      # message_action
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

   test 'Should forward the message to all personnel in saudi' do 

      message = "you did it kid, now let's go home!"
      sender = "+15005550006" # han solo
      initial_count = Message.count
      # Gets all personnel in saudi
      number_in_saudi = Employee.where(in_saudi: true).count
      result = MessageActions.emergency(message, sender )

      final_count = Message.count

      assert_equal initial_count, final_count - number_in_saudi
   end

   ################### Duplicate checker tests below #######################
   #########################################################################

   # organa and fett have more than one entry in db. should get solo and skywalker
   test "should parse out names where more than one person has that name in the db" do 
      names = ["solo", "organa", "skywalker", "fett"]
      sender = "+15125556666" #han
      destination = "dagobah"
      result = MessageActions.checkDuplicateLastName(names, sender, destination)

      assert_equal "han", result[0]["first_name"]
      assert_equal "luke", result[1]["first_name"]

   end

   test 'should handle duplicates if there is one in text and multiples in country and
   the senders phone number matches the duplicate name' do
   #for example - if fett, solo, and skywalker are going somewhere and boba fett texts
   # the message, it should assume that boba fett is the fett in the message 
      # message = "fett and solo going to jabbas place"
      message = "fett, solo, and skywalker going to the death star"
      from = "+15126667778" #boba fett
      Message.store_departure(message, from)

      boba = Employee.find_by(first_name: "boba", last_name: "fett")

      assert_equal "going to the death star", boba.location
   end

   test 'should handle duplicates in text if there is equal number in country' do 
      message = "organa, solo, and organa are going to naboo"
      sender = "+15126667777" # Leia

      Message.store_departure(message, sender)
      organas = Employee.where(last_name: "organa")

      assert_equal "going to naboo", organas[0].location 
      assert_equal "going to naboo", organas[1].location 
   end

   test 'should handle duplicates when equal number in text as in database' do 
      duplicates = ["organa", "organa"]
      sender = "+15129998890"
      destination = "coruscant"
      # returns an array of objects for the employees - normally passed back to checkDuplicates
      results = MessageActions.handle_duplicates(duplicates, sender, destination)
      organas = Employee.where(last_name: "organa")
      # Should return an array of active record objects for each organa. 
      assert_equal organas, results
   end

   test 'should handle duplicates when the only name in the text message is the duplicate' do 
      duplicates = ["organa"] #bail
      sender = "+15129998890" # bail
      destination = "not alderaan"

      result = MessageActions.handle_duplicates(duplicates, sender, destination)
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

      MessageActions.handle_duplicates(duplicates, sender, destination)
      message = Message.find_by(pending_response: true)
      refute_nil message
   end

   test 'should handle two groups of duplicates with 1 duplicate and two duplicates' do 
      duplicates = ["organa", "fett"]
      # this is going to have to work differently. It can send out two seprate query messages
      # and assign something to keep track of which response is for which (probably not)
      # or it can put the other one in a queue and as soon as the first is answered it sends
      # the second in the queue. and so on. OR it can put them all in one message and sort out
      # the answers
   end

   test 'should handle a text with 2 multiples in text and more than 2 in database' do 
      duplicates = ["fett", "fett"]
      # somehow we need to handle if there are two or more names and a greater number in 
         # the database, so fett and fett and skywalker, it should group the fetts and expect
         # two numbers
      # if size of duplicates is 1, send the normal process
      # otherwise, if it's greater than 1 and the set queue true on the sender's number 
         # send the first message
         # for remaining messages, create messages for messageQueue
      # when a message reply comes from the sender, handle the response but at the end, if
      # there are still message queues, grab the oldest and send the next one, if not, set the 
      # message queue flag to false

   end

   test 'should respond to a text with which personnel for more than 1 personnel and update database' do 
   end

   test 'should send duplicate message via duplicate_message_sender method' do 
      # Takes the name that needs to be resolved, the sender of the original
         # report, and destination
      # composes the text message that is sent out listing the people it could be
      # Saves the message with the location
      skip("TODO below needs to be completely rewritten because method has radically")
      name = "fett"
      sender = Employee.find_by(phone_num1: "+15129998888")
      destination = "that water planet with the jumping bird-whale things"

      message = Message.find_by(pending_response: true)
      assert_nil message

      MessageActions.duplicate_message_builder(name, sender, destination)
      message = Message.find_by(pending_response: true)
      refute_nil message
   end

   test 'should send a sitrep' do 
      luke = Employee.find_by(last_name: "skywalker")
      luke.location = "dagobah"
      luke.save
      number = luke.phone_num1

      Message.send_sitrep(number)
      last_message = Message.where(to: number).last
      
      assert_match "Skywalker, Luke: Dagobah", last_message.body
   end

   test 'should respond to duplicate response with duplicate_message_responder method' do 
      # takes original message - the one sent by twilio asking which duplicate
      # takes the response message that is a number or series of numbers 
         # identifying which duplicate
      # calls updateDatabaseDepart with the array of employee objects, destination
         # and sender of original text report. This in turn updates the database
         # with transit employees and Employee.location
      original_message = Message.create(from: "+15005550006", to: "+15129998888", 
         body:  "Which organa did you mean?\n1. Leia Organa\n2. Bail Organa\n\nRespond with the corresponding number", 
         employee_id: 9, pending_response: true,
         location: "hoth")

      response_message = "2"

      result = MessageActions.duplicate_message_responder(original_message, response_message)
      bail = Employee.find_by(first_name: "bail")
      assert_equal "going to hoth", bail.location
   end


end
