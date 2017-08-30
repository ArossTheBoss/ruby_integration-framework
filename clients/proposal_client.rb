require_relative 'http_base'
require 'faker'
require 'json'
require 'pry'
require 'date'

class ProposalClient < HttpBase
  attr_accessor :proposal_id

  def initialize(session: nil, path: 'api/direct/proposals')
    super(session, path)

  end

  def get_markets
    self.get(path: 'api/catalog/markets')
  end

  def univeral_search(vendor_name: 'Matrix')
    vendor_info = self.get(path: "api/catalog/universal_search?active=true&for_vendor=false&name=#{vendor_name}&page=1&sort%5Bfield%5D=name&sort%5Border%5D=asc&type=property")
    self.get(path: "/api/catalog/properties/#{vendor_info['results'].first['_id']}")
  end

  def data(media_plan_id:)
    vendor_properties = self.univeral_search
    vendor_id = vendor_properties['vendors'].first['id']
    propert_vendor_id = vendor_properties['property_vendors'].first['id']

    {
      "media_plan_id": media_plan_id,
      "vendor_id": vendor_id,
      "contact_ids": [],
      "property_buys_attributes": [{
                                     "property_vendor_id": propert_vendor_id,
                                     "tactics_attributes": []
                                   }]
    }
  end

  def create_proposal(data:)
    self.post(payload: data)
  end

  def update_proposal(line_item_data: )
    proposal_id = line_item_data[:id]

    self.put(payload: line_item_data, path: "api/direct/proposals/" + proposal_id)
  end

  def rate_type(type:)
    type = self.get(path: 'api/direct/rate_types').select {|t| t['description'] == type }.first
    type['id']
  end

  def line_item_data(proposal:, campaign:, rate_type:, media_rate:, total_units:, available_units:)
    {
      "id": proposal['id'],
      "name": nil,
      "viewed": false,
      "media_plan_id": campaign['media_plan_id'],
      "property_buys_attributes": [{
                                     "id": proposal['property_buys'].first['id'],
                                     "position": 1,
                                     "property_vendor_id": proposal['property_buys'].first['property_vendor']['id'],
                                     "tactics_attributes": tactics_attributes(name: 'Line Item',
                                                                              start_date: campaign['start_date'],
                                                                              end_date: campaign['end_date'],
                                                                              rate_type: rate_type,
                                                                              media_rate: media_rate,
                                                                              total_units: total_units,
                                                                              available_units: available_units),
                                     "placements_attributes": []
                                   }]

    }

  end

  def tactics_attributes(name:, start_date:, end_date:, rate_type:, media_rate:, total_units:, available_units:)
    [{
       "name": name,
       "rate_type_id": rate_type(type: rate_type),
       "format_id": "1a0add74-2112-46fd-849e-3ebd73cdc0a1",
       "platform_ids": ["1921e580-5d11-4a8f-8cbe-20116c06cde3"],
       "dimension_ids": ["006c8e7d-aaee-4f3a-8cfe-422f9f95f963"],
       "flights_attributes": flights_attributes(start_date: start_date , end_date: end_date, media_rate: media_rate, total_units: total_units, available_units: available_units )
     }]
  end

  def flights_attributes(start_date:, end_date:, media_rate:, total_units:, available_units: )
    [{
       "start_date": start_date,
       "end_date": end_date,
       "media_rate": media_rate,
       "client_media_rate": Faker::Number.number(1),
       "user_input_media_cost": Faker::Number.number(2),
       "ordered_units": Faker::Number.number(2),
       "total_units": total_units,
       "available_units": available_units,
       "user_input_client_cost": Faker::Number.number(2),
       "user_input_media_margin": 0,
       "user_input_client_rate": Faker::Number.number(2),
       "ad_serving_rate": Faker::Number.number(2),
       "ad_serving_client_rate": Faker::Number.number(2)
     }]
  end
end

