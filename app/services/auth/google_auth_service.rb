module Auth
  class GoogleAuthService
    def initialize(token)
      @token = token
    end

    def call
      validator = GoogleIDToken::Validator.new

      payload = validator.check(
        @token,
        ENV.fetch("GOOGLE_CLIENT_ID")
      )

      email = payload["email"]
      full_name = payload["name"]

      user = User.find_by(email: email.downcase)

      unless user
        password = "#{SecureRandom.hex(8)}Aa@1"

        user = User.create!(
          full_name: full_name,
          email: email.downcase,
          password: password,
          password_confirmation: password,
          email_verified: true,
          email_verified_at: Time.current,
          status: :email_verified
        )
      end

      tokens = JwtService.generate_tokens(user)

      {
        success: true,
        message: "Google authentication successful",
        data: UserSerializer.call(user).merge(tokens)
      }
    rescue GoogleIDToken::ValidationError => e
      Rails.logger.error("[GoogleAuthService] Validation error: #{e.message}")
      
      {
        success: false,
        error: "Invalid Google token"
      }
    rescue => e
      Rails.logger.error("[GoogleAuthService] Error: #{e.message}")
      
      {
        success: false,
        error: "Authentication failed"
      }
    end
  end
end