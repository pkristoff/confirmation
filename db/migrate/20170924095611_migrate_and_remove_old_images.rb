class MigrateAndRemoveOldImages < ActiveRecord::Migration
  def change

    SponsorCovenant.all.each do |sc|
      unless sc.sponsor_elegibility_filename.nil?
        puts "SponsorCovenant sc.sponsor_elegibility_filename=#{sc.sponsor_elegibility_filename}"
        sc.scanned_eligibility = ::ScannedImage.new(
            filename: sc.sponsor_elegibility_filename,
            content_type: sc.sponsor_elegibility_content_type,
            content: sc.sponsor_elegibility_file_contents
        )
        sc.save
      end
      unless sc.sponsor_covenant_filename.nil?
        puts "SponsorCovenant sc.sponsor_covenant_filename=#{sc.sponsor_covenant_filename}"
        sc.scanned_covenant = ::ScannedImage.new(
            filename: sc.sponsor_covenant_filename,
            content_type: sc.sponsor_covenant_content_type,
            content: sc.sponsor_covenant_file_contents
        )
        sc.save
      end
    end

    RetreatVerification.all.each do |rv|
      puts "RetreatVerification rv.retreat_filename=#{rv.retreat_filename}"
      unless rv.retreat_filename.nil?
        rv.scanned_retreat = ::ScannedImage.new(
            filename: rv.retreat_filename,
            content_type: rv.retreat_content_type,
            content: rv.retreat_file_content
        )
        rv.save
      end
    end

    BaptismalCertificate.all.each do |bc|
      unless bc.certificate_filename.nil?
        puts "BaptismalCertificate bc.certificate_filename=#{bc.certificate_filename}"
        bc.scanned_certificate = ::ScannedImage.new(
            filename: bc.certificate_filename,
            content_type: bc.certificate_content_type,
            content: bc.certificate_file_contents
        )
        bc.save
      end
    end

    remove_column(:baptismal_certificates, :certificate_filename, :string)
    remove_column(:baptismal_certificates, :certificate_content_type, :string)
    remove_column(:baptismal_certificates, :certificate_file_contents, :binary)

    remove_column(:retreat_verifications, :retreat_filename, :string)
    remove_column(:retreat_verifications, :retreat_content_type, :string)
    remove_column(:retreat_verifications, :retreat_file_content, :binary)

    remove_column(:sponsor_covenants, :sponsor_elegibility_filename, :string)
    remove_column(:sponsor_covenants, :sponsor_elegibility_content_type, :string)
    remove_column(:sponsor_covenants, :sponsor_elegibility_file_contents, :binary)

    remove_column(:sponsor_covenants, :sponsor_covenant_filename, :string)
    remove_column(:sponsor_covenants, :sponsor_covenant_content_type, :string)
    remove_column(:sponsor_covenants, :sponsor_covenant_file_contents, :binary)

  end
end
