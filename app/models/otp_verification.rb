class OtpVerification < ApplicationRecord
  # Associations
  belongs_to :user
  
  # Validations
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :otp_code, presence: true
  validates :otp_type, inclusion: { in: %w(email sms) }
  validates :expires_at, presence: true
  validates :user_id, presence: true
  
  # Scopes
  scope :valid, -> { where("expires_at > ?", Time.current).where(verified: false) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :recent, -> { order(created_at: :desc) }
  
  # Constants
  OTP_VALIDITY_DURATION = 10.minutes
  
  # Class methods
  def self.generate_otp(length = 6)
      rand(10**(length - 1)...10**length).to_s
  end
  
  def self.create_for_user(user, otp_type = "email")
    otp_code = generate_otp(6)
    
    create(
      user: user,
      email: user.email,
      otp_code: otp_code,
      otp_type: otp_type,
      expires_at: Time.current + OTP_VALIDITY_DURATION
    )
  end
  
  # Instance methods
  def verify!(otp_code)
    if expired?
      return { success: false, error: "OTP has expired" }
    end
    
    if attempt_count >= 5
      return { success: false, error: "Too many attempts. Please request a new OTP" }
    end
    
    increment!(:attempt_count)
    
    if self.otp_code == otp_code
      update(verified: true, verified_at: Time.current)
      return { success: true, message: "OTP verified successfully" }
    else
      return { success: false, error: "Invalid OTP code" }
    end
  end
  
  def expired?
    expires_at <= Time.current
  end
  
  def active?
    !expired? && !verified?
  end
end
