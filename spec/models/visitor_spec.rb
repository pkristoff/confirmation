# frozen_string_literal: true

RSpec.describe Visitor, type: :model do
  before(:each) do
    @visitor = FactoryBot.create(:visitor)
  end
  it 'should return home text.' do
    expect(@visitor.home).to eq('<p>home text</p>')
  end
  it 'should return about text.' do
    expect(@visitor.about).to eq('<p>about text</p>')
  end
  it 'should return contact text.' do
    expect(@visitor.contact).to eq('<p>contact me</p>')
  end
end
