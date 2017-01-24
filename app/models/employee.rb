require 'pry-byebug'

class Employee < ActiveRecord::Base
	has_many :messages

	def self.register_employee(sender)
		# send a message to get last name
		begin
			employee = Employee.create(phone_num1: sender)
		rescue ActiveRecord::RecordNotUnique
			employee = nil
		end
		if employee 
			message = "Please send me your first name for registration"
		else
			message = "Your phone number already exists in the database"
		end
		Message.send_message(sender, message)
	end

	def self.unregister_employee(sender)
		#no confirmation needed just remove them
		Employee.find_by(phone_num1: sender).delete
		employee = Employee.find_by(phone_num1: sender)
		if employee.nil?
			message = "You have been successfully deleted from the database."
		elsif employee
			message = "There was a problem deleting you from the database."
		end
		Message.send_message(sender, message)
	end
	
	# Message is reply from user containing either first or last name, or location
	# sender is the person we are requesting info from, 
	# original message is the message we sent asking for the information in message (message class)
	def self.parse_registration(message, sender, original_message)
		employee = Employee.find_by(phone_num1: sender)
		if original_message.body =~ /first/
			employee.first_name = message
			Message.send_message(sender, "Registration: Please send your last name")
		elsif original_message.body =~ /last/
			employee.last_name = message 
			Message.send_message(sender, "Registration: Please send your location (alderaan, 
				home, Prince Sultan Air Base, etc")
		elsif original_message.body =~ /location/
			employee.location = message 
			Message.send_message(sender, "Registration Complete: #{employee.first_name} 
				#{employee.last_name} located at #{employee.location}")
			set_admin(sender)
		end
		employee.save
	end

	# THIS METHOD ONLY EXISTS FOR DEMO PURPOSES FOR PEOPLE TO TRY OUT THE APP. DELETE
	# ON ACTUAL APP IF EVER USED BY REAL COMPANY.
	def self.set_admin(sender)
		employee = Employee.find_by(phone_num1: sender)
		employee.admin = true
		employee.save
	end
end
