# frozen_string_literal: true

describe 'Internal' do

  describe 'app' do

    it 'should pass controllers' do
      expect(system 'rubocop app/controllers/').to eq(true)
    end

    it 'should pass app helpers' do
      expect(system 'rubocop app/helpers/').to eq(true)
    end

    it 'should pass mailers' do
      expect(system 'rubocop app/mailers').to eq(true)
    end

    it 'should pass models' do
      expect(system 'rubocop app/models').to eq(true)
    end

    it 'should pass  views' do
      expect(system 'rubocop app/views').to eq(true)
    end
  end

  describe 'db' do
    it 'should pass migration' do
      expect(system 'rubocop db/migrate/20180209181803_add_column_first_comm_at_stmm.rb').to eq(true)
    end
  end

  describe 'spec' do
    it 'should pass app_factories spec' do
      expect(system 'rubocop spec/app_factories').to eq(true)
    end

    it 'should pass controller spec' do
      expect(system 'rubocop spec/controllers').to eq(true)
    end

    it 'should pass factories spec' do
      expect(system 'rubocop spec/factories').to eq(true)
    end

    it 'should pass features spec' do
      expect(system 'rubocop spec/features').to eq(true)
    end

    it 'should pass fixture spec' do
      expect(system 'rubocop spec/fixtures').to eq(true)
    end

    it 'should pass mailers spec' do
      expect(system 'rubocop spec/mailers').to eq(true)
    end

    it 'should pass support spec' do
      expect(system 'rubocop spec/support').to eq(true)
    end

    it 'should pass features spec' do
      expect(system 'rubocop spec/features/candidates/admin/mass_edit/candidate_events/christian_ministry.html.erb_spec.rb').to eq(true)
      expect(system 'rubocop spec/features/candidates/admin/mass_edit/candidate_events/pick_confirmation_name.html.erb_spec.rb').to eq(true)
    end

    it 'should pass views visitors spec' do
      expect(system 'rubocop spec/views/visitors/about.html.erb_spec.rb').to eq(true)
    end
  end

  describe 'initializers' do
    it 'should pass initializers' do
      expect(system 'rubocop config/initializers/version.rb').to eq(true)
    end
  end
end
