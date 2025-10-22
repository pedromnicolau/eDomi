require 'rails_helper'

RSpec.describe Notification, type: :model do
  let(:user) { create(:user) }

  it "is valid with a title and user" do
    n = build(:notification, user: user, title: "Olá", body: "Corpo")
    expect(n).to be_valid
  end

  it "is invalid without title or user" do
    n = Notification.new
    expect(n).not_to be_valid
    expect(n.errors[:title]).to be_present
    expect(n.errors[:user]).to be_present
  end
end
