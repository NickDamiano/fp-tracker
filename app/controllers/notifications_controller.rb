class NotificationsController < ApplicationController

	skip_before_action :verify_authenticity_token

	def parse
		# log message to history
		p params["Body"]
		message = params["Body"]
		message.downcase!
		case message
		when /^911/
			p "It's an emergency"
		when /^sitrep/
			p "It's requesting sitrep"
		else
			p "It's a depart/arrive"
		end
		# case statement for 
		# emergency
		# mass distro message for TASS or for king air guys
		# SITREP reports on who is where. lists out location
			# followed by indented names 
		# LFG feature later
		# else it's a report for departing or arriving

	end




end