# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status do
  it 'creating a status' do
    status = Status.new(name: 'X1', description: 'desc')
    expect(status.name).to eq('X1')
    expect(status.description).to eq('desc')
  end

  it 'creating a valid status' do
    status = Status.new(name: 'X1', description: 'desc')
    status.validate
    expect(status.errors.size).to be(0)
  end

  it 'status invalid name' do
    status = Status.new(description: 'desc')
    status.validate
    expect(status.errors.size).to be(1)
    expect(status.errors.full_messages).to eq(["Name can't be blank"])
  end

  it 'status invalid description' do
    status = Status.new(name: 'X1')
    status.validate
    expect(status.errors.size).to be(1)
    expect(status.errors.full_messages).to eq(["Description can't be blank"])
  end

  describe 'used_by_candidate?' do
    it 'return false if Status is not used' do
      lll_status = FactoryBot.create(:status, name: 'lll')
      active_status = FactoryBot.create(:status)
      candidate = FactoryBot.create(:candidate)
      expect(candidate.status_id).to eq(active_status.id)
      expect(lll_status.used_by_candidate?).to be(false)
    end

    it 'return true if Status is used' do
      FactoryBot.create(:status, name: 'lll')
      active_status = FactoryBot.create(:status)
      candidate = FactoryBot.create(:candidate)
      expect(candidate.status_id).to eq(active_status.id)
      expect(active_status.used_by_candidate?).to be(true)
    end
  end

  describe 'predicate' do
    it 'active? is true' do
      status = FactoryBot.create(:status)
      expect(Status.active?(status.id)).to be true
      expect(Status.confirmed_elsewhere?(status.id)).to be false
      expect(Status.deferred?(status.id)).to be false
      expect(Status.from_another_parish?(status.id)).to be false
    end

    it 'confirmed_elsewhere? is true' do
      status = FactoryBot.create(:status, name: Status::CONFIRMED_ELSEWHERE)
      expect(Status.active?(status.id)).to be false
      expect(Status.confirmed_elsewhere?(status.id)).to be true
      expect(Status.deferred?(status.id)).to be false
      expect(Status.from_another_parish?(status.id)).to be false
    end

    it 'deferred? is true' do
      status = FactoryBot.create(:status, name: Status::DEFERRED)
      expect(Status.active?(status.id)).to be false
      expect(Status.confirmed_elsewhere?(status.id)).to be false
      expect(Status.deferred?(status.id)).to be true
      expect(Status.from_another_parish?(status.id)).to be false
    end

    it 'from_another_parish? is true' do
      status = FactoryBot.create(:status, name: Status::FROM_ANOTHER_PARISH)
      expect(Status.active?(status.id)).to be false
      expect(Status.confirmed_elsewhere?(status.id)).to be false
      expect(Status.deferred?(status.id)).to be false
      expect(Status.from_another_parish?(status.id)).to be true
    end
  end
end
