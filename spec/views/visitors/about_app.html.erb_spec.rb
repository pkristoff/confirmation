# frozen_string_literal: true

describe 'visitors/about_app.html.erb' do
  before(:each) do
    last_version = `git describe --tags --always`
    split_v = last_version.strip.split('.')
    version = split_v[0]
    if split_v.size == 2
      split_dash = split_v[1].split('-')
      if split_dash.size == 1
        next_version = '01'
        minor_version = split_v[1]
      else
        minor_version = split_dash[0]
        n = Integer(split_dash[1])
        next_version = (n + 1).to_s if n > 9
        next_version = '0' + (n + 1).to_s if n <= 9
      end
    else
      n = Integer(split_v[2]) + 1
      next_version = n.to_s if split_v.size == 3 && n > 9
      next_version = '0' + n.to_s if split_v.size == 3 && n <= 9
    end
    @next_minor_version = "#{version}.#{minor_version}.#{next_version}"
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
    expect(rendered).to have_css('li', text: "Version: #{@next_minor_version}")
    expect(rendered).to have_css('li', text: 'Date: 6/20/2019')
  end
end
