class ChangeDefaultValueOfSponsorAttendsHomeParishInSponsorEligibilities < ActiveRecord::Migration[6.1]
  def change
    change_column_default :sponsor_eligibilities, :sponsor_attends_home_parish, from: true, to: false
    say "changing #{SponsorEligibility.count} sponsor_attends_home_parish defaults"
    Candidate.all.each do |cand|
      se = cand.sponsor_eligibility
      say "changing #{cand.account_name}"
      se.sponsor_attends_home_parish = false
      se.save
    end
  end
end
