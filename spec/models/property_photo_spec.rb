require 'rails_helper'

RSpec.describe PropertyPhoto, type: :model do
  let(:property) { create(:property) }

  it "is valid with property and position" do
    p = build(:property_photo, property: property, position: 1)
    expect(p).to be_valid
  end

  it "is invalid without property or position" do
    p = PropertyPhoto.new
    expect(p).not_to be_valid
    expect(p.errors[:property]).to be_present
  end

  it "requires position to be integer >= 1 and unique per property" do
    p = build(:property_photo, property: property, position: 0)
    expect(p).not_to be_valid
    expect(p.errors[:position]).to be_present

    create(:property_photo, property: property, position: 1)
    p3 = build(:property_photo, property: property, position: 1)
    expect(p3).not_to be_valid
    expect(p3.errors[:position]).to be_present
  end
end
