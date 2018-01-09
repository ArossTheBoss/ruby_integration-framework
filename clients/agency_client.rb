require_relative 'http_client'
require 'faker'
require 'json'
require 'pry'
require 'Date'

class AgencyClient < HttpClient
	def initialize(session: nil, path: '/auth/agencies')
		nil
  end

	def agenecy_data
    {
      'name': 'Jiggbobo Agency',
      'phone': '1112212323',
      'address_attributes':
        {
          'address1': '444 Testing Ave',
          'address2': '',
          'country': 'United States',
          'city': 'Chicago',
          'state': 'Illinois',
          'postal_code': '60605'
        },
      'pricing_plans_attributes': [
        {
          'cost': 1000,
          'plan_type': 'flat',
          'start_date': '2000-01-01',
          'end_date': '2030-01-01'
        }
      ],
      'billing_information_attributes':
        {
          'attention': '',
          'email': 'jiggboboTest@gmail.com',
          'phone': '3332232345',
          'fax': '',
          'address_attributes':
            {
              'address1': '445 Testing Ave2',
              'address2': '',
              'country': 'United States',
              'city': 'Chicago',
              'state': 'Illinois',
              'postal_code': '60605'
            },
          'company_name': 'Jiggbobo Company'
        }
    }
  end
end


