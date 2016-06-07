include ViewsHelpers
describe 'candidate_imports/new.html.erb' do

  it 'layout with no errors' do

    @candidate_import = CandidateImport.new

    render

    expect(rendered).to have_selector("li[id=column-0] strong", text: 'last_name')
    expect(rendered).to have_selector("li[id=column-1] strong", text: 'first_name')
    expect(rendered).to have_selector("li[id=column-2] strong", text: 'grade')
    expect(rendered).to have_selector("li[id=column-3] strong", text: 'parent_email_1')


    expect(rendered).to have_selector("div[id=error_explanation] li", count: 0)


    expect(rendered).to have_selector('section[id=import] form[id=new_candidate_import][action="/candidate_imports"]')
    expect(rendered).to have_button(I18n.t('views.imports.import'))

    expect(rendered).to have_selector('section[id=remove_all_candidates] form[id=new_candidate_import][action="/candidate_imports/remove_all_candidates"]')
    expect(rendered).to have_button(I18n.t('views.imports.reset_database'))

    expect(rendered).to have_selector('section[id=reset_database] form[id=new_candidate_import][action="/candidate_imports/reset_database"]')
    expect(rendered).to have_button(I18n.t('views.imports.remove_all_candidates'))


  end

  it 'layout with errors' do

    uploaded_file = fixture_file_upload('Invalid.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
    @candidate_import = CandidateImport.new(uploaded_file: uploaded_file)
    @candidate_import.save

    render

    expect(rendered).to have_selector("section[id=import] li[id=column-0] strong", text: 'last_name')
    expect(rendered).to have_selector("section[id=import] li[id=column-1] strong", text: 'first_name')
    expect(rendered).to have_selector("section[id=import] li[id=column-2] strong", text: 'grade')
    expect(rendered).to have_selector("section[id=import] li[id=column-3] strong", text: 'parent_email_1')


    expect(rendered).to have_selector("div[id=error_explanation] li", count: 5)

  end
end