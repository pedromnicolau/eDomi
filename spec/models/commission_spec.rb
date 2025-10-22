require 'rails_helper'

RSpec.describe Commission, type: :model do
  let(:agent) { create(:user) }
  let(:buyer) { create(:user) }
  let(:property) { create(:property, agent: agent) }
  let(:sale) { create(:sale, property: property, agent: agent, buyer: buyer, sale_price: 90_000) }

  it "is valid with proper percentage and value" do
    com = build(:commission, sale: sale, agent: agent, percentage: 5.5, value: 4950.0)
    expect(com).to be_valid
  end

  it "requires percentage and value and enforces ranges" do
    c = Commission.new
    expect(c).not_to be_valid
    expect(c.errors[:percentage]).to be_present

    c2 = build(:commission, sale: sale, agent: agent, percentage: -1, value: 10)
    expect(c2).not_to be_valid
    expect(c2.errors[:percentage]).to be_present

    c3 = build(:commission, sale: sale, agent: agent, percentage: 200, value: 10)
    expect(c3).not_to be_valid
    expect(c3.errors[:percentage]).to be_present

    c4 = build(:commission, sale: sale, agent: agent, percentage: 10, value: -5)
    expect(c4).not_to be_valid
    expect(c4.errors[:value]).to be_present
  end

  it "enforces uniqueness of agent per sale" do
    create(:commission, sale: sale, agent: agent, percentage: 5, value: 4500)
    dup = build(:commission, sale: sale, agent: agent, percentage: 6, value: 5400)
    expect(dup).not_to be_valid
    expect(dup.errors[:agent_id]).to be_present
  end

  it "enforces uniqueness of agent per sale" do
    Commission.create!(sale: sale, agent: agent, percentage: 5, value: 4500)
    dup = Commission.new(sale: sale, agent: agent, percentage: 6, value: 5400)
    expect(dup).not_to be_valid
    expect(dup.errors[:agent_id]).to be_present
  end
end
