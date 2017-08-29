require_relative '../modules/authentication'
require_relative '../clients/http_base'
require_relative '../clients/client_client'
require_relative '../clients/initiative_client'
require_relative '../clients/terms_and_conditions_client'
require_relative '../clients/campaign_client'
require_relative '../clients/http_base'
require 'json'


RSpec.describe "Integration tests pointed at staging" do

   let(:authenticated_session) {Authentication::authenticate(base_url: "platform01.staging.basis.net", user: "admin@centro.net", password: "password")}
   let(:user) {Client.new(session: authenticated_session).get_valid_users_by_email(user_email: "prod.test.cd@gmail.com")}
   let(:impersenated_session) {Authentication::login_as(authenticated_session, user)}

   let(:client) {Client.new(session: impersenated_session)}
   let(:initiative_client) {InitiativeClient.new(session: impersenated_session)}
   let(:brand_id) {client.get_valid_brands(first_brand_id_only: true)}
   let(:terms_conditions_client) {TermsAndConditions.new(session: impersenated_session)}
   let(:campaign_client) {CampaignClient.new(session: impersenated_session)}


   it 'excepts terms and conditions' do
      response = terms_conditions_client.except_terms_and_conditions
      expect(response).to eq(nil)
   end


   it "logs into localhost and creates a client with a brand" do

      client_payload = client.data(brand_id: brand_id)

      created_client = client.create_client(payload: client_payload, user_email:'prod.test.cd@gmail.com')

      found_client = client.get_client_by_name(client_payload[:name])

      expect(created_client["id"]).to eq(found_client["id"])

      initiative_data = initiative_client.initiative_data(initiative_duration: 30, client_brand_id: created_client['client_brands'].first['id'], client_id: created_client['id'])

      initiative = initiative_client.create_initiative(data: initiative_data)

      campaign = campaign_client.create_campaign(initiative: initiative)
   end
end
