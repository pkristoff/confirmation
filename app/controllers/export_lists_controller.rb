# frozen_string_literal: true

#
# Handles exporting to excel spread sheets.
#
class ExportListsController < ApplicationController
  BAPTISM_COLUMNS =
    [I18n.t('label.baptismal_certificate.baptismal_certificate.baptized_at_stmm'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.first_comm_at_stmm'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.birth_date'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.baptismal_date'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.father_first'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.father_middle'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.father_last'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.mother_first'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.mother_middle'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.mother_maiden'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.mother_last'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.street_1'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.street_2'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.city'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.state'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.church_address.zip_code'),
     I18n.t('label.baptismal_certificate.baptismal_certificate.certificate_picture')].freeze

  BAPTISM_VALUES =
    [->(candidate) { candidate.baptismal_certificate.baptized_at_stmm },
     ->(candidate) { candidate.baptismal_certificate.first_comm_at_stmm },
     ->(candidate) { candidate.baptismal_certificate.birth_date },
     ->(candidate) { candidate.baptismal_certificate.baptismal_date },
     ->(candidate) { candidate.baptismal_certificate.father_first },
     ->(candidate) { candidate.baptismal_certificate.father_middle },
     ->(candidate) { candidate.baptismal_certificate.father_last },
     ->(candidate) { candidate.baptismal_certificate.mother_first },
     ->(candidate) { candidate.baptismal_certificate.mother_middle },
     ->(candidate) { candidate.baptismal_certificate.mother_maiden },
     ->(candidate) { candidate.baptismal_certificate.mother_last },
     ->(candidate) { candidate.baptismal_certificate.church_address.street_1 },
     ->(candidate) { candidate.baptismal_certificate.church_address.street_2 },
     ->(candidate) { candidate.baptismal_certificate.church_address.city },
     ->(candidate) { candidate.baptismal_certificate.church_address.state },
     ->(candidate) { candidate.baptismal_certificate.church_address.zip_code },
     ->(candidate) { !candidate.baptismal_certificate.scanned_certificate.nil? }].freeze

  # downloads spreadsheet for event baptism per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def baptism
    external, to_be_verified, verified, not_complete = Candidate.baptismal_external_verification

    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Baptized',
                    ExportListsController::BAPTISM_COLUMNS,
                    ExportListsController::BAPTISM_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'baptized.xlsx'
  end

  CONFIRMATION_NAME_NAMES =
    [I18n.t('label.confirmation_name.saint_name')].freeze

  CONFIRMATION_NAME_VALUES =
    [->(candidate) { candidate.pick_confirmation_name.saint_name }].freeze

  # downloads spreadsheet for event confirmation name per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def confirmation_name
    external, to_be_verified, verified, not_complete = Candidate.confirmation_name_external_verification
    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Confirm Names',
                    ExportListsController::CONFIRMATION_NAME_NAMES,
                    ExportListsController::CONFIRMATION_NAME_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'confirmation_name.xlsx'
  end

  RETREAT_COLUMNS =
    [I18n.t('label.retreat_verification.retreat_held_at_stmm'),
     I18n.t('label.retreat_verification.start_date'),
     I18n.t('label.retreat_verification.end_date'),
     I18n.t('label.retreat_verification.who_held_retreat'),
     I18n.t('label.retreat_verification.where_held_retreat')].freeze

  RETREAT_VALUES =
    [->(candidate) { candidate.retreat_verification.retreat_held_at_stmm },
     ->(candidate) { candidate.retreat_verification.start_date },
     ->(candidate) { candidate.retreat_verification.end_date },
     ->(candidate) { candidate.retreat_verification.who_held_retreat },
     ->(candidate) { candidate.retreat_verification.where_held_retreat }].freeze

  # downloads spreadsheet for event retreat per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def retreat
    external, to_be_verified, verified, not_complete = Candidate.retreat_external_verification

    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Retreat',
                    ExportListsController::RETREAT_COLUMNS,
                    ExportListsController::RETREAT_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'retreat.xlsx'
  end

  SPONSOR_COLUMNS =
    [I18n.t('label.sponsor_covenant.sponsor_attends_stmm'),
     I18n.t('label.sponsor_covenant.sponsor_name'),
     I18n.t('label.sponsor_covenant.sponsor_church'),
     I18n.t('label.sponsor_covenant.sponsor_eligibility_picture')].freeze

  SPONSOR_VALUES =
    [->(candidate) { candidate.sponsor_covenant.sponsor_attends_stmm },
     ->(candidate) { candidate.sponsor_covenant.sponsor_name },
     ->(candidate) { candidate.sponsor_covenant.sponsor_church },
     ->(candidate) { !candidate.sponsor_covenant.scanned_eligibility.nil? }].freeze

  # downloads spreadsheet for event sponsor per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def sponsor
    external, to_be_verified, verified, not_complete = Candidate.sponsor_external_verification
    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Sponsor',
                    ExportListsController::SPONSOR_COLUMNS,
                    ExportListsController::SPONSOR_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'sponsor.xlsx'
  end

  def self.event_columns
    ConfirmationEvent.order(:name).map(&:name)
  end

  def self.event_values
    ExportListsController.event_columns.map { |candidate_event_name| candidate_event_state(candidate_event_name) }
  end

  # downloads spreadsheet for event status per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def events
    external, to_be_verified, verified, not_complete = Candidate.events_external_verification

    confirmation_event_names = ExportListsController.event_columns
    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Events',
                    confirmation_event_names,
                    confirmation_event_names.map { |candidate_event_name| ExportListsController.candidate_event_state(candidate_event_name) })
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'events.xlsx'
  end

  # returns lambda which when called with candidate will return the CandidateEvent status of event_name
  #
  # === Parameters:
  #
  # * <tt>:event_name</tt> name of event
  #
  # === Returns:
  #
  # Lambda - when called with candidate will return the CandidateEvent status
  #
  def self.candidate_event_state(event_name)
    ->(candidate) { candidate.get_candidate_event(event_name).status }
  end

  # creates spreadsheet with four worksheets showing event information
  #
  # === Parameters:
  #
  # * <tt>:external_verify</tt> List of candidates needing verification outside of system
  # * <tt>:verify</tt> List of candidates needing verification by admin
  # * <tt>:verified</tt> List of candidates already verified
  # * <tt>:not_complete</tt> List of candidates needing more work
  # * <tt>:pre_title</tt> prefix for worksheet name
  # * <tt>:extra_columns</tt> list of columns to be shown
  # * <tt>:value_lambdas</tt> list of values for extra_columns
  #
  # === Returns:
  #
  # * <tt>Axlsx::Package</tt>
  #
  def create_xlsx(external_verify, verify, verified, not_complete, pre_title, extra_columns = [], value_lambdas = [])
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    add_wb(wb, external_verify, "#{pre_title} Externally Verify", extra_columns, value_lambdas)
    add_wb(wb, verify, "#{pre_title} Verify", extra_columns, value_lambdas)
    add_wb(wb, verified, "#{pre_title} Verified", extra_columns, value_lambdas)
    add_wb(wb, not_complete, "#{pre_title} Not Complete", extra_columns, value_lambdas)
    p
  end

  protected

  def add_wb(wbk, candidates, title, extra_columns, value_lambdas)
    wbk.add_worksheet(name: title) do |sheet|
      headers = [I18n.t('label.candidate_sheet.first_name'), I18n.t('label.candidate_sheet.last_name')]
      extra_columns.each { |extra_column| headers.push(extra_column) }
      sheet.add_row(headers)
      candidates.each do |candidate|
        # puts "#{title}: #{candidate.account_name}"
        values = [candidate.candidate_sheet.first_name,
                  candidate.candidate_sheet.last_name]
        value_lambdas.each { |value_lambda| values.push(value_lambda.call(candidate)) }
        sheet.add_row(values)
      end
    end
  end
end
