module Auth
  class ResendOtpService
    def initialize(email:)
      @email = email.downcase.strip
    end

    def call
      user = User.find_by(email: @email)

      return failure("User not found") unless user

      user.otp_verifications.destroy_all

      otp_verification = OtpVerification.create_for_user(user)

      EmailService.send_otp_email(user, otp_verification)

      {
        success: true,
        message: "New OTP sent successfully",
        data: {
          email: user.email
        }
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