module Auth
  class ForgotPasswordService
    def initialize(params)
      @email = params[:email].downcase.strip
    end

    def call
      user = User.find_by(email: @email)

      if user
        token = SecureRandom.urlsafe_base64(32)

        user.update!(
          password_reset_token: token,
          password_reset_token_expires_at: 1.hour.from_now
        )

        EmailService.send_password_reset_email(user, token)
      end

      {
        success: true,
        message: "If an account exists with this email, a password reset link has been sent"
      }
    end
  end
end