# frozen_string_literal: true

describe 'Internal' do

  it 'should pass controllers' do
    expect(system 'rubocop -l --only Rails,Layout,Naming,Style,Performance app/controllers/admins_controller.rb').to eq(true)
  end

  it 'should pass models' do
    expect(system 'rubocop -l --only Rails,Layout,Naming,Style,Performance app/controllers/admins_controller.rb').to eq(true)
  end
end
