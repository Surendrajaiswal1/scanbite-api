class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:signup, :verify_otp, :login, :resend_otp, :google_auth, :forgot_password, :reset_password]
  
  # POST /api/v1/auth/signup
  def signup
    result = SignupService.new(signup_params).call
    
    if result[:success]
      render json: result, status: :created
    else
      render json: result, status: :unprocessable_entity
    end
  end
  
  # POST /api/v1/auth/verify-otp
  def verify_otp
    begin
      user = User.find_by(email: verify_otp_params[:email])
      raise AuthenticationError, "User not found" unless user
      
      otp_verification = user.otp_verifications.valid.recent.first
      raise AuthenticationError, "No valid OTP found" unless otp_verification
      
      result = otp_verification.verify!(verify_otp_params[:otp_code])
      
      if result[:success]
        user.update(email_verified: true, email_verified_at: Time.current, status: :email_verified)
        
        tokens = JwtService.generate_tokens(user)
        EmailService.send_welcome_email(user)
        
        render json: {
          success: true,
          message: "Email verified successfully",
          data: {
            user_id: user.id,
            email: user.email,
            full_name: user.full_name,
            business_name: user.business_profile&.shop_name,
            business_type: user.business_profile&.business_type,
            is_store_open: user.business_profile&.is_store_open.nil? ? true : user.business_profile.is_store_open,
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token],
            expires_in: tokens[:expires_in]
          }
        }, status: :ok
      else
        render json: {
          success: false,
          message: "OTP verification failed",
          error: result[:error]
        }, status: :unprocessable_entity
      end
    rescue AuthenticationError => e
      render json: {
        success: false,
        message: "Verification failed",
        error: e.message
      }, status: :unprocessable_entity
    end
  end
  
  # POST /api/v1/auth/login
  def login
    begin
      user = User.find_by(email: login_params[:email].downcase)
      
      if user && user.authenticate(login_params[:password])
        unless user.email_verified?
          return render json: {
            success: false,
            message: "Email not verified",
            error: "Please verify your email first"
          }, status: :unauthorized
        end
        
        tokens = JwtService.generate_tokens(user)
        
        render json: {
          success: true,
          message: "Login successful",
          data: {
            user_id: user.id,
            email: user.email,
            full_name: user.full_name,
            business_name: user.business_profile&.shop_name,
            business_type: user.business_profile&.business_type,
            is_store_open: user.business_profile&.is_store_open.nil? ? true : user.business_profile.is_store_open,
            access_token: tokens[:access_token],
            refresh_token: tokens[:refresh_token],
            expires_in: tokens[:expires_in]
          }
        }, status: :ok
      else
        render json: {
          success: false,
          message: "Invalid credentials",
          error: "Email or password is incorrect"
        }, status: :unauthorized
      end
    rescue => e
      render json: {
        success: false,
        message: "Login failed",
        error: e.message
      }, status: :internal_server_error
    end
  end
  
  # POST /api/v1/auth/resend-otp
  def resend_otp
    begin
      user = User.find_by(email: resend_otp_params[:email].downcase)
      raise AuthenticationError, "User not found" unless user
      
      # Delete previous OTPs
      user.otp_verifications.destroy_all
      
      # Create new OTP
      otp_verification = OtpVerification.create_for_user(user, "email")
      EmailService.send_otp_email(user, otp_verification)
      
      render json: {
        success: true,
        message: "New OTP sent to your email",
        data: { email: user.email }
      }, status: :ok
    rescue AuthenticationError => e
      render json: {
        success: false,
        message: "Failed to resend OTP",
        error: e.message
      }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/auth/google
  def google_auth
    token = google_auth_params[:token]

    raise "Google token is required" if token.blank?

    validator = GoogleIDToken::Validator.new

    payload = validator.check(
      token,
      ENV["GOOGLE_CLIENT_ID"]
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

    render json: {
      success: true,
      message: "Google authentication successful",
      data: {
        user_id: user.id,
        email: user.email,
        full_name: user.full_name,
        business_name: user.business_profile&.shop_name,
        business_type: user.business_profile&.business_type,
        is_store_open: user.business_profile&.is_store_open.nil? ? true : user.business_profile.is_store_open,
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token],
        expires_in: tokens[:expires_in]
      }
    }, status: :ok

  rescue GoogleIDToken::ValidationError
    render json: {
      success: false,
      message: "Google authentication failed",
      error: "Invalid Google token"
    }, status: :unauthorized

  rescue => e
    render json: {
      success: false,
      message: "Google authentication failed",
      error: e.message
    }, status: :internal_server_error
  end

  # POST /api/v1/auth/forgot-password
  def forgot_password
    begin
      user = User.find_by(email: forgot_password_params[:email].downcase)
      
      # Always return success for security (don't reveal if email exists)
      unless user
        return render json: {
          success: true,
          message: "If an account exists with this email, a password reset link has been sent"
        }, status: :ok
      end

      # Generate reset token
      reset_token = SecureRandom.urlsafe_base64(32)
      user.update(
        password_reset_token: reset_token,
        password_reset_token_expires_at: Time.current + 1.hour
      )

      # Send email
      EmailService.send_password_reset_email(user, reset_token)

      render json: {
        success: true,
        message: "If an account exists with this email, a password reset link has been sent"
      }, status: :ok
    rescue => e
      render json: {
        success: false,
        message: "Failed to process forgot password request",
        error: e.message
      }, status: :internal_server_error
    end
  end

  # POST /api/v1/auth/reset-password
  def reset_password
    begin
      reset_token = reset_password_params[:token]
      new_password = reset_password_params[:password]
      password_confirmation = reset_password_params[:password_confirmation]

      raise "Token is required" if reset_token.blank?
      raise "Password is required" if new_password.blank?

      user = User.find_by(password_reset_token: reset_token)
      raise "Invalid or expired reset token" unless user

      if user.password_reset_token_expires_at.blank? || user.password_reset_token_expires_at < Time.current
        raise "Reset token has expired"
      end

      raise "Passwords do not match" if new_password != password_confirmation

      user.password = new_password
      user.password_confirmation = password_confirmation
      
      if user.valid?
        user.update(
          password_reset_token: nil,
          password_reset_token_expires_at: nil
        )

        render json: {
          success: true,
          message: "Password reset successfully"
        }, status: :ok
      else
        render json: {
          success: false,
          message: "Password validation failed",
          errors: user.errors.full_messages
        }, status: :unprocessable_entity
      end
    rescue => e
      render json: {
        success: false,
        message: "Password reset failed",
        error: e.message
      }, status: :unprocessable_entity
    end
  end
  
  private
  
  def signup_params
    params.require(:user).permit(
      :full_name, :email, :password, :password_confirmation
    )
  end
  
  def verify_otp_params
    params.require(:verification).permit(:email, :otp_code)
  end
  
  def login_params
    params.require(:credentials).permit(:email, :password)
  end
  
  def resend_otp_params
    params.require(:user).permit(:email)
  end

  def google_auth_params
    params.permit(:token)
  end

  def forgot_password_params
    params.require(:user).permit(:email)
  end

  def reset_password_params
    params.require(:password_reset).permit(:token, :password, :password_confirmation)
  end
end
