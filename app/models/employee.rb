class Employee < ActiveRecord::Base
	has_many :messages

	# needs test
	def self.register_employee(sender)
		# send a message to get last name
		message = Employee.create(phone_num1: sender).valid? ? "Please send me your first name for\
		 registration" : message = "Your phone number already exists in the database"
		Message.send_message(sender, message)
	end

	# needs test
	def self.unregister_employee(sender)
		#no confirmation needed just remove them
		Employee.find_by(phone_num1: sender).delete.
		message = Employee.find_by(phone_num1: sender).nil? ? "You have been successfully deleted from\
		 the database." : "There was a problem deleting you from the database."
		Message.send_message(sender, message)
	end
	
end
