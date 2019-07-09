# frozen_string_literal: true

require 'i18n/tasks'

RSpec.describe 'I18n' do
  let(:i18n) {I18n::Tasks::BaseTask.new}
  let(:missing_keys) {i18n.missing_keys}
  let(:unused_keys) {i18n.unused_keys}
  # these keys are used even though this says otherwise.
  # email... are used via MailPart.i18n_label
  let(:used_keys) {%w[
        email.closing_input_label
        email.completed_awaiting_input_label
        email.from_input_label
        email.pre_coming_due_input_label
        email.pre_late_input_label
        email.salutation_input_label
        label.candidate_event.select
        views.admins.current_password
        views.admins.email
        views.candidates.account_name
        views.candidates.first_name
        views.candidates.last_name
        views.candidates.middle_name
        views.candidates.parent_email_1
        views.common.password
        views.common.password_confirmation
        views.top_bar.contact_admin_mail
    ].to_set
  }

  it 'does not have missing keys' do
    # these are used in _error_messages.html.erb and defined in devise.en.  Do marking them not missing
    notMissing = ['en.errors.messages.not_saved.one', 'en.errors.messages.not_saved.other']
    y = missing_keys.subtract_keys(notMissing)
    expect(y).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  it 'does not have unused keys' do
    unused_key_names = unused_keys.key_names
    # expect(unused_key_names.count).to eq(used_keys.count)
    used_keys.select! do |used_key|
      unused_key_names.delete(used_key).nil?
    end
    puts "used_keys=#{used_keys}" unless used_keys.empty?
    expect(used_keys).to be_empty,
                         "#{used_keys.count} unused i18n keys, run `i18n-tasks unused' to show them"
    puts "unused_key_names=#{unused_key_names}" unless unused_key_names.empty?
    expect(unused_key_names).to be_empty,
                                "#{unused_key_names.count} unused i18n keys, run `i18n-tasks unused' to show them"
  end

  it 'files are normalized' do
    non_normalized = i18n.non_normalized_paths
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map {|path| "  #{path}"}.join("\n")}\n" \
                    'Please run `i18n-tasks normalize` to fix'
    expect(non_normalized).to be_empty, error_message
  end
end
