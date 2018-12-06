require 'rails_helper'

describe User, type: :model do

  let(:user) { create :user }

  it 'has a valid factory' do
    expect(FactoryBot.create(:user)).to be_valid
  end

  context 'validations' do
    subject { create :user }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to have_secure_password }
  end
end