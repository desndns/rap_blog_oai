class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many_attached :images
  has_many_attached :files

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
end
