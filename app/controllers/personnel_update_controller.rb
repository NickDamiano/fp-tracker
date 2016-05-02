class PersonnelUpdateController < ApplicationController
  def depart
  	# receives text indicating departure from somewhere, parses text,
  	# updates database, and sends response text
  end

  def arrive
  	# receives text indicating arrival to somewhere, parses, updates, and responds
  end

  def alert
  	# sends alert to those who have indicated they need to know when this changes
  	# possibly invoked by others or should this be a model method?
  end
end
