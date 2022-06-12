# frozen_string_literal: true

require 'i18n/tasks'

RSpec.describe I18n do
  let(:i18n) { I18n::Tasks::BaseTask.new }
  let(:missing_keys) { i18n.missing_keys }
  let(:unused_keys) { i18n.unused_keys }
  let(:inconsistent_interpolations) { i18n.inconsistent_interpolations }

  it 'does not have missing keys' do
    # Look at ignore_missing in i18n-tasks.yml for a list of should be ignored
    puts "missing_keys=#{missing_keys.keys.map{|arr| arr}}" unless missing_keys.empty?
    expect(missing_keys).to be_empty, "#{missing_keys.size} missing i18n keys, run `i18n-tasks missing' to show them"
  end

  it 'does not have unused keys' do
    puts "unused_keys=#{unused_keys.keys.map{|arr| arr}}" unless unused_keys.empty?
    # Look at I18n-tasks.yml ignore_unused: if get an error and it is used.
    # This means the file(s) it is used in is not checked
    #
    # Look at ignore_unused in i18n-tasks.yml for a list of should be ignored
    expect(unused_keys).to be_empty, "#{unused_keys.size} unused i18n keys, run `i18n-tasks unused' to show them"
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
