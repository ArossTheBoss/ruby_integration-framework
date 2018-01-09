require_relative 'http_client'
require 'faker'
require 'json'
require 'pry'

class TermsAndConditions < HttpClient

	def initialize(session: nil, path: 'api/catalog/terms_and_conditions?page=1')
		super(session, path)
	end

	def except_terms_and_conditions
		response = self.get(path: 'api/catalog/terms_and_conditions?page=1')
		id = response['results'].first['id']
		response = self.post(path: "api/catalog/terms_and_conditions/#{id}/make_active", payload: {})
	end
end
