require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  test "should get depart info from a depart text" do 
      message = "boba, jango, and jarjar going to naboo"

      result = MessageDepart.get_depart_info(message)

      assert_equal ["boba", "jango", "jarjar"], result[:names]
      assert_equal "naboo", result[:to]
   end 

   test "should store a departure" do
      message = "skywalker, vader, and solo going to al yamama"
      sender = "+15122223333"

      # Assert skywalker is at psab
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal luke["location"], "psab"
   	
      # Call method store_departure and it should change the location for employees
      # showing them in transit to that point, and create transit employee records
      MessageDepart.store_departure(message, sender)
      luke = Employee.find_by(last_name: "skywalker")
      assert_equal "going to al yamama", luke["location"]

      # Assert that there are three employees in transit (as sent by luke)
      transit_employee_count = TransitEmployee.where(sender: "+15122223333").count
      # 6 is expected because there are 3 hard-coded fixtures already
      assert_equal 6, transit_employee_count
   end

   test 'should parse location for departing when to not present' do 
      message = "skywalker going dagobah"
      result = MessageDepart.parse_location_to(message)

      assert_equal "dagobah", result
   end

end