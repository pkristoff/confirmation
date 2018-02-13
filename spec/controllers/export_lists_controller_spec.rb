describe ExportListsController do

  before(:each) do

    c1 = FactoryBot.create(:candidate, account_name: 'c1')
    c1.candidate_sheet.first_name = 'Paul'
    c1.candidate_sheet.last_name = 'Kristoff'
    c1.sponsor_covenant.sponsor_name = 'George'
    c1.save
    c2 = FactoryBot.create(:candidate, account_name: 'c2')
    c2.candidate_sheet.first_name = 'Vicki'
    c2.candidate_sheet.last_name = 'Kristoff'
    c2.sponsor_covenant.sponsor_name = 'Wilma'
    c2.save

    AppFactory.add_confirmation_events

    @c1 = Candidate.find_by_account_name(c1.account_name)
    @c2 = Candidate.find_by_account_name(c2.account_name)
  end

  it 'should create an xlsx' do

    package = controller.create_xlsx([@c1, @c2], 'foo')

    expect(package.core.creator).to eq('Admin')
    check_workbook(package)
  end

  it 'should create an xlsx with extra columns' do

    column_name = I18n.t('label.sponsor_covenant.sponsor_name')

    package = controller.create_xlsx([@c1, @c2], 'foo', [column_name], [lambda {|candidate| candidate.sponsor_covenant.sponsor_name}])

    expect(package.core.creator).to eq('Admin')
    check_workbook(package, column_name, ['George', 'Wilma'])
  end

  it 'should return a xlxs Baptized attachment' do
    @c1.baptismal_certificate.baptized_at_stmm = true
    @c1.get_candidate_event(I18n.t('events.baptismal_certificate')).completed_date = Date.today
    @c1.save

    expect_send_data([@c1], 'Baptized', 'baptized.xlsx', :baptism)
  end

  it 'should return a xlxs retreat attachment' do
    @c1.retreat_verification.retreat_held_at_stmm = true
    @c1.get_candidate_event(I18n.t('events.retreat_verification')).completed_date = Date.today
    @c1.save

    expect_send_data([@c1], 'Retreat', 'retreat.xlsx', :retreat)
  end

  it 'should return a xlxs sponsor attachment' do
    @c1.sponsor_covenant.sponsor_attends_stmm = true
    @c1.get_candidate_event(I18n.t('events.sponsor_covenant')).completed_date = Date.today
    @c1.save

    expect_send_data([@c1], 'Sponsor', 'sponsor.xlsx', :sponsor,
                     [I18n.t('label.sponsor_covenant.sponsor_name')],
                     [lambda {|candidate| candidate.sponsor_covenant.sponsor_name}])
  end

  it 'should return a xlxs event attachment' do

    expect_send_data([@c1, @c2], 'Events', 'events.xlsx', :events,
                     [I18n.t('events.retreat_verification'), I18n.t('events.baptismal_certificate'), I18n.t('events.candidate_covenant_agreement'),
                      I18n.t('events.candidate_information_sheet'), I18n.t('events.christian_ministry'), I18n.t('events.confirmation_name'),
                      I18n.t('events.parent_meeting'), I18n.t('events.sponsor_covenant'), I18n.t('events.sponsor_agreement')],
                     [expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due')), expected_value_function(I18n.t('status.coming_due'))])
  end

end

def expected_value_function(status_name)
  lambda { |candidate| status_name }
end

def check_workbook(package, extra_colum=nil, column_values=nil)
  package.workbook do |wb|
    expect(wb.worksheets.size).to eq(1)
    ws = wb.worksheets.first
    expect(ws.name).to eq('foo')
    expect(ws.rows.size).to eq(3)
    # header
    header = ws.rows.first
    number_of_columns = 2 + (extra_colum.nil? ? 0 : 1)
    expect(header.cells.size).to eq(number_of_columns)
    expect(header.cells[0].value).to eq('First name')
    expect(header.cells[1].value).to eq('Last name')
    expect(header.cells[2].value).to eq(extra_colum) unless extra_colum.nil?
    # data
    first_row = ws.rows.second
    expect(first_row.cells.size).to eq(number_of_columns)
    expect(first_row.cells[0].value).to eq('Paul')
    expect(first_row.cells[1].value).to eq('Kristoff')
    expect(first_row.cells[2].value).to eq(column_values[0]) unless extra_colum.nil?

    second_row = ws.rows.third
    expect(second_row.cells.size).to eq(number_of_columns)
    expect(second_row.cells[0].value).to eq('Vicki')
    expect(second_row.cells[1].value).to eq('Kristoff')
    expect(second_row.cells[2].value).to eq(column_values[1]) unless extra_colum.nil?
  end
end


def expect_send_data(candidates, sheet_name, filename, route, extra_columns=[], functs=[])
  xlsx = controller.create_xlsx(candidates, sheet_name, extra_columns, functs)
  xlxs_data = xlsx.to_stream.read
  xlxs_options = {type: 'application/xlsx', filename: filename}

  expect(controller).to receive(:send_data).with(xlxs_data, xlxs_options) {
    controller.render nothing: true # to prevent a 'missing template' error
  }

  get route
end

