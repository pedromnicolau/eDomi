require 'rails_helper'

RSpec.describe User, type: :model do
  it "is valid with valid attributes" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without email" do
    user = build(:user, email: nil)
    expect(user).not_to be_valid
    expect(user.errors[:email]).to be_present
  end

  it "validates email uniqueness" do
    create(:user, email: "dup@example.com")
    dup = build(:user, email: "dup@example.com")
    expect(dup).not_to be_valid
    expect(dup.errors[:email]).to be_present
  end
end
