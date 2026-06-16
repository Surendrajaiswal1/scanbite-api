class User < ApplicationRecord
  # Associations
  has_many :otp_verifications, dependent: :destroy
  has_one :business_profile, dependent: :destroy
  
  # Authentication
  has_secure_password
  
  # Enums
  enum :status, { pending: 0, email_verified: 1, active: 2 }
  
  # Validations - Identity Only
  validates :full_name, presence: true, length: { minimum: 3, maximum: 50 }, format: { with: /\A[a-zA-Z\s\-']+\z/, message: "must contain only letters, spaces, hyphens, or apostrophes" }
  validates :full_name, format: { with: /[a-zA-Z]/, message: "must contain at least one letter" }
  
  validates :email, presence: true, 
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email" }
  
  # validates :phone_number, presence: true,
  #           uniqueness: true,
  #           format: { with: /\A\d{10,15}\z/, message: "must contain 10-15 digits" }
  
  validates :password, presence: true, length: { minimum: 8 }, 
            format: { 
              with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@#$%^&*!])[A-Za-z\d@#$%^&*!]+\z/,
              message: "must include uppercase, lowercase, number, and special character"
            }, if: :password_digest_changed?
  
  validates :password_confirmation, presence: true, if: :password_digest_changed?
  
  validates :status, presence: true, inclusion: { in: statuses.keys }
  
  # Callbacks
  before_save :normalize_email
  
  # Scopes
  scope :verified, -> { where(email_verified: true) }
  scope :unverified, -> { where(email_verified: false) }
  scope :active, -> { where(status: :active) }
  
  private
  
  def normalize_email
    self.email = email&.downcase&.strip
    # self.phone_number = phone_number&.gsub(/\D/, "")
  end
end
