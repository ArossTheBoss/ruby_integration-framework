require_relative 'http_client'
require 'faker'
require 'json'
require 'pry'
require 'date'
require 'csv'

class ProposalClient < HttpClient
  attr_accessor :proposal_id

  def initialize(session: nil, path: 'api/direct/proposals')
    super(session, path)
  end

  def get_markets
    self.get(path: 'api/catalog/markets')
  end

  def univeral_search(vendor_name: 'FBSkins.com')
    vendor_info = self.get(path: "api/catalog/universal_search?active=true&for_vendor=false&name=#{vendor_name}&page=1&sort%5Bfield%5D=name&sort%5Border%5D=asc&type=property")
    self.get(path: "/api/catalog/properties/#{vendor_info['results'].first['_id']}")
  end

  def proposal_data(media_plan_id:, vendor:)
    d = {
      "media_plan_id": media_plan_id,
      "contact_ids": [],
      "property_buys_attributes": []
    }

    vendor.each do |v|
      vendor_properties = self.univeral_search(vendor_name: v)
      vendor_id = vendor_properties['vendors'].first['id']
      propert_vendor_id = vendor_properties['property_vendors'].first['id']

      attributes  = {
        "property_vendor_id": propert_vendor_id,
        "tactics_attributes": []
      }

      d[:vendor_id] = vendor_id
      d[:property_buys_attributes] << attributes
    end
    return d
  end


  def create_proposal(data:)
    self.post(payload: data)
  end

  def update_proposal(line_item_data: )
    proposal_id = line_item_data[:id]
    self.put(payload: line_item_data, path: "api/direct/proposals/" + proposal_id)
  end

  def revise_proposal(media_plan_id:, number_of_revisions: 1)
    number_of_revisions.times do
      self.post(path: "api/direct/media_plans/#{media_plan_id}/revise")
    end
  end

  def rate_type(type:)
    type = self.get(path: 'api/direct/rate_types').select {|t| t['description'] == type }.first
    type['id']
  end

  def line_item_data(proposal:, campaign:, rate_type:, media_rate:, total_units:, available_units:)
    d= {
      "id": proposal['id'],
      "name": nil,
      "viewed": false,
      "media_plan_id": campaign['media_plan_id'],
      "property_buys_attributes": []
    }

    proposal["property_buys"].each do |p|

    d[:property_buys_attributes] << {
      "id": p['id'],
      "position": 1,
      "property_vendor_id": p['property_vendor']['id'],
      "tactics_attributes": tactics_attributes(name: "Line Item for #{rate_type}",
                                               start_date: campaign['start_date'],
                                               end_date: campaign['end_date'],
                                               rate_type: rate_type,
                                               media_rate: media_rate,
                                               total_units: total_units,
                                               available_units: available_units),
      "placements_attributes": []
    }
    end
    return d
  end

  def tactics_attributes(name:, start_date:, end_date:, rate_type:, media_rate:, total_units:, available_units:)
    #Need end points to expose seeded data. Rate type is done need format id and dimensions and platform ids
    [
      {
        "name": name,
        "rate_type_id": rate_type(type: rate_type),
        "format_id": "4f564ac1-d7c3-445c-b3de-bf85a6df65b0",
        "platform_ids": ["4edf7d8f-d14f-4cd6-8acd-b7e9d4fe6985"],
        "dimension_ids": ["99900f50-3bce-4c31-96af-0b3437358f20"],
        "flights_attributes": flights_attributes(start_date: start_date , end_date: end_date, media_rate: media_rate, total_units: total_units, available_units: available_units )
      }
    ]
  end

  def flights_attributes(start_date:, end_date:, media_rate:, total_units:, available_units: )
    [
      {
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
      }
    ]
  end
end

