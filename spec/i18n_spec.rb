# frozen_string_literal: true

require 'i18n/tasks'

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it 'does not have missing keys' do
    # these are used in _error_messages.html.erb and defined in devise.en.  Do marking them not missing
    not_missing = %w[alert.reset_password
                     errors.messages.not_saved.one
                     errors.messages.not_saved.other
                     errors.messages.blank
                     errors.messages.account_name_not_found
                     errors.messages.reset_password
                     devise.mailer.reset_password_instructions.subject
                     devise.failure.unconfirmed
                     views.common.remember_me]
    y = missing_keys.keys.to_set.map {|arr| arr[0]}.select{|x| !not_missing.include? x}
    expect(y).to be_empty, "Missing #{y.count} i18n keys missing #{y}, (hint remove from  en.yml & es.yml) run `i18n-tasks missing' to show them"
  end

  it 'does not have unused keys' do
    used = %w[email.closing_input_label
              email.completed_awaiting_input_label
              email.from_input_label
              email.pre_coming_due_input_label
              email.pre_late_input_label
              email.reset_password_subject
              email.salutation_input_label
              views.admins.current_password
              views.candidates.account_name
              views.common.password_confirmation
              views.nav.email
              views.reset_db.reset_database.message
              views.reset_db.start_new_year.message
              views.top_bar.contact_admin_mail
              views.reset_db.reset_database.message
              views.reset_db.start_new_year.message
              views.top_bar.contact_admin_mail]
    y = unused_keys.keys.to_set.map {|arr| arr[0]}.select{|x| !used.include? x}
    puts "y=#{y}"
    expect(y).to be_empty, "#{y.size} unused i18n keys, run `i18n-tasks unused' to show them"
  end

  it 'files are normalized' do
    non_normalized = i18n.non_normalized_paths
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    "Please run `i18n-tasks normalize' to fix"
    expect(non_normalized).to be_empty, error_message
  end

  it 'does not have inconsistent interpolations' do
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Run `i18n-tasks check-consistent-interpolations' to show them"
    expect(inconsistent_interpolations).to be_empty, error_message
  end
end
