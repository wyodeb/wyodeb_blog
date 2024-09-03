require 'rails_helper'

RSpec.describe OtpController, type: :controller do
  let(:email) { 'test@example.com' }
  let(:username) { 'testuser' }
  let(:otp) { '123456' }
  let(:user) { create(:user, email: email, username: username) }

  before do
    allow_any_instance_of(User).to receive(:password_required?).and_return(false)
  end

  describe 'POST #request_otp' do
    context 'when the user does not exist' do
      it 'creates a new user and sends an OTP email' do
        expect {
          post :request_otp, params: { email: email, username: username }
        }.to change(User, :count).by(1).and change(Token, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('message' => 'OTP sent successfully')
      end
    end

    context 'when the user already exists' do
      before { user }

      it 'does not create a new user but creates a new token' do
        expect {
          post :request_otp, params: { email: email }
        }.to change(Token, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('message' => 'OTP sent successfully')
      end
    end
  end

  describe 'POST #verify_otp' do
    context 'when the OTP is valid' do
      before do
        create(:token, user: user, otp: otp, expires_at: 10.minutes.from_now)
      end

      it 'verifies the OTP and returns a success message' do
        post :verify_otp, params: { email: email, otp: otp }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('message' => 'OTP verified successfully')
      end
    end

    context 'when the OTP is invalid or expired' do
      it 'returns unauthorized if the OTP does not match' do
        create(:token, otp: 'correctotp', user: user, expires_at: 10.minutes.from_now)
        post :verify_otp, params: { email: email, otp: 'wrongotp' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include('error' => 'Invalid or expired OTP')
      end

      it 'returns unauthorized when no token is found' do
        post :verify_otp, params: { email: email, otp: 'nonexistent' }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include('error' => 'Invalid or expired OTP')
      end

      it 'returns unauthorized if the OTP has expired' do
        create(:token, user: user, otp: otp, expires_at: 10.minutes.ago)
        post :verify_otp, params: { email: email, otp: otp }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to include('error' => 'Invalid or expired OTP')
      end
    end
  end
end
