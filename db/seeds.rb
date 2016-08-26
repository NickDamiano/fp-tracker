# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
twilio_test_number = "15005550006"
twilio_number = Rails.application.secrets.twilio_number.to_s

employees = Employee.create([
	{ first_name: 'not in the system', in_saudi: true, permanent: true},
	{ first_name: 'twilio_app', last_name: "twilio_app", phone_num1: twilio_number, 
	phone_num2:  twilio_test_number},
	{ first_name: 'nick', last_name: 'damiano', phone_num1: "+15129944596", location: 'psab', 
		in_saudi: true, admin: true}
	])


