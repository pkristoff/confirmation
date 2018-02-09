# frozen_string_literal: true

describe 'Internal' do

  it 'should pass controllers' do
    expect(system 'rubocop app/controllers/admins_controller.rb').to eq(true)
  end

  it 'should pass models' do
    expect(system 'rubocop app/models').to eq(true)
  end
end
