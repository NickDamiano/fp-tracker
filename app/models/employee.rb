class Employee < ActiveRecord::Base
	has_many :messages
end
