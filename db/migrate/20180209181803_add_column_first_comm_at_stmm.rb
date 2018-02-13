# frozen_string_literal: true

#
# The candidate can now specify that they had First Communion at St MM, in which they don't have to supply there
# baptismal candidate.
#
class AddColumnFirstCommAtStmm < ActiveRecord::Migration
  def up
    add_column :baptismal_certificates, :first_comm_at_stmm, :boolean, null: false, default: false
    add_column :baptismal_certificates, :baptized_at_stmm, :boolean, null: false, default: false
    add_column :baptismal_certificates, :show_empty_radio, :integer, null: false, default: 0
    Candidate.find_each do |cand|
      bc = cand.baptismal_certificate
      Rails.logger.info("cand=#{cand.account_name} cand.baptized_at_stmm=#{cand.baptized_at_stmm}")
      bc.baptized_at_stmm = cand.baptized_at_stmm
      bc.first_comm_at_stmm = false
      if bc.baptized_at_stmm
        bc.show_empty_radio = 1
      else
        bc.show_empty_radio = 2
        unless bc.validate_other_info
          if bc.errors.full_messages.size == 12
            Rails.logger.info("  bc.errors.full_messages.size=#{bc.errors.full_messages.size}")
            bc.show_empty_radio = 0
          end
        end
      end
      Rails.logger.info("  baptized_at_stmm=#{bc.baptized_at_stmm}")
      Rails.logger.info("  first_comm_at_stmm=#{bc.first_comm_at_stmm}")
      Rails.logger.info("  show_empty_radio=#{bc.show_empty_radio}")
      cand.save(validate: false)
    end
    remove_column :candidates, :baptized_at_stmm
  end

  def down
    add_column :candidates, :baptized_at_stmm, :boolean, null: false, default: false
    Candidate.find_each do |cand|
      cand.baptized_at_stmm = cand.baptismal_certificate.baptized_at_stmm
      cand.save(validate: false)
    end
    remove_column :baptismal_certificates, :baptized_at_stmm
    remove_column :baptismal_certificates, :first_comm_at_stmm
    remove_column :baptismal_certificates, :show_empty_radio
  end
end
