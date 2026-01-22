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

  scope :tagged_with, lambda { |names|
    names = Array(names).map { |name| name.to_s.strip.downcase }.reject(&:blank?).uniq
    return all if names.empty?

    tags = Tag.where(name: names)
    return none if tags.empty?

    tag_ids = tags.select(:id)
    tag_count = tags.count

    post_taggings = Tagging.where(taggable_type: "Post", tag_id: tag_ids)
      .select("taggable_id AS post_id, tag_id")
    comment_taggings = Tagging.joins("INNER JOIN comments ON comments.id = taggings.taggable_id")
      .where(taggable_type: "Comment", tag_id: tag_ids)
      .select("comments.post_id AS post_id, taggings.tag_id")
    union_sql = "#{post_taggings.to_sql} UNION ALL #{comment_taggings.to_sql}"

    joins("INNER JOIN (#{union_sql}) AS combined_tags ON combined_tags.post_id = posts.id")
      .group("posts.id")
      .having("COUNT(DISTINCT combined_tags.tag_id) = ?", tag_count)
  }
end
