require 'rails_helper'

describe SponsorCovenant, type: :model do

  describe 'basic creation' do

    it 'can retrieve a SponsorCovenant\'s info' do
      sponsor_covenant = FactoryGirl.create(:sponsor_covenant)
      expect(sponsor_covenant.sponsor_name).to match 'George Sponsor'
      expect(sponsor_covenant.sponsor_elegibility_filename).to eq(nil)

    end

  end
end
