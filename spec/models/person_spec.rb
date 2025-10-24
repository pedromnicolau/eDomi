require 'rails_helper'

RSpec.describe Person, type: :model do
  it "is valid with required attributes" do
    person = build(:person)
    expect(person).to be_valid
  end

  it "is invalid without name or email" do
    person = Person.new
    expect(person).not_to be_valid
    expect(person.errors[:name]).to be_present
    expect(person.errors[:email]).to be_present
  end

  it "validates uniqueness of email" do
    create(:person, email: "unique@example.com")
    dup = build(:person, email: "unique@example.com")
    expect(dup).not_to be_valid
    expect(dup.errors[:email]).to be_present
  end

  it "accepts valid enums and has active default true" do
    person = create(:person, status: :client, preferred_contact_method: :whatsapp)
    expect(person.client?).to be_truthy
    expect(person.preferred_contact_method).to eq("whatsapp")
    expect(person.active).to be true
  end
end
