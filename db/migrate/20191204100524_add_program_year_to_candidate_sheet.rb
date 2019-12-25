class AddProgramYearToCandidateSheet < ActiveRecord::Migration[5.2]
  def change
    add_column :candidate_sheets, :program_year, :decimal, precision: 1, default: 2, null: false
    Candidate.all.each do |cand|
      cand.candidate_sheet.program_year = 2
    end
  end
end
