# require 'rails_helper'
#
# RSpec.describe PostsController, type: :controller do
#   let(:user) { create(:user) }
#   let(:other_user) { create(:user) }
#   let(:post_draft) { create(:post, user: user, status: :draft) }
#   let(:post_published) { create(:post, user: user, status: :published) }
#   let(:post_published_other_user) { create(:post, user: other_user, status: :published) }
#
#   describe 'GET #show' do
#     let!(:post) { create(:post, slug: 'unique-slug') }
#
#     context 'when user is authenticated and owns the post' do
#       before do
#         sign_in user
#         get :show, params: { slug: post.slug }
#       end
#
#       it 'returns the post with status' do
#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)['status']).to eq('draft')  # Adjust as needed
#       end
#     end
#
#     context 'when user is authenticated but does not own the post' do
#       before do
#         sign_in other_user
#         get :show, params: { slug: post.slug }
#       end
#
#       it 'returns the post without status' do
#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)['status']).to be_nil
#       end
#     end
#
#     context 'when user is not authenticated' do
#       before { get :show, params: { slug: post.slug } }
#
#       it 'returns the post with status' do
#         expect(response).to have_http_status(:ok)
#         expect(JSON.parse(response.body)['status']).to eq('published')  # Adjust as needed
#       end
#     end
#   end
#
#   describe 'PATCH/PUT #update' do
#     let!(:post) { create(:post, slug: 'unique-slug') }
#
#     context 'when user is a poster and owns the post' do
#       before do
#         sign_in user
#         patch :update, params: { slug: post.slug, post: { title: 'Updated Title' } }
#       end
#
#       it 'updates the post' do
#         expect(response).to have_http_status(:ok)
#         expect(Post.find_by(slug: post.slug).title).to eq('Updated Title')
#       end
#     end
#
#     context 'when user is not a poster' do
#       before do
#         sign_in other_user
#         patch :update, params: { slug: post.slug, post: { title: 'Should Not Update' } }
#       end
#
#       it 'returns forbidden' do
#         expect(response).to have_http_status(:forbidden)
#       end
#     end
#   end
#
#
#
#
#   describe 'GET #index' do
#     context 'when the user is authenticated' do
#       before { sign_in user }
#
#       it 'returns all posts for the authenticated user' do
#         get :index
#         expect(response).to have_http_status(:ok)
#         json_response = JSON.parse(response.body)
#         expect(json_response.any? { |post| post['slug'] == post_draft.slug }).to be(true)
#         expect(json_response.any? { |post| post['slug'] == post_published.slug }).to be(true)
#       end
#     end
#
#     context 'when the user is not authenticated' do
#       it 'returns only published posts' do
#         get :index
#         expect(response).to have_http_status(:ok)
#         json_response = JSON.parse(response.body)
#         expect(json_response.any? { |post| post['slug'] == post_published.slug }).to be(true)
#         expect(json_response.none? { |post| post['slug'] == post_draft.slug }).to be(true)
#       end
#     end
#   end
# end
