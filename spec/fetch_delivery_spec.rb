require_relative '../modules/authentication'
require_relative '../clients/http_base'
require_relative '../clients/client_client'
require_relative '../clients/initiative_client'
require 'json'



RSpec.describe "Fetch Delivery" do

   let(:authenticated_session) {Authentication::authenticate(baseUrl: "cmm.dev", user: "admin@centro.net", password: "danpatrick")}
   let(:http_client) {HttpBase.new(session: authenticated_session, path: "internal")}

   it 'fetches delivery for Facebook' do
       #to do
   end
end


   
