class MessageActions
	def self.depart
		puts 'message actions depart message called'
	end

	def self.arrive(message)
		puts "message action #{message} message called !!!!"
		puts 'fart'
	end

	def self.emergency
	end

	def self.sitrep
	end
end