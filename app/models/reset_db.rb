# frozen_string_literal: true

#
# A helper class used for importing and exporting the DB information.
#
class ResetDB
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  # Clear DB out for starting a new year.
  #
  def self.start_new_year
    ResetDB.new.start_new_year
  end

  # Clear DB out for starting a new year.
  #
  def start_new_year
    clean_associations(Candidate)
    Orphaneds.remove_orphaned_table_rows

    AppFactory.create_seed_candidate
    today = Time.zone.today
    ConfirmationEvent.find_each do |ce|
      ce.program_year2_due_date = today
      ce.program_year1_due_date = today
      ce.save
    end

    Rails.logger.info 'done start new year'
  end

  # Reset the database.  End up with only an admin + confirmation events and the candidate vickikristoff
  #
  def self.reset_database
    ResetDB.new.reset_database
  end

  # Reset the database.  End up with only an admin + confirmation events and the candidate vickikristoff
  #
  def reset_database
    # clean statuses out
    Status.find_each(&:destroy)
    # create_seed_statuses
    AppFactory.generate_default_status

    start_new_year

    remove_all_confirmation_events

    # save admin info because deleting all Admins
    admin = Admin.first
    contact_name = admin.contact_name
    contact_phone = admin.contact_phone
    admin_email = admin.email

    Admin.find_each(&:delete)

    # clean out Visitor
    Visitor.find_each(&:destroy)
    Visitor.create!(home_parish: 'Change to home parish of confirmation',
                    home: 'HTML for home page',
                    about: 'HTML for about page',
                    contact: 'HTML for contact page')

    AppFactory.add_confirmation_events

    AppFactory.generate_seed(contact_name, contact_phone, admin_email)
  end

  # Removes all ConfirmationEvent
  # public for TEST - Only
  #
  def remove_all_confirmation_events
    ConfirmationEvent.find_each(&:destroy)
  end

  private

  # Used to start a new year - cleans out tables for new year.
  #
  # === Parameters:
  #
  # * <tt>:clazz</tt> Class: class under consideration
  # * <tt>:checked</tt> Array: of class already checked
  # * <tt>:do_not_destroy</tt> Array: of class not to destroy table entries.
  #
  def clean_associations(clazz, checked = [], do_not_destroy = [Admin, ConfirmationEvent])
    return if (checked.include? clazz) || (do_not_destroy.include? clazz)

    checked << clazz
    return unless clazz == Candidate

    candidates_to_keep = []
    Candidate.all.find_each do |candidate|
      if Status.from_another_parish? candidate.status_id
        candidate.destroy
      elsif Status.confirmed_elsewhere? candidate.status_id
        candidate.destroy
      elsif Status.deferred? candidate.status_id
        candidate.status_id = Status.active.id
        candidate.candidate_sheet.grade += 1
        candidate.save
        candidates_to_keep.push(candidate)
      elsif Status.active? candidate.status_id
        if candidate.candidate_sheet.program_year == 1
          candidate.candidate_sheet.program_year = 2
          candidate.candidate_sheet.grade += 1
          candidate.save
          candidates_to_keep.push(candidate)
        else
          candidate.destroy
        end
      else
        clazz.destroy_all
      end
    rescue StandardError => e
      Rails.logger.info "cleaning association error when destroying #{clazz}"
      Rails.logger.info e.message
      Rails.logger.info e.backtrace.inspect
    end
  end
end
