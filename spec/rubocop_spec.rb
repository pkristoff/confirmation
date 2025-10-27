# frozen_string_literal: true

describe 'Internal' do

  describe 'app' do

    it 'passes controllers' do
      expect(system('rubocop -d app/controllers/')).to be(true)
    end

    it 'passes app helpers' do
      expect(system('rubocop -d app/helpers/')).to be(true)
    end

    it 'passes mailers' do
      expect(system('rubocop -d app/mailers')).to be(true)
    end

    it 'passes models' do
      expect(system('rubocop -d app/models')).to be(true)
    end

    it 'passes views' do
      expect(system('rubocop -d app/views')).to be(true)
    end
  end

  describe 'db' do
    it 'passes migration' do
      expect(system('rubocop db/migrate/20180209181803_add_column_first_comm_at_stmm.rb')).to be(true)
    end
  end

  describe 'spec' do
    it 'passes app_factories -d spec' do
      expect(system('rubocop -d spec/app_factories')).to be(true)
    end

    it 'passes controller spec' do
      expect(system('rubocop -d spec/controllers')).to be(true)
    end

    it 'passes factories spec' do
      expect(system('rubocop -d spec/factories')).to be(true)
    end

    it 'passes features spec' do
      expect(system('rubocop spec/features')).to be(true)
    end

    it 'passes -d fixture spec' do
      expect(system('rubocop -d spec/fixtures')).to be(true)
    end

    it 'passes models spec' do
      puts 'Starting spec/models'
      expect(system('rubocop -d spec/models')).to be(true)
      puts 'Ending spec/models'
    end

    it 'passes mailers spec' do
      puts 'Starting spec/mailers'
      expect(system('rubocop -d spec/mailers')).to be(true)
      puts 'Ending spec/mailers'
    end

    it 'passes support spec' do
      puts "Starting spec/support = #{system 'rubocop spec/support'}"
      expect(system('rubocop -d spec/support')).to be(true)
      puts 'Ending spec/support'
    end

    it 'passes views visitors spec' do
      expect(system('rubocop -d spec/views')).to be(true)
    end
  end

  describe 'initializers' do
    it 'passes initializers' do
      expect(system('rubocop config/initializers/version.rb')).to be(true)
    end
  end

  describe 'gemspec' do
    it 'passes gemspec' do
      expect(system('rubocop Gemfile')).to be(true)
    end
  end
end