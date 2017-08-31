require_relative 'http_base'
require 'faker'
require 'json'
require 'pry'
require 'date'

class ClientAndBrandClient < HttpBase

	def initialize(session: nil, path: 'api/catalog/clients')
		super(session, path)
	end

	def data(brand_id: nil)
		brand_ids =[]
	
		data = {'name': 'Test-Client-' + DateTime.now.to_s,
				'notes': 'Test Client',
				'billing_address_attributes': {
					'address1': Faker::Address.street_name,
					'country': 'United States',
					'city': 'Wheeling',
					'state': 'Illinois',
					'postal_code': '60089'
				},
				'brand_ids': brand_ids.push(brand_id),
				'billing_codes_attributes': [],
				'billing_name': 'Aross',
				'restricted_access': true,
				'contact_first_name': 'Alex',
				'contact_last_name': 'Ross',
				'contact_email': 'alex.ross@testemail.com',
				'contact_phone': 1111111111,
				'contact_extension': '000'}
	end


	def get_valid_brands(first_brand_id_only: false)
		response = self.get(path: 'api/catalog/brands/search/')

	   
		if first_brand_id_only
			return response['results'][0]['id']
		end
		response
	end

	def get_valid_users_by_email(user_email: 'rfp@linkedin.com')
		params = "term=#{user_email}"
		response = self.get(path: 'auth/users/search?' + params)
		response['results'].select {|user|  user['email'].include?(user_email)}
	end

	def create_client(payload: nil, user_email: 'fun_admin@test.test')
        paylod_data = data()
		if payload
			paylod_data = payload
		end
		response = self.post(path: 'api/catalog/clients', payload: paylod_data)
		
		user = get_valid_users_by_email(user_email: user_email)

		self.restrict_client_users(response['id'], team_user_id: user.first['id'])
		response
	end

	def get_client_by_name(name)
        encoded_name = URI.encode(name)
		params = "term=#{encoded_name}"
	
		response = self.get(path: 'api/catalog/clients/search_with_brands/?' + params)
		response['results'].first
	end

	def restrict_client_users(created_client_id, team_user_id: nil)
		payload = {team_user_ids: []}
		if team_user_id
			payload[:team_user_ids].push(team_user_id)
		end
		response = self.put(path: "api/catalog/clients/#{created_client_id}/restrict_client_users", payload: payload)
	end

	def brand_data(brand_name: Faker::Name.name, vertical_id: 'cbac75f3-3270-4ded-a098-a22b68f48028')
		data = {'name': brand_name,'vertical_ids':[vertical_id],'client_ids':[]}
		response = self.post(path:'api/catalog/brands', payload: data)
	end

	def create_brand(data: nil)
		payload = brand_data()
		if data
			payload = data
		end
		response = self.post(path: 'api/catalog/brands', payload: payload)
		response
	end
end



