class CommentsController < ApplicationController
  before_action :set_post, only: [:create]
  include Authenticable

  def create
    if @post
      @comment = @post.comments.new(comment_params)
      @comment.user = current_user

      if @comment.save
        render json: @comment, status: :created
      else
        render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Post not found' }, status: :not_found
    end
  end

  private

  def set_post
    @post = Post.find_by(slug: params[:post_slug])
    if @post.nil?
      render json: { error: 'Post not found' }, status: :not_found
    end
  end

  def comment_params
    params.require(:comment).permit(:content, :parent_id)
  end
end
