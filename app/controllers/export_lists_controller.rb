class ExportListsController < ApplicationController

  def baptism
    candidates = Candidate.order(:account_name).select do |candidate|
      Candidate.baptismal_external_verification?(candidate)
    end

    p = create_xlsx(candidates, 'Baptized')
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'baptized.xlsx'
  end

  def retreat
    candidates = Candidate.order(:account_name).select do |candidate|
      Candidate.retreat_external_verification?(candidate)
    end

    p = create_xlsx(candidates, 'Retreat')
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'retreat.xlsx'
  end

  def sponsor
    candidates = Candidate.order(:account_name).select do |candidate|
      Candidate.sponsor_external_verification?(candidate)
    end

    p = create_xlsx(candidates, 'Sponsor',
                    [I18n.t('label.sponsor_covenant.sponsor_name')],
                    [lambda {|candidate| candidate.sponsor_covenant.sponsor_name}])
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'sponsor.xlsx'
  end

  def events
    candidates = Candidate.order(:account_name).select do |candidate|
      Candidate.events_external_verification?(candidate)
    end

    confirmation_even_names = ConfirmationEvent.order(:name).map {|candidate_event| candidate_event.name}
    p = create_xlsx(candidates, 'Events',
                    confirmation_even_names,
                    confirmation_even_names.map {|candidate_event_name| candidate_event_state(candidate_event_name)})
    send_data p.to_stream.read, type: 'application/xlsx', filename: 'events.xlsx'
  end

  def candidate_event_state(event_name)
    lambda {|candidate| candidate.get_candidate_event(event_name).status}
  end

  def create_xlsx(candidates, sheet_name, extra_columns=[], value_lambdas=[])
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    wb.add_worksheet(name: sheet_name) do |sheet|
      headers = [I18n.t('label.candidate_sheet.first_name'), I18n.t('label.candidate_sheet.last_name')]
      extra_columns.each {|extra_column| headers.push(extra_column)}
      sheet.add_row(headers)
      candidates.each do |candidate|
        values = [candidate.candidate_sheet.first_name,
                 candidate.candidate_sheet.last_name]
        value_lambdas.each {|value_lambda| values.push(value_lambda.call(candidate))}
        sheet.add_row(values)
      end
    end
    p
  end

end
