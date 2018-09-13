# frozen_string_literal: true

describe 'visitors/about_app.html.erb' do
  before(:each) do
    last_version = `git describe --tags --always`
    split_v = last_version.split('.')
    next_version = (Integer(split_v[2].split('-')[0]) + 1).to_s
    @next_version = "#{split_v[0]}.#{split_v[1]}.#{next_version}"
  end

  it 'navigation layout' do
    render

    expect_common
  end

  it 'navigation layout admin logged in' do
    login_admin

    render

    expect_common
  end

  it 'navigation layout candidate logged in' do
    login_candidate

    render

    expect_common
  end

  def expect_common
    expect(rendered).to have_css('p', text: t('views.top_bar.aboutApp'))
    expect(rendered).to have_css('li', count: 2)
    expect(rendered).to have_css('li', text: "Version: #{@next_version}")
    expect(rendered).to have_css('li', text: 'Date: 03/27/2018')
  end
end
