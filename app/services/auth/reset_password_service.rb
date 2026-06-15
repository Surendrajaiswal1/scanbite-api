module Auth
  class ResetPasswordService
    def initialize(params)
      @token = params[:token]
      @password = params[:password]
      @password_confirmation = params[:password_confirmation]
    end

    def call
      user = User.find_by(password_reset_token: @token)

      return failure("Invalid or expired reset token") unless user

      if user.password_reset_token_expires_at.blank? ||
         user.password_reset_token_expires_at.past?
        return failure("Reset token has expired")
      end

      user.password = @password
      user.password_confirmation = @password_confirmation

      unless user.valid?
        return {
          success: false,
          errors: user.errors.full_messages
        }
      end

      user.save!

      user.update!(
        password_reset_token: nil,
        password_reset_token_expires_at: nil
      )

      {
        success: true,
        message: "Password reset successfully"
      }
    end

    private

    def failure(error)
      {
        success: false,
        error: error
      }
    end
  end
end