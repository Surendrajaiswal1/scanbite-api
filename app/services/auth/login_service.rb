module Auth
  class LoginService
    def initialize(params)
      @email = params[:email].to_s.downcase.strip
      @password = params[:password]
    end

    def call
        user = User.find_by(email: email)

        Rails.logger.debug "USER FOUND: #{user.present?}"

        return invalid_credentials unless valid_user?(user)

        Rails.logger.debug "PASSWORD VALID"

        return email_not_verified unless user.email_verified?

        Rails.logger.debug "EMAIL VERIFIED"

        tokens = JwtService.generate_tokens(user)

        {
            success: true,
            message: "Login successful",
            data: UserSerializer.call(user).merge(tokens)
        }
    end

    private

    attr_reader :email, :password

    def valid_user?(user)
        Rails.logger.debug "AUTH RESULT: #{user&.authenticate(password).present?}"
      user.present? && user.authenticate(password)
    end

    def invalid_credentials
      {
        success: false,
        message: "Invalid credentials",
        error: "Email or password is incorrect"
      }
    end

    def email_not_verified
      {
        success: false,
        message: "Email not verified",
        error: "Please verify your email first"
      }
    end
  end
end