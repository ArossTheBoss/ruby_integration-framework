require "uri"
require 'json'
require 'pry'
require 'oga'
require 'rest-client'


module Authentication
   
	DEFUALT_USER = 'fun_admin@test.test'
	DEFAULT_PASSWORD = "danpatrick"
    LOGIN_BASE_URL = "localhost:3000"
	LOGIN_PATH = "auth/login"
	SESSION_PATH = "auth/sessions"
 
	def getAuthentictyToken(responseBody)
        document = Oga.parse_html(responseBody.body)
        authenticity_token = document.at_css('input[name="authenticity_token"]').get('value')
		return authenticity_token
	end
    
	def getCsrfToken(responseBody)
        document = Oga.parse_html(responseBody.body)
        csrf_token = document.at_css('meta[name="csrf-token"]').get('content')
		return csrf_token
	end
    
	def urlEncodedformData(authenticity_token: nil, user: DEFUALT_USER, password: DEFAULT_PASSWORD)
        data = {"session[email]" => user,  "session[password]" => password, "commit" => "Sign in ", "authenticity_token" => authenticity_token, "utf8"=>"✓"}
        encoded_data = URI.encode_www_form(data)
		return encoded_data
    end
    
    def getCookiefromAuthLogin(response)
    	return response.headers[:set_cookie][0]
    end

    def getCookiesFromSession(response)
        cookie = response.headers[:set_cookie][0].sub!("; path=/", "") + ";" + response.headers[:set_cookie][1].sub!("; path=/", "")
        return cookie
    end

    def getRequestIdFromAuthLogin(response)
    	return response.headers[:x_request_id]
    end

    def getUserUuid(headers)
        uri = headers['Cookie'][0]
        userId = URI.decode(uri).sub!("; path=/","::").split("::")[1]
        return userId
    end
    

    def authenticate(baseUrl: LOGIN_BASE_URL, user: DEFUALT_USER, password: DEFAULT_PASSWORD)
     login_url = baseUrl + "/" + LOGIN_PATH
     session_url = baseUrl + "/" + SESSION_PATH
     headers = {}

     dashboard_response = RestClient.get("http://#{LOGIN_BASE_URL}/dashboard?statuses=Planning&statuses=Approved&statuses=Live")
     headers['Cookie'] = getCookiefromAuthLogin(dashboard_response)

     auth_response = RestClient::Request.execute(method: :get, url: login_url, headers: headers)
     headers['Cookie'] = getCookiefromAuthLogin(auth_response)
     puts auth_response.body
    
     authenticity_token = getAuthentictyToken(auth_response)
     csrf_token = getCsrfToken(auth_response)
     form_data = urlEncodedformData(authenticity_token: authenticity_token)
   
     session_response = RestClient::Request.execute(method: :post, url: session_url, payload: form_data, headers: headers) {|response, request, result| response}
     headers["Cookie"] = getCookiesFromSession(session_response)
     
     auth_data ={"headers" => headers, "csrfToken" => csrf_token, "authenticityToken" => authenticity_token, "cookies" => session_response.cookies}
     return auth_data

     end
 end






