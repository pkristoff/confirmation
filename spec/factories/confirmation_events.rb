FactoryBot.define do
  factory :confirmation_event do
    name "Going out to eat"
    the_way_due_date "2016-05-31"
    chs_due_date "2016-05-24"
    instructions '<h3>Do this</h3><ul><li>one</li><li>two</li><li>three</li></ul></h3>'
  end
end
