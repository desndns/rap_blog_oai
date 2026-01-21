module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings
  end

  def tag_list
    tags.order(:name).pluck(:name).join(", ")
  end

  def tag_list=(value)
    names = value.to_s.split(",").map { |name| name.strip.downcase }.reject(&:blank?).uniq
    self.tags = names.map { |name| Tag.find_or_create_by!(name: name) }
  end
end
