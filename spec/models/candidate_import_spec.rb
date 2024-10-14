# frozen_string_literal: true

describe CandidateImport do
  describe 'self methods' do
    it 'image columns' do
      ic = CandidateImport.image_columns
      %w[
        baptismal_certificate.scanned_certificate
        retreat_verification.scanned_retreat sponsor_covenant.scanned_covenant sponsor_eligibility.scanned_eligibility
      ].each do |column|
        expect(ic).to include(column)
      end
    end

    it 'transiet columns' do
      tc = CandidateImport.transient_columns
      %w[
        baptismal_certificate.certificate_picture
        baptismal_certificate.remove_certificate_picture
        retreat_verification.retreat_verification_picture
        retreat_verification.remove_retreat_verification_picture
        sponsor_covenant.sponsor_eligibility_picture
        sponsor_covenant.sponsor_covenant_picture
        sponsor_covenant.remove_sponsor_eligibility_picture
        sponsor_covenant.remove_sponsor_covenant_picture
      ].each do |column|
        expect(tc).to include(column)
      end
    end
  end
end
