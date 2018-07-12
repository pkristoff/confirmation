# frozen_string_literal: true

require 'rails_helper'

describe CandidatePDFDocument, type: :model do
  before(:each) do
    @candidate = FactoryBot.create(:candidate)
    AppFactory.add_confirmation_events
    File.open('spec/fixtures/Baptismal Certificate.pdf', 'rb') do |f|
      @candidate.baptismal_certificate.scanned_certificate =
        ScannedImage.new(
          filename: 'Baptismal Certificate.pdf',
          content_type: 'application/pdf',
          content: f.read
        )
    end
    File.open('spec/fixtures/Baptismal Certificate.pdf', 'rb') do |f|
      @candidate.retreat_verification.scanned_retreat =
        ScannedImage.new(
          filename: 'Baptismal Certificate.PDF',
          content_type: 'application/pdf',
          content: f.read
        )
    end
    @candidate.save
  end

  it 'should generate a pdf with a pdf image and no traceback.' do
    CandidatePDFDocument.new(Candidate.find(@candidate.id))
  end
end
