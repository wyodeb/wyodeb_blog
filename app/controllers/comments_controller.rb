class CommentsController < ApplicationController
  include Authenticable
  before_action :set_post, only: [:create, :destroy]
  before_action :set_comment, only: [:destroy]
  before_action :authenticate_user!, only: [:create]
  before_action :authorize_comment_owner_or_post_owner!, only: [:destroy]

  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      render json: @comment, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @comment.children.any?
      # Soft delete
      @comment.update(content: 'Author deleted this comment')
      render json: { message: 'Comment has been marked as deleted.' }, status: :ok
    else
      # Hard delete
      @comment.destroy
      head :no_content
    end
  end

  private

  def set_post
    @post = Post.find_by(slug: params[:post_slug])
    render json: { error: 'Post not found' }, status: :not_found if @post.nil?
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end

  def authorize_comment_owner_or_post_owner!
    unless current_user == @comment.user || current_user == @post.user
      render json: { error: 'Forbidden' }, status: :forbidden
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
