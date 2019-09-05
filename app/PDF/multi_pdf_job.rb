# frozen_string_literal: true

require 'rubygems'
require 'zip'

class MultiPDFJob
  include FileHelper
  include SuckerPunch::Job

  def perform(candidate, run_name, zip_file)
    Rails.logger.info("starting MultiPDFJob for #{candidate.id}: #{candidate.account_name}")
    # Rails.logger.info("stats=#{sucker_stats}")

    pdf = CandidatePDFDocument.new(candidate)
    pdf_filename = "#{pdf.document_name}".downcase
    pdf_file_path = Rails.root.join("public/pdfs/#{pdf_filename}")
    File.delete(pdf_file_path) if File.exists?(pdf_file_path)
    File.open(pdf_file_path, 'wb') do |f|
      f.write(pdf.render)
    end
    # Two arguments:
    # - The name of the file as it will appear in the archive
    # - The original file, including the path to find it
    zip_file.add(pdf_filename, pdf_file_path)
    Rails.logger.info("ending MultiPDFJob for #{candidate.id}")
  end

  def self.jobs_left?(expected_num_ofjobs)
    all_stats = SuckerPunch::Queue.stats
    stats = all_stats[MultiPDFJob.to_s]
    return false if stats.nil?
    Rails.logger.info("stats=#{stats}")
    stats['jobs']['processed'] + stats['jobs']['failed'] < expected_num_ofjobs
    # workers = stats['workers']
    # workers['idle'] == 0 && workers['busy'] == 0
  end

  def self.generate_pdfs candidates, admin
    archive_filename = "pdfs_#{Time.zone.now.to_s}.zip"
    archive_folder = Rails.root.join(archive_filename) #Location to save the zip

    # Delte .zip folder if it's already there
    FileUtils.rm_rf(archive_folder)

    # Open the zipfile
    Zip::File.open(archive_folder, Zip::File::CREATE) do |zip_file|
      candidates.each do |cand|
        ::MultiPDFJob.new.perform cand, 'run_name', zip_file
        # ::MultiPDFJob.perform_async cand, 'run_name', zip_file
      end
    end
    [archive_folder, archive_filename]
  end
end
