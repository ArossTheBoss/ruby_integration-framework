require_relative 'http_base'
require 'faker'
require 'json'
require 'pry'

class Client < HttpBase

	def initialize(session: nil, path: "api/catalog/clients")
		super(session, path)
	end

	def data(brand_id: nil)
		brand_ids =[]
		data = {"name": Faker::Company.name,
				"notes": "Test Client",
				"billing_address_attributes": {
					"address1": Faker::Address.street_name,
					"address2": "",
					"country": "United States",
					"city": "Wheeling",
					"state": "Illinois",
					"postal_code": "60089"
				},
				"brand_ids": brand_ids.push(brand_id),
				"billing_codes_attributes": [],
				"billing_name": "Aross",
				"restricted_access": true,
				"contact_first_name": "Alex",
				"contact_last_name": "Ross",
				"contact_email": "alex.ross@testemail.com",
				"contact_phone": "111-223-4403",
				"contact_extension": "000"}
	end

	def get_valid_brands(first_brand_id_only: false)
		response = self.get(path: "api/catalog/brands/search/")
	   
		if first_brand_id_only
			return response["results"][0]["id"]
		end
		brands
	end

	def get_valid_users_by_email(user_email: "rfp@linkedin.com")
		params = "term=#{user_email}"
		response = self.get(path: "auth/users/search?" + params)
		response['results'].select {|user|  user['email'].include?(user_email)}
	end

	def create_client(payload: nil)
        paylod_data = data()
		if payload
			paylod_data = payload
		end
		response = self.post(payload: paylod_data)
	
		self.restrict_client_users(response["id"], team_user_id: nil)
		response
	end

	def get_client_by_name(name)
        encoded_name = URI.encode(name)
		params = "term=#{encoded_name}"
	
		response = self.get(path: "/api/catalog/clients/search_with_brands/?" + params)
		response['results'].first
	end

	def restrict_client_users(created_client_id, team_user_id: nil)
		payload = {"team_user_ids":[]}
		if team_user_id
			payload["team_user_ids"] = [team_user_id]
		end
		response = self.put(path: "api/catalog/clients/#{created_client_id}/restrict_client_users", payload: payload)
	end

	
end



