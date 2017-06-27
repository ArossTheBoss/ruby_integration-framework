require 'pry'
require 'rest-client'
require_relative 'authentication.rb'

class HttpBase
	extend Authentication

	attr_accessor :headers, :cookies, :crf_token, :authenticity_token , :auth_data, :base_url, :path

	def initialize(baseUrl: "localhost:3000", path: "", user: "fun_admin@test.test", password: "danpatrick")
        @auth_data = HttpBase.authenticate(baseUrl: baseUrl, user: user, password: password)
		@headers = @auth_data['headers']
		@cookies = @auth_data['cookies']
		@crf_token = @auth_data['csrfToken']
		@authenticity_token = @auth_data['authenticityToken']
		@base_url = baseUrl
		@path = path
	end	

	def get(path: nil, params: {})
		full_url = @base_url
		if path
			full_url = @base_url+ "/" + path
		end
		response = RestClient::Request.execute(method: :get, url: full_url, headers: @headers, params: params)
	end

end




	
if __FILE__ == $0
	h = HttpBase.new
	h.get(path: "sdsfdsgsdg", params: {"tset" =>  "alex"})
end