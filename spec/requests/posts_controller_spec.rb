require 'rails_helper'

RSpec.describe PostsController, type: :request do
  let(:poster) { create(:user, :poster) }
  let(:commenter) { create(:user, :commenter) }
  let!(:draft_post) { create(:post, user: poster, status: :draft) }
  let!(:published_post) { create(:post, user: poster, status: :published) }
  let!(:category) { create(:category, name: 'Technology') } # Example category

  def set_auth_header(user)
    token = user.generate_authentication_token
    user.update(authentication_token: token)
    @headers = { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /posts' do
    context 'when the user is logged in as a poster' do
      before do
        set_auth_header(poster)
        get posts_path, headers: @headers
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
        set_auth_header(poster)
        get post_path(draft_post.slug), headers: @headers
      end

      it 'returns the post including the status' do
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(draft_post.id)
        expect(json_response['status']).to eq('draft')
      end
    end

    context 'when the user is not the owner and the post is published' do
      before do
        set_auth_header(commenter)
        get post_path(published_post.slug), headers: @headers
      end

      it 'returns the post without the status' do
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['id']).to eq(published_post.id)
        expect(json_response).not_to have_key('status')
      end
    end

    context 'when the post is not found' do
      before do
        set_auth_header(poster)
        get post_path('non-existent-slug'), headers: @headers
      end

      it 'returns a not found error' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /posts' do
    context 'when the user is a poster and categories are provided' do
      before do
        set_auth_header(poster)
        post posts_path, params: { post: { title: 'New Post with Categories', content: 'Post content' }, categories: ['Technology', 'Science'] }, headers: @headers
      end

      it 'creates a new post with the provided categories' do
        expect(response).to have_http_status(:created)
        expect(Post.count).to eq(3)
        json_response = JSON.parse(response.body)
        post = Post.find(json_response['id'])
        expect(post.categories.pluck(:name)).to include('Technology', 'Science')
      end
    end

    context 'when the user is a poster and no categories are provided' do
      before do
        set_auth_header(poster)
        post posts_path, params: { post: { title: 'New Post without Categories', content: 'Post content' } }, headers: @headers
      end

      it 'creates a new post with the default "No category"' do
        expect(response).to have_http_status(:created)
        expect(Post.count).to eq(3)
        json_response = JSON.parse(response.body)
        post = Post.find(json_response['id'])
        expect(post.categories.pluck(:name)).to include('No category')
      end
    end

    context 'when the user is not a poster' do
      before do
        set_auth_header(commenter)
        post posts_path, params: { post: { title: 'New Post', content: 'Post content' } }, headers: @headers
      end

      it 'returns a forbidden error' do
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Forbidden')
      end
    end
  end

  describe 'PATCH /posts/:slug' do
    context 'when updating a post' do
      before do
        set_auth_header(poster)
        patch post_path(draft_post.slug), params: { post: { title: 'Updated Title', content: 'Updated content with more words to test word count.' } }, headers: @headers
      end

      it 'updates the post and recalculates word count and reading time' do
        expect(response).to have_http_status(:ok)
        draft_post.reload
        expect(draft_post.title).to eq('Updated Title')
        expect(draft_post.word_count).to eq(23)
        expect(draft_post.reading_time).to eq(1)
      end
    end

    context 'when the user is not a poster' do
      before do
        set_auth_header(commenter)
        patch post_path(draft_post.slug), params: { post: { title: 'Updated Title' } }, headers: @headers
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
        set_auth_header(poster)
        delete post_path(draft_post.slug), headers: @headers
      end

      it 'deletes the post' do
        expect(response).to have_http_status(:no_content)
        expect(Post.count).to eq(1)
      end
    end

    context 'when the user is not a poster' do
      before do
        set_auth_header(commenter)
        delete post_path(draft_post.slug), headers: @headers
      end

      it 'returns a forbidden error' do
        expect(response).to have_http_status(:forbidden)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Forbidden')
      end
    end
  end
end
