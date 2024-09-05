require 'rails_helper'

RSpec.describe CommentsController, type: :request do
  let(:poster) { create(:user, :poster) }
  let(:commenter) { create(:user, :commenter) }
  let(:other_user) { create(:user) }
  let(:post_record) { create(:post, user: poster) }
  let(:comment) { create(:comment, post: post_record, user: commenter) }
  let(:headers) { { 'CONTENT_TYPE' => 'application/json' } }

  def set_auth_header(user)
    token = user.generate_authentication_token
    user.update(authentication_token: token)
    headers['Authorization'] = "Bearer #{token}"
  end

  describe 'POST /posts/:slug/comments' do
    context 'when user is authenticated' do
      before do
        set_auth_header(commenter)
      end

      context 'with valid params' do
        let(:valid_params) { { comment: { content: 'This is a test comment', parent_id: nil } } }

        it 'creates a new comment' do
          expect {
            post "/posts/#{post_record.slug}/comments", params: valid_params.to_json, headers: headers
          }.to change(Comment, :count).by(1)

          expect(response).to have_http_status(:created)
          json_response = JSON.parse(response.body)
          expect(json_response['content']).to eq('This is a test comment')
        end
      end

      context 'with invalid params' do
        let(:invalid_params) { { comment: { content: '' } } }

        it 'does not create a new comment' do
          expect {
            post "/posts/#{post_record.slug}/comments", params: invalid_params.to_json, headers: headers
          }.to_not change(Comment, :count)

          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
          expect(json_response['errors']).to include("Content can't be blank")
        end
      end

      context 'when post is not found' do
        let(:invalid_post_params) { { comment: { content: 'This is a test comment' } } }

        it 'returns not found error' do
          post '/posts/non-existent-slug/comments', params: invalid_post_params.to_json, headers: headers

          expect(response).to have_http_status(:not_found)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Post not found')
        end
      end
    end

    context 'when user is not authenticated' do
      let(:valid_params) { { comment: { content: 'This is a test comment', parent_id: nil } } }

      it 'returns unauthorized error' do
        post "/posts/#{post_record.slug}/comments", params: valid_params.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Unauthorized')
      end
    end
  end

  describe 'DELETE /posts/:slug/comments/:id' do
    context 'when user is authenticated' do
      context 'when user is the comment owner' do
        before do
          set_auth_header(commenter)
        end

        it 'deletes the comment' do
          delete "/posts/#{post_record.slug}/comments/#{comment.id}", headers: headers

          expect(response).to have_http_status(:no_content)
          expect(Comment.exists?(comment.id)).to be_falsey
        end
      end

      context 'when user is the post owner' do
        before do
          set_auth_header(poster)
        end

        it 'deletes the comment' do
          delete "/posts/#{post_record.slug}/comments/#{comment.id}", headers: headers

          expect(response).to have_http_status(:no_content)
          expect(Comment.exists?(comment.id)).to be_falsey
        end
      end

      context 'when user is not the comment owner or post owner' do
        before do
          set_auth_header(other_user)
        end

        it 'returns forbidden error' do
          delete "/posts/#{post_record.slug}/comments/#{comment.id}", headers: headers

          expect(response).to have_http_status(:forbidden)
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Forbidden')
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns unauthorized error' do
        delete "/posts/#{post_record.slug}/comments/#{comment.id}", headers: headers

        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Forbidden')
      end
    end

    context 'when comment has replies' do
      let!(:reply) { create(:comment, post: post_record, parent: comment, user: commenter) }

      before do
        set_auth_header(commenter)
      end

      it 'does not delete the comment and shows "author deleted this comment"' do
        delete "/posts/#{post_record.slug}/comments/#{comment.id}", headers: headers

        expect(response).to have_http_status(:ok)
        expect(Comment.find(comment.id).content).to eq('Author deleted this comment')
      end
    end
  end
end
