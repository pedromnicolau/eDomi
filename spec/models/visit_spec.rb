require 'rails_helper'

RSpec.describe Visit, type: :model do
  let(:agent) { create(:user) }
  let(:buyer) { create(:user) }
  let(:property) { create(:property, agent: agent) }

  it "is valid with required attributes" do
    v = build(:visit, property: property, buyer: buyer, agent: agent, scheduled_at: 1.day.from_now)
    expect(v).to be_valid
  end

  it "is invalid without scheduled_at or associations" do
    v = Visit.new
    expect(v).not_to be_valid
    expect(v.errors[:scheduled_at]).to be_present
    expect(v.errors[:property]).to be_present
    expect(v.errors[:buyer]).to be_present
    expect(v.errors[:agent]).to be_present
  end

  it "accepts valid status values" do
    v = build(:visit, property: property, buyer: buyer, agent: agent, scheduled_at: 1.day.from_now, status: :confirmed)
    expect(v).to be_valid
    expect(v.status).to eq("confirmed").or eq(:confirmed)
  end

  it "accepts valid status values" do
    v = Visit.new(property: property, buyer: buyer, agent: agent, scheduled_at: 1.day.from_now, status: :confirmed)
    expect(v).to be_valid
    expect(v.status).to eq("confirmed").or eq(:confirmed)
  end
end
