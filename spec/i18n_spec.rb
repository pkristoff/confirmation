# frozen_string_literal: true

require 'i18n/tasks'

RSpec.describe 'I18n' do
  before(:each) do
    @i18n = I18n::Tasks::BaseTask.new
    @missing_keys = @i18n.missing_keys(locales: ['en']).key_names
    @unused_keys = @i18n.unused_keys(locales: ['en'])
    # these keys are used even though this says otherwise.
    # email... are used via MailPart.i18n_label
    @used_keys = %w[
        email.closing_input_label
        email.completed_awaiting_input_label
        email.from_input_label
        email.pre_coming_due_input_label
        email.pre_late_input_label
        email.salutation_input_label
        views.admins.current_password
        views.candidates.account_name
        views.candidates.parent_email_1
        views.common.password_confirmation
        views.top_bar.contact_admin_mail
    ].to_set
  end

  it 'all locale files should have the same keys' do
    [['en.yml', 'es.yml'], ['devise.en.yml', 'devise.es.yml'], ['rails.en.yml', 'rails.es.yml']].each do |pairs|
      en_file = File.join(Rails.root, 'config', 'locales', pairs[0])
      es_file = File.join(Rails.root, 'config', 'locales', pairs[1])
      YAML.load(File.open(en_file)).each do |en_key, en_value|
        YAML.load(File.open(es_file)).each do |es_key, es_value|
          expect(en_key).to eq('en')
          expect(es_key).to eq('es')
          compare_locale_files(en_key, en_value, es_value)
        end
      end
    end
  end

  def compare_locale_files(en_key, en_value, es_value)
    expect(es_value.is_a? String).to eq(true) if (en_value.is_a? String)
    unless en_value.is_a? String
      expect(en_value.count).to eq(es_value.count), "key: #{en_key} English count diff: #{en_value} \n from Spanish #{es_value}"
      en_value.each do |val_en_key, en_val|
        es_val = es_value[val_en_key]
        compare_locale_files(val_en_key, en_val, es_val) if val_en_key.is_a? Hash
      end
    end
  end

  it 'does not have missing keys' do
    # these are used in _error_messages.html.erb and defined in devise.en.  Do marking them not missing
    not_missing = %w[errors.messages.not_saved.one
                     errors.messages.not_saved.other
                     errors.messages.blank
                     devise.mailer.reset_password_instructions.subject
                     devise.failure.unconfirmed
                     views.common.remember_me]
    y = @missing_keys - not_missing
    expect(y).to be_empty, "Missing #{y.count} i18n keys missing #{y}, run `i18n-tasks missing' to show them"
  end

  it 'does not have unused keys' do
    unused_key_names = @unused_keys.key_names
    # expect(unused_key_names.count).to eq(used_keys.count)
    # puts "@used_keys=#{@used_keys}"
    # puts "unused_key_names=#{unused_key_names}"
    xxx = @used_keys - unused_key_names
    puts "used_keys#{xxx}" unless xxx.empty?
    expect(xxx).to be_empty
  end

  it 'files are normalized' do
    non_normalized = @i18n.non_normalized_paths
    error_message = "The following files need to be normalized:\n" \
                    "#{non_normalized.map { |path| "  #{path}" }.join("\n")}\n" \
                    'Please run `i18n-tasks normalize` to fix'
    expect(non_normalized).to be_empty, error_message
  end
end
