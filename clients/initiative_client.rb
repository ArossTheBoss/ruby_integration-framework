require_relative 'http_base'
require 'faker'
require 'json'
require 'Date'

class InitiativeClient < HttpBase
	def initialize(session: nil, path: "api/direct/initiatives")
		super(session, path)
	end

	def initiative_data(initiative_duration=0, client_brand_id= "b9cf6cc6-7aa5-4e71-bcf6-152e70630ca", client_id= "f2e4d1b5-b46e-445f-a625-41610d69d8c6")
		names = Faker::Name.name
		num = Faker::Number.number(7)
		now = DateTime.now 
		data = {"name": names,
			"budget": num,
			"client_brand_id": client_brand_id,
			"client_id": client_id,
			"start_date": convert_date_to_s(now),
			"end_date": convert_date_to_s(now, initiative_duration)
		}
		return data
	end

	def convert_date_to_s(date, initiative_duration=0)
		date = DateTime.now + initiative_duration
		date.strftime("%Y-%m-%d")
	end


	def create_initiative(data: nil)
		payload = initiative_data()
		if data
			payload = data
		end
		response = self.post(payload: payload)
		response
	end

	def get_client_info()
		clients = self.get(path: "api/catalog/clients/search/")
	end

	def parse_client_info(results)
		x  = JSON.parse(results.body)
		puts x.keys
	end
end







