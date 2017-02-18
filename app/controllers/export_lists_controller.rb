class ExportListsController < ApplicationController

  def baptism
    candidates = Candidate.select do |candidate|
      Candidate.baptismal_external_verification?(candidate)
    end

    p = create_xlsx(candidates, 'Baptized')
    send_data p.to_stream.read, type: "application/xlsx", filename: "baptized.xlsx"
  end

  def retreat
    candidates = Candidate.select do |candidate|
      Candidate.retreat_external_verification?(candidate)
    end

    p = create_xlsx(candidates, 'Retreat')
    send_data p.to_stream.read, type: "application/xlsx", filename: "retreat.xlsx"
  end

  def sponsor
    candidates = Candidate.select do |candidate|
      Candidate.sponsor_external_verification?(candidate)
    end

    p = create_xlsx(candidates, 'Sponsor',
                    I18n.t('label.sponsor_covenant.sponsor_name'),
                    lambda {|candidate| candidate.sponsor_covenant.sponsor_name})
    send_data p.to_stream.read, type: "application/xlsx", filename: "sponsor.xlsx"
  end

  def create_xlsx(candidates, sheet_name, extra_column=nil, value=nil)
    p = Axlsx::Package.new(author: 'Admin')
    wb = p.workbook
    wb.add_worksheet(name: sheet_name) do |sheet|
      headers = [I18n.t('label.candidate_sheet.first_name'), I18n.t('label.candidate_sheet.last_name')]
      headers.push(extra_column) unless extra_column.nil?
      sheet.add_row(headers)
      candidates.each do |candidate|
        values = [candidate.candidate_sheet.first_name,
                 candidate.candidate_sheet.last_name]
        values.push(value.call(candidate)) unless value.nil?
        sheet.add_row(values)
      end
    end
    p
  end

end
