require_relative '../modules/authentication'
require_relative '../clients/http_base'
require_relative '../clients/client_client'
require_relative '../clients/initiative_client'
require 'json'


RSpec.describe "Integration tests pointed at staging" do

   let(:authenticated_session) {Authentication::authenticate(baseUrl: "platform01.staging.basis.net", user: "admin@centro.net", password: "password")}
   let(:user) {Client.new(session: authenticated_session).get_valid_users_by_email(user_email: "prod.test.cd@gmail.com")}
   let(:impersenated_session) {Authentication::login_as(authenticated_session, user)}
   
   let(:client) {Client.new(session: impersenated_session)}
   let(:initiative_client) {InitiativeClient.new(session: impersenated_session)}
   let(:brand_id) {client.get_valid_brands(first_brand_id_only: true)}

   it "logs into staging and creates data" do
      client_payload = client.data(brand_id: brand_id)
    
      created_client = client.create_client(payload: client_payload)
   

      found_client = client.get_client_by_name(client_payload[:name])

      expect(created_client["id"]).to eq(found_client["id"])
      
   end

   it "creates an initiative" do
      initiative_data = initiative_client.initiative_data
      created_initiative = initiative_client.create_initiative(data: initiative_data)
   end
end
