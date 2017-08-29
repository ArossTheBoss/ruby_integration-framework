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
  LOGOUT_PATH= "auth/logout"
	SESSION_PATH = "auth/sessions"
 
	def self.get_authenticty_token(response_body)
        document = Oga.parse_html(response_body.body)
        authenticity_token = document.at_css('input[name="authenticity_token"]').get('value')
		return authenticity_token
	end
    
	def self.get_csrf_token(response_body)
        document = Oga.parse_html(response_body.body)
        csrf_token = document.at_css('meta[name="csrf-token"]').get('content')
		return csrf_token
	end
    
	def self.url_encoded_form_data(authenticity_token: nil, user: DEFUALT_USER, password: DEFAULT_PASSWORD)
        data = {'session[email]' => user,  'session[password]' => password, 'commit' => 'Sign in ', 'authenticity_token' => authenticity_token, 'utf8'=> '✓'}
        encoded_data = URI.encode_www_form(data)
		return encoded_data
    end
    
    def self.get_cookies_from_response(response)
        cookie = ''
        if response.cookies.size > 1
            cookie = "auth%2Fuser_credentials=#{response.cookies["auth%2Fuser_credentials"]}" + ";" + "_main_session=#{response.cookies["_main_session"]}"
        else
            cookie = "_main_session=#{response.cookies["_main_session"]}"
        end
        return cookie
    end

    def self.get_user_uuid(headers)
        uri = headers['Cookie'][0]
        user_id = URI.decode(uri).sub!("; path=/","::").split("::")[1]
        return user_id
    end

    def self.authenticate(base_url: LOGIN_BASE_URL, user: DEFUALT_USER, password: DEFAULT_PASSWORD)
     protocol = "http://" 

     if !base_url.include?("localhost")
        protocol = "https://"
     end

     login_url = protocol + base_url + "/" + LOGIN_PATH
     session_url = protocol + base_url + "/" + SESSION_PATH
     headers = {}
     dashboard_url = "#{base_url}/dashboard"
    
     dashboard_response = RestClient.get(dashboard_url)
     headers['Cookie'] = get_cookies_from_response(dashboard_response)
     
     auth_response = RestClient::Request.execute(method: :get, url: login_url, headers: headers)
     headers['Cookie'] = get_cookies_from_response(auth_response)
    
     authenticity_token = get_authenticty_token(auth_response)
     csrf_token = get_csrf_token(auth_response)
     form_data = url_encoded_form_data(authenticity_token: authenticity_token, user: user, password: password)
    
     session_response = RestClient::Request.execute(method: :post, url: session_url, payload: form_data, headers: headers) {|response, request, result| response}

     headers["Cookie"] = get_cookies_from_response(session_response)
     headers["Accept"] = "application/json; charset=utf-8"
     authenticated_data ={'headers' => headers, 'csrfToken' => csrf_token, 'authenticityToken' => authenticity_token, 'cookies' => session_response.cookies, 'sessionResponse' => session_response, 'baseUrl' => base_url, 'user' => user, 'password' => password}
     return authenticated_data
     end

     def self.login_as(authenticated_data, user)
        base_Url = authenticated_data['baseUrl']
        session_url = "https://#{baseUrl}/auth/su"
  
        payload = {"id": user.first['id']}  
        
        headers = authenticated_data['headers']
       
        headers["Cookie"]= authenticated_data['headers']["Cookie"]
        headers['X-CSRF-Token'] = authenticated_data['csrfToken']
       
        response = RestClient::Request.execute(method: :post, url: session_url, payload: payload, headers: headers) {|response, request, result| response}
        headers['Cookie'] = get_cookies_from_response(response)
        headers['Accept'] = "application/json; charset=utf-8"
        
        response = RestClient::Request.execute(method: :get, url: "https://#{baseUrl}/dashboard", headers: headers)
        csrf_token = get_csrf_token(response)
        headers['X-CSRF-Token'] = csrf_token
     
        authenticated_data ={"headers" => headers, "csrfToken" => csrf_token, "baseUrl" => baseUrl}
        return authenticated_data
    end


     def self.logout(base_url: LOGIN_BASE_URL)
        log_out_url =  base_url + "/" + LOGOUT_PATH
        response = RestClient.get(url: log_out_url) {|response, request, result| response.status}
        return response
    end
 end






