module Auth
  class VerifyOtpService
    def initialize(email:, otp_code:)
      @email = email.downcase.strip
      @otp_code = otp_code
    end

    def call
      user = User.find_by(email: @email)

      return failure("User not found") unless user

      otp_verification = user.otp_verifications.valid.recent.first

      return failure("No valid OTP found") unless otp_verification

      result = otp_verification.verify!(@otp_code)

      return failure(result[:error]) unless result[:success]

      user.update!(
        email_verified: true,
        email_verified_at: Time.current,
        status: :email_verified
      )

      EmailService.send_welcome_email(user)

      tokens = JwtService.generate_tokens(user)

      success(
        message: "Email verified successfully",
        data: UserSerializer.call(user).merge(tokens)
      )
    end

    private

    def success(message:, data:)
      {
        success: true,
        message: message,
        data: data
      }
    end

    def failure(error)
      {
        success: false,
        error: error
      }
    end

    # def serialized_user(user)
    #   {
    #     user_id: user.id,
    #     email: user.email,
    #     full_name: user.full_name,
    #     business_name: user.business_profile&.business_name,
    #     business_type: user.business_profile&.business_type
    #   }
    # end
  end
end