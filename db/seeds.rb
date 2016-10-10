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
	{ first_name: 'not in the system', in_country: true, permanent: true},
	{ first_name: 'twilio_app', last_name: "twilio_app", phone_num1: twilio_number, 
	phone_num2:  twilio_test_number},
	{ first_name: 'nick', last_name: 'damiano', phone_num1: "+15129944596", location: 'psab', 
		in_country: true, admin: true},
	{ first_name: 'anakin', last_name: 'skywalker', phone_num1: "+15121112222", location: 'naboo', 
		in_country: true, admin: false},
	{ first_name: 'jarjar', last_name: 'binks', phone_num1: "+15121113333", location: 'naboo', 
		in_country: true, admin: false},
	{ first_name: 'r2', last_name: 'd2', phone_num1: "+15121114444", location: 'naboo', 
		in_country: true, admin: false},
	{ first_name: 'sheev', last_name: 'palpatine', phone_num1: "+15121115555", location: 'naboo', 
		in_country: true, admin: false},
	{ first_name: 'padme', last_name: 'amidala', phone_num1: "+15121116666", location: 'psab', 
		in_country: true, admin: false},
	{ first_name: 'sand', last_name: 'everywhere', phone_num1: "+15121117777", location: 'naboo', 
		in_country: true, admin: false},
	{ first_name: 'quigon', last_name: 'jin', phone_num1: "+15121118888", location: 'naboo', 
		in_country: true, admin: false},
	{ first_name: 'cornelius', last_name: 'crumb', phone_num1: "+15121119999", location: 'tatooine', 
		in_country: true, admin: false},
	{ first_name: 'jabba the', last_name: 'hutt', phone_num1: "+15121110000", location: 'tatooine', 
		in_country: true, admin: false},
	{ first_name: 'jawa', last_name: 'mcjawerson', phone_num1: "+15123334444", location: 'tatooine', 
		in_country: true, admin: false},
	{ first_name: 'shmi', last_name: 'skywalker', phone_num1: "+15123335555", location: 'tatooine', 
		in_country: true, admin: false},
	{ first_name: 'owen', last_name: 'lars', phone_num1: "+15123336666", location: 'tatooine', 
		in_country: true, admin: false},
	{ first_name: 'beru', last_name: 'whitesun', phone_num1: "+15123337777", location: 'tatooine', 
		in_country: true, admin: false},
	{ first_name: 'boba', last_name: 'fett', phone_num1: "+15123338888", location: 'kamino', 
		in_country: true, admin: false},
	{ first_name: 'jango', last_name: 'fett', phone_num1: "+15123339999", location: 'kamino', 
		in_country: true, admin: false},
	{ first_name: 'cad', last_name: 'bane', phone_num1: "+15123330000", location: 'bespin', 
		in_country: true, admin: false},
	{ first_name: 'darth', last_name: 'bane', phone_num1: "+15124445555", location: 'kashykk', 
		in_country: true, admin: false},
	{ first_name: 'luke', last_name: 'skywalker', phone_num1: "+15124446666", location: 'tatooine', 
		in_country: true, admin: false}

	])


