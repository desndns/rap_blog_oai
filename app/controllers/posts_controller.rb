class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]
  before_action :require_login, except: %i[index show]
  before_action :require_post_owner, only: %i[edit update destroy]

  def index
    @query = params[:q]
    @posts = Post.search(@query).order(created_at: :desc)
  end

  def show
    @comments = @post.comments.order(created_at: :desc)
    @comment = @post.comments.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user

    if @post.save
      redirect_to @post, notice: "Post created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, images: [], files: [])
  end

  def require_post_owner
    return if admin? || @post.user == current_user

    redirect_to @post, alert: "You can only change your own posts."
  end
end
