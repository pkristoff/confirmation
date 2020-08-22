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
    AppFactory.create_seed_candidate
    today = Time.zone.today
    ConfirmationEvent.find_each do |ce|
      ce.chs_due_date = today
      ce.the_way_due_date = today
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
    start_new_year

    remove_all_confirmation_events

    # save admin info because deleting all Admins
    admin = Admin.first
    contact_name = admin.contact_name
    contact_phone = admin.contact_phone
    admin_email = admin.email

    Admin.find_each(&:delete)

    # clean out Visitor
    Visitor.visitor('Change to home parish of confirmation',
                    'HTML for home page',
                    'HTML for about page',
                    'HTML for contact page')

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
    begin
      clazz.destroy_all
    rescue StandardError => e
      Rails.logger.info "cleaning association error when destroying #{clazz}"
      Rails.logger.info e.message
      Rails.logger.info e.backtrace.inspect
    end
    clazz.reflect_on_all_associations.each do |assoc|
      clean_associations(assoc.klass, checked)
    end
  end
end
