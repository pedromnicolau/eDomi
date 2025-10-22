require 'rails_helper'

RSpec.describe Property, type: :model do
  let(:agent) { create(:user) }

  it "is valid with required attributes" do
    prop = build(:property, agent: agent)
    expect(prop).to be_valid
  end

  it "is invalid without title, price, address, city or state" do
    prop = Property.new
    expect(prop).not_to be_valid
    expect(prop.errors[:title]).to be_present
    expect(prop.errors[:price]).to be_present
    expect(prop.errors[:address]).to be_present
    expect(prop.errors[:city]).to be_present
    expect(prop.errors[:state]).to be_present
  end

  it "validates non-negative numeric fields" do
    prop = build(:property,
                 agent: agent,
                 price: -1,
                 bedrooms: -1,
                 bathrooms: -2,
                 parking_spaces: -1,
                 condominium_fee: -10.0,
                 iptu: -5.0)
    expect(prop).not_to be_valid
    expect(prop.errors[:price]).to be_present
    expect(prop.errors[:bedrooms]).to be_present
    expect(prop.errors[:bathrooms]).to be_present
    expect(prop.errors[:parking_spaces]).to be_present
    expect(prop.errors[:condominium_fee]).to be_present
    expect(prop.errors[:iptu]).to be_present
  end

  it "accepts valid numeric values" do
    prop = build(:property,
                 agent: agent,
                 bedrooms: 2,
                 bathrooms: 1,
                 parking_spaces: 1,
                 condominium_fee: 100.0,
                 iptu: 50.0,
                 price: 50_000)
    expect(prop).to be_valid
  end
end
