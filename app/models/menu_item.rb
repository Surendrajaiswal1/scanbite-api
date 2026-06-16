class MenuItem < ApplicationRecord
  belongs_to :business_profile
  has_one_attached :image
  
  validates :name, presence: true, length: { minimum: 2, maximum: 80 }, format: { with: /[a-zA-Z]/, message: "must contain at least one letter" }
  validates :category, presence: true, length: { minimum: 2, maximum: 40 }, format: { with: /\A[a-zA-Z0-9\s&,.'-]+\z/, message: "contains invalid characters" }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999999 }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 99999 }, allow_nil: true
  validates :discount, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 999999 }, allow_nil: true
  validates :currency, inclusion: { in: %w[INR USD EUR GBP], message: "must be a valid currency" }, allow_blank: true
  validate :discount_cannot_exceed_price
  
  def image_url
    # Explicitly providing the host to avoid ArgumentError in API mode
    Rails.application.routes.url_helpers.rails_blob_url(image, host: ENV.fetch("API_HOST", "http://localhost:3000")) if image.attached?
  end

  before_save :calculate_final_price
  
  private
  
  def discount_cannot_exceed_price
    if discount.present? && price.present? && discount > price
      errors.add(:discount, "cannot be greater than price")
    end
  end

  def calculate_final_price
    discount_val = discount || 0
    if price
      calculated = price - discount_val
      self.final_price = calculated < 0 ? 0 : calculated
    end
  end
end
