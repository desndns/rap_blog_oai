class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many_attached :images
  has_many_attached :files

  validates :title, presence: true
  validates :body, presence: true
end
