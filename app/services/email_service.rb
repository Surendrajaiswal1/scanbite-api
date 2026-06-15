class EmailService
  class << self
    def send_otp_email(user, otp_verification)
      begin
        AuthMailer.otp_verification(user, otp_verification.otp_code).deliver_later
        Rails.logger.info("OTP email queued for #{user.email}")
        true
      rescue => e
        Rails.logger.error("Failed to send OTP email: #{e.message}")
        false
      end
    end
    
    def send_welcome_email(user)
      begin
        AuthMailer.welcome_email(user).deliver_later
        Rails.logger.info("Welcome email queued for #{user.email}")
        true
      rescue => e
        Rails.logger.error("Failed to send welcome email: #{e.message}")
        false
      end
    end

    def send_password_reset_email(user, reset_token)
      begin
        AuthMailer.password_reset(user, reset_token).deliver_later
        Rails.logger.info("Password reset email queued for #{user.email}")
        true
      rescue => e
        Rails.logger.error("Failed to send password reset email: #{e.message}")
        false
      end
    end
  end
end
