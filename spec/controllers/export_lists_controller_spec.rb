# frozen_string_literal: true

describe ExportListsController do
  before(:each) do
    FactoryBot.create(:visitor)

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

    @c1 = Candidate.find_by(account_name: c1.account_name)
    @c2 = Candidate.find_by(account_name: c2.account_name)

    @today = Time.zone.today
  end

  it 'should create an xlsx' do
    package = controller.create_xlsx([], [@c1, @c2], [], [], 'foo')

    expect(package.core.creator).to eq('Admin')
    check_workbook(package)
  end

  it 'should create an xlsx with extra columns' do
    column_name = I18n.t('label.sponsor_covenant.sponsor_name')

    package = controller.create_xlsx([], [@c1, @c2], [], [], 'foo', [column_name],
                                     [->(candidate) { candidate.sponsor_covenant.sponsor_name }])

    expect(package.core.creator).to eq('Admin')
    check_workbook(package, column_name, %w[George Wilma])
  end

  it 'should return a xlxs Baptized attachment' do
    @c1.baptismal_certificate.baptized_at_home_parish = true
    @c1.get_candidate_event(BaptismalCertificate.event_key).completed_date = @today
    @c1.save

    expect_send_data([@c1], [], [], [@c2], 'Baptized', 'baptized.xlsx', :baptism,
                     ExportListsController.baptism_columns,
                     ExportListsController::BAPTISM_VALUES)
  end

  it 'should return a xlxs retreat attachment' do
    @c1.retreat_verification.retreat_held_at_home_parish = true
    @c1.get_candidate_event(RetreatVerification.event_key).completed_date = @today
    @c1.save

    expect_send_data([@c1], [], [], [@c2], 'Retreat', 'retreat.xlsx', :retreat,
                     ExportListsController.retreat_columns,
                     ExportListsController::RETREAT_VALUES)
  end

  it 'should return a xlxs confirmation name attachment' do
    @c1.pick_confirmation_name.saint_name = 'Paul'
    @c1.get_candidate_event(PickConfirmationName.event_key).completed_date = @today
    @c1.save

    expect_send_data([], [@c1], [], [@c2], 'Confirm Names', 'confirmation_name.xlsx', :confirmation_name,
                     ExportListsController::CONFIRMATION_NAME_NAMES,
                     ExportListsController::CONFIRMATION_NAME_VALUES)
  end

  it 'should return a xlxs sponsor covenant attachment' do
    @c1.get_candidate_event(SponsorCovenant.event_key).completed_date = @today
    @c1.save
    expect_send_data([], [@c1], [], [@c2], 'Sponsor', 'sponsor_covenant.xlsx', :sponsor_covenant,
                     ExportListsController::SPONSOR_COVENANT_COLUMNS,
                     ExportListsController::SPONSOR_COVENANT_VALUES)
  end

  it 'should return a xlxs sponsor eligibility attachment' do
    @c1.sponsor_eligibility.sponsor_attends_home_parish = true
    @c1.get_candidate_event(SponsorEligibility.event_key).completed_date = @today
    @c1.save
    expect_send_data([@c1], [], [], [@c2], 'Sponsor', 'sponsor_eligibility.xlsx', :sponsor_eligibility,
                     ExportListsController.sponsor_eligibility_columns,
                     ExportListsController::SPONSOR_ELIGIBILITY_VALUES)
  end

  it 'should return a xlxs event attachment' do
    expect_send_data([], [@c1, @c2], [], [], 'Events', 'events.xlsx', :events,
                     ExportListsController.event_columns,
                     ExportListsController.event_values)
  end
end

private

def expected_value_function(status_name)
  ->(_candidate) { status_name }
end

def check_workbook(package, extra_colum = nil, column_values = nil)
  package.workbook do |wb|
    expect(wb.worksheets.size).to eq(4)
    ['Externally Verify', 'Verify', 'Verified', 'Not Complete'].each_with_index do |str, i|
      expect(wb.worksheets[i].name).to eq("foo #{str}")
    end
    ws = wb.worksheets.second
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

def expect_send_data(external,
                     to_be_verified,
                     verified,
                     not_complete,
                     pre_title,
                     filename,
                     route,
                     extra_columns = [],
                     functs = [])
  xlsx = controller.create_xlsx(external, to_be_verified, verified, not_complete, pre_title, extra_columns, functs)
  xlxs_data = xlsx.to_stream.read
  xlxs_options = { type: 'application/xlsx', filename: filename }

  expect(controller).to receive(:send_data).with(xlxs_data, xlxs_options) do
  end

  post route
end
