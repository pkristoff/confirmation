describe CandidatesController do
  before(:each) do
    @admdin = login_admin
  end

  it 'should NOT have a current_candidate' do
    expect(subject.current_candidate).to eq(nil)
  end

  it 'should show sorted list of candidates' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index
    expect(response).to render_template('index')
    expect(response.status).to eq(200)
    expect(controller.candidate_info.size).to eq(3)
    expect(controller.candidate_info[0].id).to eq(c1.id)
    expect(controller.candidate_info[1].id).to eq(c2.id)
    expect(controller.candidate_info[2].id).to eq(c3.id)
  end

  it 'should show sorted list of candidates based on first_name' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index, direction: 'asc', sort: 'candidate_sheet.first_name'
    expect(response).to render_template('index')
    expect(response.status).to eq(200)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(3)
    [c1,c2,c3].each_with_index do |candidate, index|
      expect(controller.candidate_info[index].id ).to eq(candidate.id)
    end
  end

  it 'should show sorted list of candidates based on last_name' do
    c1 = create_candidate('c1')
    c2 = create_candidate('c2')
    c3 = create_candidate('c3')
    get :index, direction: 'asc', sort: 'candidate_sheet.last_name'
    expect(response).to render_template('index')
    expect(response.status).to eq(200)
    # order not important js will do it
    expect(controller.candidate_info.size).to eq(3)
    [c1,c2,c3].each_with_index do |candidate, index|
      expect(controller.candidate_info[index].id ).to eq(candidate.id)
    end
  end

  def create_candidate(prefix)
    candidate = FactoryBot.create(:candidate, account_name: prefix)
    case prefix
      when 'c1'
        candidate.candidate_sheet.first_name = "c2first_name"
        candidate.candidate_sheet.middle_name = 'c1middle_name'
        candidate.candidate_sheet.last_name = "c3last_name"
      when 'c2'
        candidate.candidate_sheet.first_name = "c3first_name"
        candidate.candidate_sheet.middle_name = 'c2middle_name'
        candidate.candidate_sheet.last_name = "c1last_name"
      when 'c3'
        candidate.candidate_sheet.first_name = "c1first_name"
        candidate.candidate_sheet.middle_name = 'c3middle_name'
        candidate.candidate_sheet.last_name = "c2last_name"
    end
    candidate.save
    candidate
  end

  describe 'show' do

    it 'show should show candidate.' do
      candidate = FactoryBot.create(:candidate)
      get :show, {id: candidate.id}
      expect(response).to render_template('show')
      expect(controller.candidate).to eq(candidate)
      expect(@request.fullpath).to eq("/candidates/#{candidate.id}")
    end

  end

  describe 'behaves like' do
    before(:each) do
      @candidate = FactoryBot.create(:candidate)
      @dev = ''
      @dev_registration = ''
    end

    describe 'sign_agreement' do

      it_behaves_like 'sign_agreement'

    end

    describe 'sponsor_agreement' do

      it_behaves_like 'sponsor_agreement'

    end

    describe 'candidate_information_sheet' do

      it_behaves_like 'candidate_information_sheet'

    end

    describe 'baptismal_certificate' do

      it_behaves_like 'baptismal_certificate'

    end

  end

end