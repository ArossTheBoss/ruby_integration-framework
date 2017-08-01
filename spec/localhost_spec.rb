require_relative '../modules/authentication'
require_relative '../clients/http_base'
require_relative '../clients/client_client'
require_relative '../clients/initiative_client'
require_relative '../clients/terms_and_conditions_client'
require 'json'


RSpec.describe "Integration tests pointed at localhost" do

   let(:authenticated_session) {Authentication::authenticate()}
   let(:client) {Client.new(session: authenticated_session)}
   let(:initiative_client) {InitiativeClient.new(session: authenticated_session)}
   let(:brand_id) {client.get_valid_brands(first_brand_id_only: true)}
   let(:terms_conditions_client) {TermsAndConditions.new(session: authenticated_session)}

   it 'excepts terms and conditions' do
      response = terms_conditions_client.except_terms_and_conditions
      expect(response).to eq(nil)
   end


   it "logs into staging and creates a client with a brand" do
      client_payload = client.data(brand_id: brand_id)
      
      created_client = client.create_client(payload: client_payload)
   
      found_client = client.get_client_by_name(client_payload[:name])

      expect(created_client["id"]).to eq(found_client["id"]) 

      initiative_data = initiative_client.initiative_data(initative_duration=30)
  
      created_initiative = initiative_client.create_initiative(data: initiative_data)
   end

   # it "creates an initiative" do
   #    initiative_data = initiative_client.initiative_data(initative_duration=30)
   #    puts initiative_data
   #    created_initiative = initiative_client.create_initiative(data: initiative_data)
   # end
end