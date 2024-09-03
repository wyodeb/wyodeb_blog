require 'rails_helper'

RSpec.describe PostsController, type: :request do
  let(:poster) { create(:user, :poster) }
  let(:commenter) { create(:user, :commenter) }
  let(:draft_post) { create(:post, user: poster, status: :draft) }
  let(:published_post) { create(:post, user: poster, status: :published) }

  describe 'GET /posts' do
    context 'when the user is logged in as a poster' do
      before do
        sign_in(poster) # Ensure this method is properly implemented
        get posts_path
      end

      it 'returns all posts including drafts' do
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.map { |post| post['id'] }).to include(draft_post.id, published_post.id)
      end
    end

    context 'when the user is not logged in' do
      before { get posts_path }

      it 'returns only published posts' do
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response.map { |post| post['id'] }).to include(published_post.id)
        expect(json_response.map { |post| post['id'] }).not_to include(draft_post.id)
      end
    end
  end

  describe 'GET /posts/:slug' do
    context 'when the user is logged in as the post owner' do
      before do
        sign_in(poster)
        get post_path(draft_post.slug)
      end

      it 'returns the post including the status' do
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(draft_post.id)
        expect(json_response['status']).to eq('draft')
      end
    end

    context 'when the user is not the owner and the post is published' do
      before { get post_path(published_post.slug) }

      it 'returns the post without the status' do
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(published_post.id)
        expect(json_response).not_to have_key('status')
      end
    end

    context 'when the post is not found' do
      before do
        sign_in(poster)
        get post_path('non-existent-slug')
      end

      it 'returns a not found error' do
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Post not found')
      end
    end
  end

  describe 'POST /posts' do
    context 'when the user is a poster' do
      before do
        sign_in(poster)
        post posts_path, params: { post: { title: 'New Post', content: 'Post content' } }
      end

      it 'creates a new post with draft status' do
        expect(response).to have_http_status(:created)
        expect(Post.count).to eq(3) # Adjust based on initial count
        json_response = JSON.parse(response.body)
        expect(json_response['status']).to eq('draft')
      end
    end

    context 'when the user is not a poster' do
      before do
        sign_in(commenter)
        post posts_path, params: { post: { title: 'New Post', content: 'Post content' } }
      end

      it 'returns a forbidden error' do
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Forbidden')
      end
    end
  end

  describe 'PATCH /posts/:slug' do
    context 'when the user is a poster' do
      before do
        sign_in(poster)
        patch post_path(draft_post.slug), params: { post: { title: 'Updated Title' } }
      end

      it 'updates the post' do
        expect(response).to have_http_status(:ok)
        expect(draft_post.reload.title).to eq('Updated Title')
      end
    end

    context 'when the user is not a poster' do
      before do
        sign_in(commenter)
        patch post_path(draft_post.slug), params: { post: { title: 'Updated Title' } }
      end

      it 'returns a forbidden error' do
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Forbidden')
      end
    end
  end

  describe 'DELETE /posts/:slug' do
    context 'when the user is a poster' do
      before do
        sign_in(poster)
        delete post_path(draft_post.slug)
      end

      it 'deletes the post' do
        expect(response).to have_http_status(:no_content)
        expect(Post.count).to eq(2) # Adjust based on initial count
      end
    end

    context 'when the user is not a poster' do
      before do
        sign_in(commenter)
        delete post_path(draft_post.slug)
      end

      it 'returns a forbidden error' do
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Forbidden')
      end
    end
  end
end
