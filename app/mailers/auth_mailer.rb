class AuthMailer < ApplicationMailer
  default from: ENV.fetch("EMAIL_FROM") { "noreply@scanbite.com" }
  
  def otp_verification(user, otp_code)
    @user = user
    @otp_code = otp_code
    @expires_in_minutes = 10
    
    mail(
      to: user.email,
      subject: "ScanBite - Verify Your Email with OTP"
    )
  end
  
  def welcome_email(user)
    @user = user
    @business_slug = user.business_slug
    
    mail(
      to: user.email,
      subject: "Welcome to ScanBite! 🎉"
    )
  end

  def password_reset(user, reset_token)
    @user = user
    @reset_token = reset_token
    @reset_url = "#{ENV.fetch('FRONTEND_URL') { 'http://localhost:5173' }}/reset-password?token=#{reset_token}"
    
    mail(
      to: user.email,
      subject: "ScanBite - Reset Your Password"
    )
  end
end
