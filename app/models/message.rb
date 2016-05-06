class Message < ActiveRecord::Base
	belongs_to :employee

	def store_message(names, location_from, location_to)
		#loop through names array
			# Find record by last name. if more than one result is
				# returned, implenet duplicate method to send follow-up
				# text
			#if record is only 1 result found update status transit to location
			#if not found, regex it to see a similar name and send follow-up
			

	end
end
