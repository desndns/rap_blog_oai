class ApplicationController < ActionController::Base
  include Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def strip_empty_attachments(params, *keys)
    cleaned = params.dup
    keys.each do |key|
      value = cleaned[key]
      if value.blank?
        cleaned.delete(key)
        next
      end

      cleaned[key] = Array(value).reject(&:blank?)
      cleaned.delete(key) if cleaned[key].empty?
    end
    cleaned
  end
end
