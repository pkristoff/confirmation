include ViewsHelpers
describe 'candidate_imports/new.html.erb' do

  it 'layout with no errors' do

    @candidate_import = CandidateImport.new

    render

    puts rendered

    expect(rendered).to have_selector("li[id=column-0] strong", text: 'last_name')
    expect(rendered).to have_selector("li[id=column-1] strong", text: 'first_name')
    expect(rendered).to have_selector("li[id=column-2] strong", text: 'grade')
    expect(rendered).to have_selector("li[id=column-3] strong", text: 'parent_email_1')


    expect(rendered).to have_selector("div[id=error_explanation] li", count: 0)

  end

  it 'layout with errors' do

    uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    @candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
    @candidate_import.save

    render

    puts rendered

    expect(rendered).to have_selector("li[id=column-0] strong", text: 'last_name')
    expect(rendered).to have_selector("li[id=column-1] strong", text: 'first_name')
    expect(rendered).to have_selector("li[id=column-2] strong", text: 'grade')
    expect(rendered).to have_selector("li[id=column-3] strong", text: 'parent_email_1')


    expect(rendered).to have_selector("div[id=error_explanation] li", count: 5)

  end
end