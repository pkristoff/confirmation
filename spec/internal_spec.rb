# frozen_string_literal: true

describe 'Internal' do

  it 'should pass controllers' do
    expect(system 'rubocop app/controllers/admins_controller.rb').to eq(true)
  end

  it 'should pass models' do
    expect(system 'rubocop app/models').to eq(true)
  end

  it 'should pass migration' do
    expect(system 'rubocop db/migrate/20180209181803_add_column_first_comm_at_stmm.rb').to eq(true)
  end

  it 'should pass controller spec' do
    expect(system 'rubocop spec/controllers/candidates_controller_spec.rb').to eq(true)
  end

  it 'should pass support spec' do
    expect(system 'rubocop spec/support/shared_baptismal_certificate_html_erb.rb').to eq(true)
    expect(system 'rubocop spec/support/shared_candidates_controller.rb').to eq(true)
  end

  # it 'should pass views' do
  #   expect(system 'rubocop app/views/candidates/shared').to eq(true)
  # end
end
