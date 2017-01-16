require 'test_helper'

class PersonnelControllerTest < ActionDispatch::IntegrationTest

	test 'should get all employees from the database' do 


	end

	test 'should get a good response for viewing personnel list' do 
		get '/'
		assert_response :success
	end

end

