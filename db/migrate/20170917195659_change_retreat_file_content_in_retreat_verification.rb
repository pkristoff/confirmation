class ChangeRetreatFileContentInRetreatVerification < ActiveRecord::Migration
  def change
    rename_column :retreat_verifications, :retreat_file_content, :retreat_file_content_x
    add_column :retreat_verifications, :retreat_file_content, :binary
    Candidate.all.each do |candidate|
      unless candidate.retreat_verification.retreat_file_content_x.nil?
        candidate.retreat_verification.retreat_content_type = (candidate.retreat_verification.retreat_content_type_x)
      end
    end
    remove_column :retreat_verifications, :retreat_file_content_x
  end
end
