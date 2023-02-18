class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  before_perform do |job|
    SiteSettings.clear_cache
  end

  def self.case_insensitive_glob(extensions)
    lower = extensions.map(&:downcase)
    upper = extensions.map(&:upcase)
    "*.{#{lower.zip(upper).flatten.join(",")}}"
  end

  def self.image_pattern
    case_insensitive_glob Mime::EXTENSION_LOOKUP.filter { |k, v| v.to_s.start_with?("image") }.keys
  end

  def self.file_pattern
    case_insensitive_glob Mime::EXTENSION_LOOKUP.filter { |k, v| v.to_s.start_with?("image", "model") }.keys
  end
end
