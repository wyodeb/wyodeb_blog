class PostsController < ApplicationController
  include Authenticable
  before_action :set_post, only: %i[show update destroy]
  before_action :authenticate_user!, only: %i[create update destroy]
  before_action :authorize_poster!, only: %i[create update destroy]

  # GET /posts
  def index
    @posts = Post.all
    render json: @posts
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    @post = current_user.posts.new(post_params)
    if @post.save
      render json: @post, status: :created, location: @post
    else
      log_error(@post.errors.full_messages)
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    head :no_content
  end

  private


  def authorize_poster!
    unless current_user&.poster?
      render json: { error: 'You are not authorized to perform this action' }, status: :forbidden
    end
  end

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :published_on)
  end

  def log_error(messages)
    Rails.logger.error("Post creation failed: #{messages.join(', ')}")
  end
end
