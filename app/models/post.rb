class Post < ApplicationRecord
  has_rich_text :content

  validates :title, length: { maximum: 32 }, presence: true

  validate :validate_content_length
  validate :validate_content_attachment_byte_size
  validate :validate_content_attachment_count

  MAX_CONTENT_LENGTH = 50
  ONE_KILOBYTE = 1024
  MEGA_BYTE = 4
  MAX_CONTENT_ATTACHMENT_BYTE_SIZE = MEGA_BYTE * 1_000 * ONE_KILOBYTE
  MAX_COUNT = 4

  def validate_content_length
  length = content.to_plain_text.length

    if  length > MAX_CONTENT_LENGTH
      errors.add(
        :content,
        :too_long,
        max_content_length: MAX_CONTENT_LENGTH,
        length: length
      )
    end
  end

  def validate_content_attachment_byte_size
    content.body.attachables.grep(ActiveStorage::Blob).each do |attachable|
      if attachable.byte_size > MAX_CONTENT_ATTACHMENT_BYTE_SIZE
        errors.add(
          :base,
          :content_attachment_byte_size_is_too_big,
          max_content_attachment_mega_byte_size: MEGA_BYTE,
          bytes: attachable.byte_size,
          max_bytes: MAX_CONTENT_ATTACHMENT_BYTE_SIZE
        )
      end
    end
  end

  def validate_content_attachment_count
    count = content.body.attachables.grep(ActiveStorage::Blob).count
    if count > MAX_COUNT
      errors.add(
        :content,
        :count_is_too_big,
        max_content_count: MAX_COUNT,

      )
    end
  end
end
