require 'pry'
require 'rest-client'
require_relative '../modules/authentication.rb'
require 'json'

class HttpBase
	extend Authentication

	attr_accessor :headers,
								:cookies,
								:crf_token,
								:authenticity_token,
								:auth_data, :base_url,
								:path,
								:protocol,
								:session

	def initialize(session, path)
		@headers = session[:headers]
		@cookies = session[:cookies]
		@crf_token = session[:csrfToken]
		@authenticity_token = session[:authenticityToken]
		@base_url = session[:baseUrl]
		@path = path
		@protocol = 'http://'

		unless @base_url.include?('localhost')
			@protocol = 'https://'
		end
	end	

	def get(path: nil, params: {})
		full_url = @base_url
		if path
			full_url = @base_url+ '/' + path
		end
		response = RestClient::Request.execute(method: :get, url: @protocol + full_url, headers: @headers, params: params)
		error_check(response)
		JSON.parse(response)
	end

	def post(path: nil, payload: nil)
		full_url = @base_url + '/' + @path

		if path
			full_url = @base_url+ '/' + path
		end

		@headers['X-CSRF-Token'] = @crf_token

		response = RestClient::Request.execute(method: :post, url: @protocol + full_url, payload: payload, headers: @headers) {|response, request, result| response}
		if response.body == 'null'
			response.body.to_json
			return JSON.parse(response, :quirks_mode => true)
		end
		error_check(response)
		JSON.parse(response)
	end

	def put(path: nil, payload: nil)
		full_url = @base_url + "/" + @path
		if path
			full_url = @base_url+ "/" + path
		end

		@headers['X-CSRF-Token'] = @crf_token
		response = RestClient::Request.execute(method: :put, url: @protocol + full_url, payload: payload, headers: @headers) {|response, request, result| response}

		error_check(response)
		JSON.parse(response)
	end

	def error_check(response)
		request_method = response.request.method

		case request_method
		when "get"
			if response.code != 200
				puts "ERROR with GET request for #{response.request.url} with status: " + RestClient::STATUSES[response.code].to_s
			end
			when "post"
				unless [200, 201].include?(response.code)
				puts "ERROR with POST request for #{response.request.url} with status: " + RestClient::STATUSES[response.code].to_s
			end
		when "put"
			if response.code != 200 
				puts "ERROR with PUT request for #{response.request.url} with status: " + RestClient::STATUSES[response.code].to_s
			end
			else
		end
	end
end

