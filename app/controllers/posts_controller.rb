class PostsController < ApplicationController
  include Authenticable
  before_action :set_post, only: %i[show update destroy]
  before_action :authorize_poster!, only: %i[create update destroy]


  def index
    if current_user
      posts = Post.where(user_id: current_user.id).or(Post.where(status: 'published'))
    else
      # Non-authenticated users: show only published posts
      posts = Post.where(status: 'published')
    end

    # Include status information for authenticated users, exclude for others
    render json: posts.as_json(current_user ? { methods: :status } : { except: :status })
  end










  # GET /posts/1
  def show
    Rails.logger.info "Handling POST show action"
    if current_user == @post.user
      render json: @post.as_json(methods: :status)
    elsif @post.status == 'published'
      render json: @post.as_json(except: :status)
    else
      render  status: :not_found
    end
  end




  # POST /posts
  def create
    @post = current_user.posts.new(post_params)

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
