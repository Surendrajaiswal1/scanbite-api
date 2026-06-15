class BusinessProfile < ApplicationRecord
  belongs_to :user
  has_many :menu_items, dependent: :destroy
  has_many :orders, dependent: :destroy
  
  # Enums
  enum :business_type, { restaurant: "restaurant", cafe: "cafe", bakery: "bakery", retail: "retail", shop: "shop", other: "other" }
  
  # Validations
  validates :shop_name, presence: true, length: { minimum: 3, maximum: 50 }
  validates :phone_number, presence: true
  validates :address, presence: true
  validates :business_type, presence: true, inclusion: { in: business_types.keys }
  validates :business_slug, presence: true, uniqueness: true
  validates :upi_id, presence: true
  
  # Callbacks
  before_validation :generate_business_slug, on: :create
  
  private
  
  def generate_business_slug
    return if shop_name.blank?
    self.business_slug = shop_name.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
  end
end
