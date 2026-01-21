class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user
  has_many_attached :images
  has_many_attached :files
  include Taggable

  validates :body, presence: true
end
