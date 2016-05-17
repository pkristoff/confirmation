describe 'candidates/index.html.erb' do

  before(:each) do

    @candidate1 = FactoryGirl.create(:candidate)
    @candidate2 = FactoryGirl.create(:candidate, {
        candidate_id: 'vickikristoff',
        first_name: 'Sophia',
        last_name: 'Agusta',
        parent_email_1: 'other@test.com',
        grade: 11,
        attending: 'Catholic High School'})

  end

  #http://stackoverflow.com/questions/10503802/how-can-i-check-that-a-form-field-is-prefilled-correctly-using-capybara
  #https://gist.github.com/steveclarke/2353100

  it 'Form layout 0' do

    assign(:candidates, [])

    render

    expect(rendered).to have_css("table#candidates_table tr", :count => 0)

  end

  it 'Form layout 1' do

    assign(:candidates, [@candidate2])

    render

    expect(rendered).to have_css("table#candidates_table tr", :count => 1)

    expect_candidate(rendered, 1, @candidate2)
  end

  it 'Form layout 2' do

    assign(:candidates, [@candidate1, @candidate2])

    render

    expect(rendered).to have_css("table#candidates_table tr", :count => 2)

    expect_candidate(rendered, 1, @candidate1)
    expect_candidate(rendered, 2, @candidate2)
  end

  private

  def expect_candidate (rendered, row, candidate)

    expect(rendered).to have_css("table#candidates_table tbody tr:nth-of-type(#{row}) td", :count => 9)
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(1)", text: 'Delete')
    expect(rendered).to have_link('Delete', href: "/candidates/#{candidate.id}")

    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(2)", text: candidate.candidate_id)
    expect(rendered).to have_link(candidate.candidate_id, href: "/candidates/#{candidate.id}/edit")
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(3)", text: candidate.first_name)
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(4)", text: candidate.last_name)
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(5)", text: candidate.attending)
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(6)", text: candidate.grade)
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(7)", text: candidate.candidate_email)
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(8)", text: candidate.parent_email_1)
    expect(rendered).to have_selector("table#candidates_table tbody tr:nth-of-type(#{row}) td:nth-of-type(9)", text: candidate.parent_email_2)
  end

end