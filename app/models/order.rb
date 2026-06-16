class Order < ApplicationRecord
  belongs_to :business_profile
  has_many :order_items, dependent: :destroy

  validates :customer_name, presence: true, length: { minimum: 2, maximum: 50 }, format: { with: /\A[a-zA-Z\s.]+\z/, message: "must contain only letters, spaces, or periods" }
  validates :customer_phone, presence: true, format: { with: /\A\+?[\d\s\-()]{7,20}\z/, message: "must be a valid phone number" }
  validates :status, presence: true, inclusion: { in: %w[pending preparing ready completed cancelled rejected] }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :order_number, presence: true
  validates :notes, length: { maximum: 200 }, allow_blank: true
  validates :payment_method, inclusion: { in: ["Cash on Counter", "Online Payment"] }, allow_blank: true
  validates :payment_status, inclusion: { in: %w[Pending Paid Failed Refunded] }, allow_blank: true
end
