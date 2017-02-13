FactoryGirl.define do
  factory :retreat_verification do
    retreat_held_at_stmm false
    start_date "2017-02-06"
    end_date "2017-02-06"
    who_held_retreat "I did"
    where_held_retreat "Here"
    retreat_filename 'actions.png'
    retreat_content_type 'type/pgn'
    retreat_file_content 'WWW'
  end
end
