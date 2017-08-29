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

  def line_item_data(proposal:, campaign:, rate_type:)
    {
      "id": proposal['id'],
      "name": nil,
      "viewed": false,
      "media_plan_id": campaign['media_plan_id'],
      "property_buys_attributes": [{
                                     "id": proposal['property_buys'].first['id'],
                                     "position": 1,
                                     "property_vendor_id": proposal['property_buys'].first['property_vendor']['id'],

                                     "placements_attributes": []
                                   }]

    }
  end

  def tactics_attributes(name:, start_date:, end_date:, rate_type:)
    [{
       "name": name,
       "rate_type_id": rate_type(type: rate_type),
       "format_id": "a44846cc-b9dd-4242-9a18-e7b697827a6d",
       "platform_ids": ["29dd5304-e740-434a-b977-f4e9893107e6"],
       "dimension_ids": ["ed19322d-2af4-49c2-8549-dcd46a2233e6"],
       "flights_attributes": flights_attributes(start_date: start_date , end_date: end_date )
     }]
  end

  def flights_attributes(start_date:, end_date:)
    [{
       "start_date": start_date,
       "end_date": end_date,
       "media_rate": 2,
       "client_media_rate": 2,
       "user_input_media_cost": 2,
       "ordered_units": 1,
       "total_units": 2,
       "available_units": 2,
       "user_input_client_cost": 2,
       "user_input_media_margin": 0,
       "user_input_client_rate": 2,
       "ad_serving_rate": 2,
       "ad_serving_client_rate": 2
     }]
  end
end

