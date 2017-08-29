require_relative '../modules/authentication'
require_relative '../clients/http_base'
require_relative '../clients/client_client'
require_relative '../clients/initiative_client'
require_relative '../clients/terms_and_conditions_client'
require_relative '../clients/campaign_client'
require_relative '../clients/proposal_client'
require_relative '../clients/http_base'
require 'json'


RSpec.describe "Api Integration flow pointed at localhost" do

  let(:authenticated_session) {Authentication::authenticate()}
  let(:client) {Client.new(session: authenticated_session)}
  let(:initiative_client) {InitiativeClient.new(session: authenticated_session)}
  let(:brand_id) {client.get_valid_brands(first_brand_id_only: true)}
  let(:terms_conditions_client) {TermsAndConditions.new(session: authenticated_session)}
  let(:campaign_client) {CampaignClient.new(session: authenticated_session)}
  let(:proposal_client) {ProposalClient.new(session: authenticated_session)}

  it 'excepts terms and conditions' do
    response = terms_conditions_client.except_terms_and_conditions
    expect(response).to eq(nil)
  end


  it "creates campaigns" do
    client_payload = client.data(brand_id: brand_id)

    created_client = client.create_client(payload: client_payload)

    found_client = client.get_client_by_name(client_payload[:name])

    expect(created_client["id"]).to eq(found_client["id"])

    initiative_data = initiative_client.initiative_data(initiative_duration: 30, client_brand_id: created_client['client_brands'].first['id'], client_id: created_client['id'])

    initiative = initiative_client.create_initiative(data: initiative_data)

    campaign = campaign_client.create_campaign(initiative: initiative)

    propostal_data = proposal_client.data(media_plan_id: campaign['media_plan_id'])

    proposal = proposal_client.create_proposal(data: propostal_data)

    propostal_data = proposal_client.line_item_data(proposal: proposal, campaign: campaign, rate_type: 'CPM')

    add_line_item = proposal_client.update_proposal(line_item_data:propostal_data)
    end
end