class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many_attached :images
  has_many_attached :files
  include Taggable

  validates :title, presence: true
  validates :body, presence: true

  scope :search, lambda { |query|
    return all if query.blank?

    term = "%#{sanitize_sql_like(query)}%"
    left_joins(:comments).where(
      "posts.title LIKE :term OR posts.body LIKE :term OR comments.body LIKE :term OR comments.author LIKE :term",
      term: term
    ).distinct
  }

  scope :tagged_with, lambda { |name|
    return all if name.blank?

    tag = Tag.find_by(name: name.to_s.strip.downcase)
    return none unless tag

    post_ids = tag.taggings.where(taggable_type: "Post").select(:taggable_id)
    comment_post_ids = Comment.joins(:taggings).where(taggings: { tag_id: tag.id }).select(:post_id)

    where(id: post_ids).or(where(id: comment_post_ids)).distinct
  }
end
