# frozen_string_literal: true

require 'rails_helper'

private

def setup_candidate1
  ev = @candidate1.get_candidate_event(BaptismalCertificate.event_key)
  ev.completed_date = Time.zone.today
  bc = @candidate1.baptismal_certificate
  bc.baptized_at_home_parish = true
  bc.save
  ev.save
end

def setup_candidate2
  ev = @candidate2.get_candidate_event(BaptismalCertificate.event_key)
  ev.completed_date = Time.zone.today
  ev.verified = false
  picture = nil
  bc = @candidate2.baptismal_certificate
  filename = 'actions.png'
  File.open(File.join('spec/fixtures/files', filename), 'rb') do |f|
    picture = f.read
  end
  bc.baptized_at_home_parish = false
  bc.scanned_certificate = ::ScannedImage.new(
    filename: filename,
    content_type: 'image/png',
    content: picture
  )
  bc.save
  ev.save
end

def setup_candidate3
  ev = @candidate3.get_candidate_event(BaptismalCertificate.event_key)
  ev.completed_date = Time.zone.today
  bc = @candidate3.baptismal_certificate
  bc.baptized_at_home_parish = false
  bc.save
  ev.save
end

def setup_candidate4
  ev = @candidate4.get_candidate_event(BaptismalCertificate.event_key)
  ev.completed_date = Time.zone.today
  ev.verified = true
  picture = nil
  bc = @candidate4.baptismal_certificate
  filename = 'actions.png'
  File.open(File.join('spec/fixtures/files/', filename), 'rb') do |f|
    picture = f.read
  end
  bc.baptized_at_home_parish = false
  bc.scanned_certificate = ::ScannedImage.new(
    filename: filename,
    content_type: 'image/png',
    content: picture
  )
  bc.save
  ev.save
end

describe 'CandidatePDFDocument' do
  before do
    FactoryBot.create(:visitor)
    @candidate1 = FactoryBot.create(:candidate, account_name: 'c1', add_new_confirmation_events: false)
    @candidate1.candidate_sheet.first_name = 'cc1'
    @candidate2 = FactoryBot.create(:candidate, account_name: 'c2', add_new_confirmation_events: false)
    @candidate2.candidate_sheet.first_name = 'cc2'
    @candidate3 = FactoryBot.create(:candidate, account_name: 'c3', add_new_confirmation_events: false)
    @candidate3.candidate_sheet.first_name = 'cc3'
    @candidate4 = FactoryBot.create(:candidate, account_name: 'c4', add_new_confirmation_events: false)
    @candidate4.candidate_sheet.first_name = 'cc4'
    @candidate1.save
    @candidate2.save
    @candidate3.save
    @candidate4.save
    AppFactory.add_confirmation_events
    setup_candidate1
    setup_candidate2
    setup_candidate3
    setup_candidate4
  end

  it 'generate document name' do
    document_name = CandidateNamePDFDocument.document_name
    expect(document_name).to eq('Compare Baptismal Name.pdf')
  end

  it 'generate a document' do
    pdf = CandidateNamePDFDocument.new
    expect(pdf.plucked_bap_candidates.size).to eq(3)
    # should be sorted.
    expect(pdf.plucked_bap_candidates[0].first_name).to eq('cc1')
    expect(pdf.plucked_bap_candidates[1].first_name).to eq('cc2')
    expect(pdf.plucked_bap_candidates[2].first_name).to eq('cc3')
    pdf
  end

  describe 'other tests that dont generate the file' do
    it 'generate document name' do
      candidate = FactoryBot.create(:candidate)
      document_name = CandidatePDFDocument.document_name(Candidate.find(candidate.id))
      expect(document_name).to eq('2023-2024 Augusta Sophia.pdf')
    end
  end

  describe 'generates the pdf' do
    before do
      @candidate = FactoryBot.create(:candidate)
      AppFactory.add_confirmation_events
      File.open('spec/fixtures/files/Baptismal Certificate.pdf', 'rb') do |f|
        @candidate.baptismal_certificate.scanned_certificate =
          ScannedImage.new(
            filename: 'Baptismal Certificate.pdf',
            content_type: 'application/pdf',
            content: f.read
          )
      end
      File.open('spec/fixtures/files/Baptismal Certificate.pdf', 'rb') do |f|
        @candidate.retreat_verification.scanned_retreat =
          ScannedImage.new(
            filename: 'Baptismal Certificate.PDF',
            content_type: 'application/pdf',
            content: f.read
          )
      end
      @candidate.save
    end

    it 'generate a pdf with a pdf image and no traceback.' do
      AppFactory.add_confirmation_events
      CandidatePDFDocument.new(Candidate.find(@candidate.id))
    end
  end
end
