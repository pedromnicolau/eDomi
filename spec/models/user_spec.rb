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

  describe "person linkage on create" do
    it "creates a person and links it when none exists" do
      email = "newperson@example.com"
      expect(Person.find_by(email: email)).to be_nil

      user = create(:user, email: email, name: "New Person")

      expect(user.person).to be_present
      expect(user.person.email).to eq(email)
      expect(user.person.name).to eq("New Person")
    end

    it "links to existing person with same email without creating new" do
      email = "existing@example.com"
      person = create(:person, email: email, name: "Existing Person")

      expect {
        @user = create(:user, email: email, name: "User Name")
      }.not_to change(Person, :count)

      expect(@user.person_id).to eq(person.id)
      expect(@user.person).to eq(person)
    end
  end

  describe "role default" do
    it "defaults to buyer when role is not provided" do
      user = User.new(email: "test@example.com", password: "password")
      expect(user.role).to be_nil
      user.valid?
      expect(user.role).to eq("buyer")
    end

    it "sets buyer role even when explicitly nil before save" do
      user = build(:user, email: "test2@example.com", role: nil)
      expect(user.save).to be true
      expect(user.role).to eq("buyer")
    end

    it "allows other roles when explicitly set" do
      user = create(:user, role: :agent)
      expect(user.role).to eq("agent")
    end
  end
end
