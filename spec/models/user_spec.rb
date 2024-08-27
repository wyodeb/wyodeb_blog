require 'rails_helper'

RSpec.describe User, type: :model do
  it { should define_enum_for(:role).with_values(poster: 1, commenter: 2) }

  describe '#generate_authentication_token' do
    let(:user) { create(:user) }

    it 'generates a unique token' do
      token = user.generate_authentication_token
      expect(token).to be_present
      expect(User.exists?(authentication_token: token)).to be_falsey
    end
  end

  describe '#password_required?' do
    context 'when password validation is skipped' do
      let(:user) { build(:user, :without_password) }

      it 'does not require a password' do
        expect(user.password_required?).to be_falsey
      end
    end

    context 'when password validation is not skipped' do
      let(:user) { build(:user) }

      it 'requires a password' do
        expect(user.password_required?).to be_truthy
      end
    end
  end
end
