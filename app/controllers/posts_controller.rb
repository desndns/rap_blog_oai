class PostsController < ApplicationController
  before_action :set_post, only: %i[show edit update destroy]
  before_action :require_login, except: %i[index show]
  before_action :require_post_owner, only: %i[edit update destroy]

  def index
    @query = params[:q]
    @tags = parse_tags(params[:tags].presence || params[:tag])
    @sort = params[:sort].presence || "date_desc"
    @from = parse_date(params[:from])
    @to = parse_date(params[:to])
    @user_id = params[:user_id].presence

    base = Post.search(@query).tagged_with(@tags).left_joins(:user, :tags).distinct
    base = apply_date_range(base, @from, @to)
    base = apply_user_filter(base, @user_id)
    @posts = apply_sort(base, @sort)
  end

  def find
    @query = params[:q]
    @tags = parse_tags(params[:tags].presence || params[:tag])
    @sort = params[:sort].presence || "date_desc"
    @from = parse_date(params[:from])
    @to = parse_date(params[:to])
    @user_id = params[:user_id].presence

    base = Post.search(@query).tagged_with(@tags).left_joins(:user, :tags).distinct
    base = apply_date_range(base, @from, @to)
    base = apply_user_filter(base, @user_id)
    @posts = apply_sort(base, @sort)
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
    if @post.update(post_update_params)
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
    params.require(:post).permit(:title, :body, :tag_list, images: [], files: [])
  end

  def post_update_params
    strip_empty_attachments(post_params, :images, :files)
  end

  def require_post_owner
    return if admin? || @post.user == current_user

    redirect_to @post, alert: "You can only change your own posts."
  end

  def apply_sort(scope, sort)
    case sort
    when "date_asc"
      scope.order(created_at: :asc)
    when "author"
      scope.order(Arel.sql("users.email ASC"), created_at: :desc)
    when "tags"
      scope.group("posts.id").order(Arel.sql("MIN(tags.name) ASC"), created_at: :desc)
    else
      scope.order(created_at: :desc)
    end
  end

  def apply_date_range(scope, from_date, to_date)
    return scope unless from_date || to_date

    if from_date && to_date
      scope.where(created_at: from_date.beginning_of_day..to_date.end_of_day)
    elsif from_date
      scope.where("posts.created_at >= ?", from_date.beginning_of_day)
    else
      scope.where("posts.created_at <= ?", to_date.end_of_day)
    end
  end

  def apply_user_filter(scope, user_id)
    return scope if user_id.blank?

    scope.where(posts: { user_id: user_id })
  end

  def parse_date(value)
    return nil if value.blank?

    Date.iso8601(value)
  rescue Date::Error
    nil
  end

  def parse_tags(value)
    case value
    when Array
      value.map(&:to_s)
    when nil
      []
    else
      value.to_s.split(",")
    end.map { |name| name.strip.downcase }.reject(&:blank?).uniq
  end
end
