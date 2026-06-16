class BusinessProfile < ApplicationRecord
  belongs_to :user
  has_many :menu_items, dependent: :destroy
  has_many :orders, dependent: :destroy
  
  # Enums
  enum :business_type, { restaurant: "restaurant", cafe: "cafe", bakery: "bakery", retail: "retail", shop: "shop", other: "other" }
  
  # Validations
  validates :shop_name, presence: true, length: { minimum: 3, maximum: 50 }, format: { with: /[a-zA-Z]/, message: "must contain at least one letter" }
  validates :phone_number, presence: true, format: { with: /\A\+?[\d\s\-()]{7,20}\z/, message: "must be a valid phone number" }
  validates :address, presence: true, length: { minimum: 5, maximum: 200 }, format: { with: /[a-zA-Z0-9]/, message: "must contain at least one letter or number" }
  validates :business_type, presence: true, inclusion: { in: business_types.keys }
  validates :business_slug, presence: true, uniqueness: true
  validates :upi_id, presence: true, format: { with: /\A[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}\z/, message: "must be a valid UPI ID format (e.g., name@bank)" }
  
  # Callbacks
  before_validation :generate_business_slug, on: :create
  
  private
  
  def generate_business_slug
    return if shop_name.blank?
    self.business_slug = shop_name.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
  end
end
