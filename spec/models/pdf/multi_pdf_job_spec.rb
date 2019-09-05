# frozen_string_literal: true

describe MultiPDFJob, type: :model do
  require 'sucker_punch/async_syntax'
  describe 'jobs_left' do
    it 'should have no jobs_left?' do
      expect(MultiPDFJob.jobs_left?(0)).to be_falsey
    end
  end

  describe 'perform' do
    before(:each) do
      AppFactory.add_confirmation_events
      @admin = FactoryBot.create(:admin, email: 'paul@kristoffs.com', name: 'Paul')
      @candidate = FactoryBot.create(:candidate, add_candidate_events: true, add_new_confirmation_events: false)
    end

    it 'should add pdf doc to zip file' do
      MultiPDFJob.generate_pdfs([@candidate], @admin)
      archive_path, filename = MultiPDFJob.generate_pdfs([@candidate], @admin)
      expected_filename = "pdfs_#{Time.zone.now}.zip"
      expect(archive_path.basename.to_s).to eq(expected_filename)
      expect(filename).to eq(expected_filename)
      expect(archive_path.dirname.to_s).to eq(Rails.root.to_s)
    end

    it 'should add 2 pdf doc to zip file' do
      candidate2 = FactoryBot.create(:candidate, account_name: 'cand2', add_candidate_events: true, add_new_confirmation_events: false)
      candidate2.candidate_sheet.first_name = 'first'
      candidate2.candidate_sheet.last_name = 'last'
      archive_path, filename = MultiPDFJob.generate_pdfs([@candidate, candidate2], @admin)
      expected_filename = "pdfs_#{Time.zone.now}.zip"
      expect(archive_path.basename.to_s).to eq(expected_filename)
      expect(filename).to eq(expected_filename)
      expect(archive_path.dirname.to_s).to eq(Rails.root.to_s)
    end
  end
end
