require 'rails_helper'
RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_params) { { email: user.email, password: 'password' } }
  let(:invalid_params) { { email: 'wrong@example.com', password: 'wrong_password' } }
  let(:token) { user.generate_authentication_token }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'returns a token and status code 200' do
        post :create, params: valid_params
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['token']).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns an error message and status code 401' do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unauthorized)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'with valid token' do
      it 'invalidates the token and returns a success message' do
        user.update(authentication_token: token)
        delete :destroy, params: { token: token }
        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['message']).to eq('Signed out successfully')
        user.reload
        expect(user.authentication_token).to be_nil
      end
    end

    context 'with invalid token' do
      it 'returns an error message and status code 401' do
        delete :destroy, params: { token: 'invalid_token' }
        expect(response).to have_http_status(:unauthorized)
        parsed_response = JSON.parse(response.body)
        expect(parsed_response['error']).to eq('Invalid or expired token')
      end
    end
  end

end
