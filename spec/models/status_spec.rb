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
end
