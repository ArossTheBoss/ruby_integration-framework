require_relative 'http_base'
require 'faker'
require 'json'
require 'pry'

class CampaignClient < HttpBase
	def initialize(session: nil, path: "api/direct/campaigns")
		super(session, path)
	end

	def data
		{"ugcid": "25235345",
	     "budget": 222,
	     "name": "test",
      	"initiative_id": "02f3fb12-1064-464a-92e8-a9711623337e",
      	"objectives_attributes": [{"goal": 10, "kpi_id": "149df69b-691c-4771-a886-70e34064dcd2","objective_type_id": "ff51381a-2404-48fc-9bed-788190097549"}],
      	"billing_codes_attributes": [],
      	"team_user_ids": ["37fa9b4e-605d-4874-b234-7572e13b8a9b"],
      	"start_date": "2017-07-16",
      	"end_date": "2017-08-05"
      }
	end

end