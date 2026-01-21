class CommentsController < ApplicationController
  before_action :set_post

  def create
    @comment = @post.comments.new(comment_params)

    if @comment.save
      redirect_to @post, notice: "Comment added."
    else
      @comments = @post.comments.order(created_at: :desc)
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    comment = @post.comments.find(params[:id])
    comment.destroy
    redirect_to @post, notice: "Comment removed."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:author, :body)
  end
end
