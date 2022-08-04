# frozen_string_literal: true

#
# Handles exporting to excel spread sheets.
#
class ExportListsController < ApplicationController
  # Baptized columns
  #
  # === Returns:
  #
  # * <tt>Array</tt> I18n strings
  #
  def self.baptism_columns
    [I18n.t('activerecord.attributes.baptismal_certificate.baptized_at_home_parish',
            home_parish: Visitor.home_parish),
     I18n.t('activerecord.attributes.baptismal_certificate.baptized_catholic'),
     'Show empty radio',
     I18n.t('activerecord.attributes.baptismal_certificate.birth_date'),
     I18n.t('activerecord.attributes.baptismal_certificate.baptismal_date'),
     I18n.t('activerecord.attributes.baptismal_certificate.father_first'),
     I18n.t('activerecord.attributes.baptismal_certificate.father_middle'),
     I18n.t('activerecord.attributes.baptismal_certificate.father_last'),
     I18n.t('activerecord.attributes.baptismal_certificate.mother_first'),
     I18n.t('activerecord.attributes.baptismal_certificate.mother_middle'),
     I18n.t('activerecord.attributes.baptismal_certificate.mother_maiden'),
     I18n.t('activerecord.attributes.baptismal_certificate.mother_last'),
     I18n.t('activerecord.attributes.baptismal_certificate.certificate_picture'),

     I18n.t('activerecord.attributes.baptismal_certificate.church_name'),
     I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.street_1'),
     I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.street_2'),
     I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.city'),
     I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.state'),
     I18n.t('activerecord.attributes.baptismal_certificate.church_address/address.zip_code'),

     I18n.t('activerecord.attributes.baptismal_certificate.prof_date'),
     I18n.t('activerecord.attributes.baptismal_certificate.prof_church_name'),
     I18n.t('activerecord.attributes.baptismal_certificate.prof_church_address/address.street_1'),
     I18n.t('activerecord.attributes.baptismal_certificate.prof_church_address/address.street_2'),
     I18n.t('activerecord.attributes.baptismal_certificate.prof_church_address/address.city'),
     I18n.t('activerecord.attributes.baptismal_certificate.prof_church_address/address.state'),
     I18n.t('activerecord.attributes.baptismal_certificate.prof_church_address/address.zip_code'),
     I18n.t('activerecord.attributes.baptismal_certificate.prof_picture')].freeze
  end

  BAPTISM_VALUES =
    [->(candidate) { candidate.baptismal_certificate.baptized_at_home_parish },
     ->(candidate) { candidate.baptismal_certificate.baptized_catholic },
     ->(candidate) { candidate.baptismal_certificate.show_empty_radio },
     ->(candidate) { candidate.baptismal_certificate.birth_date },
     ->(candidate) { candidate.baptismal_certificate.baptismal_date },
     ->(candidate) { candidate.baptismal_certificate.father_first },
     ->(candidate) { candidate.baptismal_certificate.father_middle },
     ->(candidate) { candidate.baptismal_certificate.father_last },
     ->(candidate) { candidate.baptismal_certificate.mother_first },
     ->(candidate) { candidate.baptismal_certificate.mother_middle },
     ->(candidate) { candidate.baptismal_certificate.mother_maiden },
     ->(candidate) { candidate.baptismal_certificate.mother_last },
     ->(candidate) { !candidate.baptismal_certificate.scanned_certificate.nil? },

     ->(candidate) { candidate.baptismal_certificate.church_name },
     ->(candidate) { candidate.baptismal_certificate.church_address.street_1 },
     ->(candidate) { candidate.baptismal_certificate.church_address.street_2 },
     ->(candidate) { candidate.baptismal_certificate.church_address.city },
     ->(candidate) { candidate.baptismal_certificate.church_address.state },
     ->(candidate) { candidate.baptismal_certificate.church_address.zip_code },

     ->(candidate) { candidate.baptismal_certificate.prof_date },
     ->(candidate) { candidate.baptismal_certificate.prof_church_name },
     ->(candidate) { candidate.baptismal_certificate.prof_church_address.street_1 },
     ->(candidate) { candidate.baptismal_certificate.prof_church_address.street_2 },
     ->(candidate) { candidate.baptismal_certificate.prof_church_address.city },
     ->(candidate) { candidate.baptismal_certificate.prof_church_address.state },
     ->(candidate) { candidate.baptismal_certificate.prof_church_address.zip_code },
     ->(candidate) { !candidate.baptismal_certificate.scanned_prof.nil? }].freeze

  # downloads pdf file with candidate name and scanned Bap Cert if ready to be verified.
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def bap_name
    pdf = CandidateNamePDFDocument.new
    send_data pdf.render,
              filename: CandidateNamePDFDocument.document_name,
              type: 'application/pdf'
  end

  # downloads spreadsheet for event baptism per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def baptism
    external, to_be_verified, verified, not_complete = Candidate.baptismal_external_verification

    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Baptized',
                    ExportListsController.baptism_columns,
                    ExportListsController::BAPTISM_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'baptized.xlsx'
  end

  CONFIRMATION_NAME_NAMES =
    [I18n.t('activerecord.attributes.pick_confirmation_name.saint_name')].freeze

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

  # columns for retreat
  #
  # === Returns:
  #
  # * <tt>Array</tt> I18n strings
  #
  def self.retreat_columns
    [I18n.t('activerecord.attributes.retreat_verification.retreat_held_at_home_parish', home_parish: Visitor.home_parish),
     I18n.t('activerecord.attributes.retreat_verification.start_date'),
     I18n.t('activerecord.attributes.retreat_verification.end_date'),
     I18n.t('activerecord.attributes.retreat_verification.who_held_retreat'),
     I18n.t('activerecord.attributes.retreat_verification.where_held_retreat')].freeze
  end

  RETREAT_VALUES =
    [->(candidate) { candidate.retreat_verification.retreat_held_at_home_parish },
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
                    ExportListsController.retreat_columns,
                    ExportListsController::RETREAT_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'retreat.xlsx'
  end

  SPONSOR_COVENANT_COLUMNS =
    [I18n.t('activerecord.attributes.sponsor_covenant.sponsor_name'),
     I18n.t('activerecord.attributes.sponsor_covenant.sponsor_covenant_picture')].freeze

  SPONSOR_COVENANT_VALUES =
    [->(candidate) { candidate.sponsor_covenant.sponsor_name },
     ->(candidate) { !candidate.sponsor_covenant.scanned_covenant.nil? }].freeze

  # downloads spreadsheet for event sponsor per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def sponsor_covenant
    external, to_be_verified, verified, not_complete = Candidate.sponsor_covenant_external_verification
    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Sponsor',
                    ExportListsController::SPONSOR_COVENANT_COLUMNS,
                    ExportListsController::SPONSOR_COVENANT_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'sponsor_covenant.xlsx'
  end

  # downloads spreadsheet for event sponsor per candidate
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def sponsor_eligibility
    external, to_be_verified, verified, not_complete = Candidate.sponsor_eligibility_external_verification
    p = create_xlsx(external, to_be_verified, verified, not_complete, 'Sponsor',
                    ExportListsController.sponsor_eligibility_columns,
                    ExportListsController::SPONSOR_ELIGIBILITY_VALUES)
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'sponsor_eligibility.xlsx'
  end

  # columns for sponsor eligibility
  #
  # === Returns:
  #
  # * <tt>send_data</tt> for spreadsheet
  #
  def self.sponsor_eligibility_columns
    [
      I18n.t('activerecord.attributes.sponsor_eligibility.sponsor_attends_home_parish',
             home_parish: Visitor.home_parish),
      I18n.t('activerecord.attributes.sponsor_covenant.sponsor_name'),
      I18n.t('activerecord.attributes.sponsor_eligibility.sponsor_church'),
      I18n.t('activerecord.attributes.sponsor_eligibility.sponsor_eligibility_picture')
    ].freeze
  end

  SPONSOR_ELIGIBILITY_VALUES =
    [
      ->(candidate) { candidate.sponsor_eligibility.sponsor_attends_home_parish },
      ->(candidate) { candidate.sponsor_covenant.sponsor_name },
      ->(candidate) { candidate.sponsor_eligibility.sponsor_church },
      ->(candidate) { !candidate.sponsor_eligibility.scanned_eligibility.nil? }
    ].freeze

  # returns an ordered list of events
  #
  def self.event_columns
    ConfirmationEvent.order(:event_key).map(&:event_key)
  end

  # returns the state of each event
  #
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
                    confirmation_event_names.map do |candidate_event_name|
                      ExportListsController.candidate_event_state(candidate_event_name)
                    end)

    send_data p.to_stream.read, type: 'application/xlsx', filename: 'events.xlsx'
  end

  # returns lambda which when called with candidate will return the CandidateEvent status of event_name
  #
  # === Parameters:
  #
  # * <tt>:event_key</tt> name of event
  #
  # === Returns:
  #
  # * <tt>Lambda</tt> when called with candidate will return the CandidateEvent status
  #
  def self.candidate_event_state(event_key)
    ->(candidate) { candidate.get_candidate_event(event_key).status }
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
      headers = [I18n.t('activerecord.attributes.candidate_sheet.first_name'),
                 I18n.t('activerecord.attributes.candidate_sheet.last_name')]
      extra_columns.each { |extra_column| headers.push(extra_column) }
      sheet.add_row(headers)
      candidates.each do |candidate|
        values = [candidate.candidate_sheet.first_name,
                  candidate.candidate_sheet.last_name]
        value_lambdas.each { |value_lambda| values.push(value_lambda.call(candidate)) }
        sheet.add_row(values)
      end
    end
  end
end
