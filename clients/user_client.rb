require_relative 'http_base'
require 'faker'
require 'json'
require 'date'

class UserClient < HttpBase

	def initialize(session: nil, path: 'auth/agencies/b900d57c-0bd8-4f36-8cff-2c5b64be1b43/users')
		super(session, path)
	end

	def data(first_name: 'Jiggbobo', last_name: 'beef', email: 'jiggbobo444@gmail.com')
		{ 'email': email,
		 'phone': '3333332123',
		  'commissioned': true, 
		  'region': 'America',
		  'location': 'Chicago',
		  'division': 'South America','permission_set_ids': ['5c1a0c0b-6324-4c04-af5a-fe0652011138', '48dd8b29-2a29-4d54-bbaf-016ae54b96af', '039d1c8a-4d0e-472d-8f60-783d72bbe95f', '55d56700-f07d-4954-850e-f81587d05d4c', 'babbd9cc-5f73-406e-97d3-be6ed7e2bfd8', '599d3306-968d-4dc2-92cb-fda34939e54a', '2e132d98-02cd-4177-8087-8416ee7b4822', '05fea8e8-e45c-4b77-822c-caf747ef63b1', '583a49a5-3d65-4a68-94dc-6401d64b2a9d', 'd0d621a8-0e84-437d-917b-439a2bec833c', '46f4eb8e-39b6-439e-8668-4e81fac3e854', '6765f6b4-8d00-420b-9f0a-a38a1a30c7e0', '9aa881f0-4e75-4c37-a586-1bc57daf371d'],
		  'agency_id': 'b900d57c-0bd8-4f36-8cff-2c5b64be1b43',
		  'first_name': first_name,
		  'last_name': last_name}
	end

	def create_user
		response = self.post(payload: data)
		puts response
	end


end

