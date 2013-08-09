SupporterDonatedNotification = "Supporter#Donated"

class Supporter
	PERSISTENCE_KEY = 'our_beloved_supporter'

	def self.is?
		k = App::Persistence[PERSISTENCE_KEY]
		k && k.to_i > 0
	end

	def self.multi?
		App::Persistence[PERSISTENCE_KEY].to_i > 1
	end

	def self.set
		Dispatch::Queue.concurrent.async do
			App::Persistence[PERSISTENCE_KEY] = App::Persistence[PERSISTENCE_KEY].to_i + 1
			SupporterDonatedNotification.post_notification
		end
	end
end
