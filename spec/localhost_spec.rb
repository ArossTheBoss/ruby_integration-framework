require_relative '../clients/authentication_client'
require_relative '../clients/http_client'
require_relative '../clients/client_brand_client'
require_relative '../clients/initiative_client'
require_relative '../clients/terms_and_conditions_client'
require_relative '../clients/campaign_client'
require_relative '../clients/proposal_client'
require_relative '../clients/approval_client'
require 'json'
require 'faker'


RSpec.describe "Api Integration flow pointed at localhost" do
  #staging url 'staging01.prod.basis.net'
  let(:session) do
    AuthenticationClient
      .new(host: 'localhost:3000')
      .authenticate_by_credentials(email: 'fun_admin@test.test', password: 'danpatrick')
  end

  let(:http_client) { HttpClient.new( session, '') }

  let(:client) { ClientAndBrandClient.new(session: session)}
  let(:initiative_client) { InitiativeClient.new(session: session)}
  let(:brand_id) {client.get_valid_brands(first_brand_id_only: true)}
  let(:terms_conditions_client) { TermsAndConditions.new(session: session)}
  let(:campaign_client) { CampaignClient.new(session: session)}
  let(:proposal_client) { ProposalClient.new(session: session)}
  let(:approval_client) { ApprovalClient.new(session: session)}
  let(:media_rate) { Faker::Number.number(1) }
  let(:total_units) { Faker::Number.number(1) }
  let(:available_units) { Faker::Number.number(1) }

  it 'excepts terms and conditions' do
    response = terms_conditions_client.except_terms_and_conditions
    expect(response).to eq(nil)
  end


  it "creates campaigns" do
    1.times do
      puts "creating campaigns with vendor's..."
      #depends on ENV this brand changes and some are not valid
      #staging client branch 2f0e684b-58f0-47ee-b6a1-cf75e90d8b57'
      client_payload = client.data(brand_id: brand_id)
      #staging user = 'manager@centro.net'
      created_client = client.create_client(payload: client_payload)

      found_client = client.get_client_by_name(client_payload[:name])

      expect(created_client["id"]).to eq(found_client["id"])

      initiative_payload = initiative_client.initiative_data(initiative_duration: 30,
                                                             client_brand_id: created_client['client_brands'].first['id'],
                                                             client_id: created_client['id'])

      initiative = initiative_client.create_initiative(data: initiative_payload)

      campaign = campaign_client.create_campaign(initiative: initiative)

      #staging vendor 'google.com'
      propostal_payload = proposal_client.proposal_data(media_plan_id: campaign['media_plan_id'], vendor: ["Matrix", "FBSkins.com"])

      proposal = proposal_client.create_proposal(data: propostal_payload)

      ["Dynamic CPM", "CPM", "Dynamic CPC","Flat Impressions", "Flat Views", "Flat Completed Views", "CPC"].each do |type|
        proposal_line_item_payload = proposal_client.line_item_data(proposal: proposal,

                                                                campaign: campaign,
                                                                rate_type: type,
                                                                media_rate: media_rate,
                                                                total_units: total_units,
                                                                available_units: available_units)
        add_line_item = proposal_client.update_proposal(line_item_data: proposal_line_item_payload)
      end

      approved_proposal = approval_client.approve_proposal(campaign: campaign, initiative: initiative)

      revise_proposal = proposal_client.revise_proposal(media_plan_id: campaign['media_plan_id'], number_of_revisions: 2)

    end
  end
end