require_relative 'http_base'
require 'faker'
require 'json'
require 'Date'

class InitiativeClient < HttpBase
	def initialize(session: nil, path: 'api/direct/initiatives')
		super(session, path)
	end

	def initiative_data(initiative_duration: 0, client_brand_id: 'b9cf6cc6-7aa5-4e71-bcf6-152e70630ca', client_id: 'f2e4d1b5-b46e-445f-a625-41610d69d8c6')
		names = 'Test-Initiative-' + DateTime.now.to_s
		num = Faker::Number.number(7)
		now = DateTime.now 
		data = {'name': names,
			'budget': num,
			'client_brand_id': client_brand_id,
			'client_id': client_id,
			'start_date': convert_date_to_s(now),
			'end_date': convert_date_to_s(now, initiative_duration: initiative_duration)
		}
		return data
	end

	def convert_date_to_s(date, initiative_duration:0)
		d = DateTime.now 
		if date
			d = date + initiative_duration
		end
		d.strftime('%Y-%m-%d')
	end


	def create_initiative(data: nil)
		payload = initiative_data()
		if data
			payload = data
		end
		response = self.post(payload: payload)
		# self.restrict_users
		response
	end

	def get_client_info
		page = 0
		last_page = false
		results = nil
	
		while last_page != true do
			result = self.get(path: "api/catalog/clients/search?page=#{page}")
			last_page = result['meta']['last_page']
			page +=1
			results = result
		end
		results
	end

	def restrict_users
		self.put(path:'/api/catalog/clients/b42e31d7-997a-48be-9e38-2867931cf5bb/restrict_client_users')
	end
end







