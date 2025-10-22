require 'rails_helper'

RSpec.describe Sale, type: :model do
  let(:agent) { create(:user) }
  let(:buyer) { create(:user) }
  let(:property) { create(:property, agent: agent) }

  it "is valid with required attributes" do
    sale = build(:sale, property: property, agent: agent, buyer: buyer, sale_price: 150_000, sale_date: Date.today)
    expect(sale).to be_valid
  end

  it "is invalid without associations or sale_date" do
    sale = Sale.new
    expect(sale).not_to be_valid
    expect(sale.errors[:property]).to be_present
    expect(sale.errors[:agent]).to be_present
    expect(sale.errors[:buyer]).to be_present
    expect(sale.errors[:sale_date]).to be_present
  end

  it "enforces non-negative sale_price" do
    sale = build(:sale, property: property, agent: agent, buyer: buyer, sale_price: -10, sale_date: Date.today)
    expect(sale).not_to be_valid
    expect(sale.errors[:sale_price]).to be_present
  end

  it "enforces non-negative sale_price" do
    sale = Sale.new(property: property, agent: agent, buyer: buyer, sale_price: -10, sale_date: Date.today)
    expect(sale).not_to be_valid
    expect(sale.errors[:sale_price]).to be_present
  end
end
