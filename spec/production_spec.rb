require_relative '../modules/authentication'
require_relative '../clients/http_base'
require_relative '../clients/client_brand_client'
require_relative '../clients/initiative_client'
require_relative '../clients/terms_and_conditions_client'
require_relative '../clients/campaign_client'
require_relative '../clients/proposal_client'
require_relative '../clients/http_base'
require 'json'
require 'faker'


RSpec.describe "Production API smoke test" do
  let(:session) do
    Authentication::authenticate(base_url: "platform.basis.net", user: "sanju.premkumar@centro.net", password: "danpatrick")
  end

  let(:http_client) { HttpBase.new(session, nil) }
  let(:parse_response) { JSON.parse(response) }

  it 'test1' do
    http_client.get('')
  end
end


