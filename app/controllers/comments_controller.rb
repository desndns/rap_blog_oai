class CommentsController < ApplicationController
  before_action :set_post
  before_action :require_login, only: %i[create destroy]
  before_action :require_comment_owner, only: :destroy

  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user
    @comment.author = current_user.email

    if @comment.save
      redirect_to @post, notice: "Comment added."
    else
      @comments = @post.comments.order(created_at: :desc)
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    redirect_to @post, notice: "Comment removed."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def require_comment_owner
    @comment = @post.comments.find(params[:id])
    return if admin? || @comment.user == current_user

    redirect_to @post, alert: "You can only remove your own comments."
  end

  def comment_params
    params.require(:comment).permit(:body, :tag_list, images: [], files: [])
  end
end
