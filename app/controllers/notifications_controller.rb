class NotificationsController < ApplicationController

	skip_before_action :verify_authenticity_token

	def parse
		#call this 
		p params["Body"]
	end

end