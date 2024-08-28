class PostsController < ApplicationController
  include Authenticable
  before_action :set_post, only: %i[show update destroy]
  before_action :authorize_poster!, only: %i[create update destroy]

  # GET /posts
  def index
    posts = if current_user
              Post.all
            else
              Post.where.not(status: 'draft')
            end

    render json: posts.as_json(methods: :status)
  end

  # GET /posts/1
  def show
    post_data = @post.as_json(methods: :status) # Include the status attribute in the JSON output

    if current_user == @post.user || post_data['status']
      # If the current user is the author or the status is present, include status
      render json: post_data
    else
      # Otherwise, exclude status from the JSON output
      render json: @post.as_json(except: :status)
    end
  end


  # POST /posts
  def create
    @post = current_user.posts.new(post_params.merge(status: :draft))

    if @post.save
      render json: @post.as_json(methods: :status), status: :created
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      render json: @post.as_json(methods: :status)
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

  def set_post
    @post = Post.find_by!(slug: params[:slug])
  end

  def post_params
    params.require(:post).permit(:title, :content, :published_on, :status)
  end

  def authorize_poster!
    render json: { error: 'Forbidden' }, status: :forbidden unless current_user&.poster?
  end
end
