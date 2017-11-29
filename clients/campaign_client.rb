require_relative 'http_base'
require 'faker'
require 'json'
require 'pry'
require 'Date'

class CampaignClient < HttpBase
	def initialize(session: nil, path: 'api/direct/campaigns')
		super(session, path)
	end

	def data(initiative_id: id, initiative_duration: 30, objectives: nil)
		objective = self.get(path:'api/direct/objectives')
		
		if objectives
			objective = objectives
		end

		now = DateTime.now

		{ 'ugcid': Faker::Number.number(5),
			'budget': Faker::Number.number(4),
			'name': 'Monkey Man Campaign' + DateTime.now.to_s,
			'initiative_id': initiative_id ,
	        'objectives_attributes': [{
		    'goal': Faker::Number.number(3),
		    
		    'kpi_id': objective.first['kpi_id'],
		    'objective_type_id': objective.first['objective_type_id']
		    }],
	       'billing_codes_attributes': [],
	       'team_user_ids': ['f580aa72-bc3e-42be-9fb3-1123ec6043dd'],
           'start_date': convert_date_to_s(now),
           'end_date': convert_date_to_s(now, initiative_duration: initiative_duration)
       }
	end

	def create_campaign(initiative: , data: nil)
		payload = data(initiative_id: initiative['id'])
		
		if data
			payload = data
		end
	
		response = self.post(payload: payload)
        
    campaign_id = response['id']

    media_plans = self.get(path: "/api/direct/campaign_overviews/#{campaign_id}/media_plans")

    media_plan_id = media_plans.first['id']
		
		edit_media_plan(media_plan_id: media_plan_id, campaign_id: campaign_id)

		response.merge({'media_plan_id' => media_plan_id})
	end

	def edit_media_plan(media_name: 'Media name', media_note: 'Media Note', media_plan_id: nil, campaign_id: nil)
		now = DateTime.now

		payload = {
			'name': media_name,
			'note': media_note, 
			'budget': 1000,
			'id': media_plan_id,
			'aggregate_updated_at': '2017-08-18T14:39:08.548Z',
			'approval_version': nil,
			'current_state': 'draft',
			'updated_at': convert_date_to_s(now),
			'created_at': convert_date_to_s(now),
			'revision_version': nil,
			'deleted_at': nil,
			'campaign_id': campaign_id
		}

    self.put(path: "api/direct/media_plans/#{media_plan_id}", payload: payload)
	 end


	def convert_date_to_s(date, initiative_duration: 0)
		d = DateTime.now
		if date
			d = date + initiative_duration
		end
		d.strftime('%Y-%m-%d')
	end
end

