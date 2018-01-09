require "uri"
require 'oga'
require 'rest-client'


class AuthenticationClient
  attr_accessor :host

  def initialize(host: 'localhost:3000')
    self.host = host
  end

  def authenticate_by_user(user:)
    credentials = set_credentials(email: user.email, password: user.password)
    authenticate(credentials: credentials)
  end

  def authenticate_by_credentials(email:, password: )
    credentials = set_credentials(email: email, password: password)
    authenticate(credentials: credentials)
  end

  private

  def authenticty_token(response_body)
    document = Oga.parse_html(response_body.body)
    document.at_css('input[name="authenticity_token"]').get('value')
  end

  def csrf_token(response_body)
    document = Oga.parse_html(response_body.body)
    document.at_css('meta[name="csrf-token"]').get('content')
  end

  def url_encoded_form_data(authenticity_token: , credentials: )
    data = {
      'session[email]': credentials[:email],
      'session[password]': credentials[:password],
      'commit': 'Sign in ',
      'authenticity_token': authenticity_token,
      'utf8': '✓'
    }
    URI.encode_www_form(data)
  end

  def parse_cookies_from_response(response)
    if response.cookies.size > 1
      "auth%2Fuser_credentials=#{response.cookies["auth%2Fuser_credentials"]}" + ";" + "_main_session=#{response.cookies["_main_session"]}"
    else
      "_main_session=#{response.cookies["_main_session"]}"
    end
  end

  def set_credentials(email:, password:)
    { email: email, password: password }
  end

  def authenticate(credentials: )
    headers = {}

    protocol = host.include?('localhost') ? 'http://' : 'https://'

    dashboard_response = RestClient.get("#{protocol}#{host}/dashboard")

    headers['Cookie'] = parse_cookies_from_response(dashboard_response)

    login_response = RestClient::Request.execute(method: :get, url: "#{protocol}#{host}/auth/login", headers: headers){ |response| response }

    headers['Cookie'] = parse_cookies_from_response(login_response)

    authenticity_token = authenticty_token(login_response)

    csrf_token = csrf_token(login_response)

    form_data = url_encoded_form_data(authenticity_token: authenticity_token, credentials: credentials)

    session_response = RestClient::Request.execute(method: :post, url: "#{protocol}#{host}/auth/sessions", payload: form_data, headers: headers){ |response| response }

    headers['Cookie'] = parse_cookies_from_response(session_response)
    headers['Accept'] = "application/json; charset=utf-8"

    {
      headers: headers,
      csrfToken: csrf_token,
      authenticityToken: authenticity_token,
      cookies: session_response.cookies,
      protocol: protocol,
      baseUrl: host,
      credentials: credentials
    }
  end
end
