module Auth
  class SignupService
    def initialize(params)
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        create_user!
        create_otp!
      end

      send_otp_email

      {
        success: true,
        message: "Signup successful. Please verify your email.",
        data: UserSerializer.call(@user)
      }
    rescue ActiveRecord::RecordInvalid => e
      {
        success: false,
        message: "Signup failed",
        errors: format_errors(e.record.errors)
      }
    rescue StandardError => e
      Rails.logger.error("[SignupService] #{e.message}")

      {
        success: false,
        message: "Signup failed",
        errors: { base: ["Something went wrong"] }
      }
    end

    private

    def create_user!
      @user = User.create!(user_params)
    end

    def create_otp!
      @otp = OtpVerification.create_for_user(@user)
    end

    def send_otp_email
      EmailService.send_otp_email(@user, @otp)
    end

    def user_params
      @params.slice(
        :full_name,
        :email,
        :password,
        :password_confirmation
      )
    end

    def format_errors(errors)
      errors.messages.each_with_object({}) do |(key, messages), hash|
        hash[key] = messages
      end
    end
  end
end