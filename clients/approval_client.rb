require_relative 'http_base'
require 'faker'
require 'json'
require 'pry'
require 'Date'


class ApprovalClient < HttpBase
  def initialize(session: nil, path: '/api/direct/campaigns/')
    super(session, path)
  end

  def create_csv_file
    filename = 'test_file.csv'
    CSV.open(filename, 'wb') do |csv|
      csv << ['header']
      csv << ['data']
    end
    filename
  end

  def approval_payload(campaign:, initiative:)
    {
      'media_plan_id': campaign['media_plan_id'],
      'ugcid': campaign['ugcid'],
      'client_brand_id': initiative['client_brand']['id'],
      'multipart': true,
      'approval_document': File.new(create_csv_file, 'rb')
    }
  end

  def approve_proposal(campaign:, initiative:)
    binding.pry
    payload = approval_payload(campaign: campaign, initiative: initiative)
    self.post(path: "/api/direct/campaigns/#{campaign['id']}/plan_approve", payload: payload)
  end
end