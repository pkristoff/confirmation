# frozen_string_literal: true

RSpec.describe Visitor, type: :model do
  it 'should return home text.' do
    expect(FactoryBot.create(:visitor).home).to eq('<p>home text</p>')
  end
  it 'should return about text.' do
    expect(FactoryBot.create(:visitor).about).to eq('<p>about text</p>')
  end
  it 'should return contact text.' do
    expect(FactoryBot.create(:visitor).contact).to eq('<p>contact me</p>')
  end
end
