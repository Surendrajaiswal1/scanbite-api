class Api::V1::Auth::PasswordsController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def forgot
    result = Auth::ForgotPasswordService.new(forgot_password_params).call

    render json: result, status: :ok
  end

  def reset
    result = Auth::ResetPasswordService.new(reset_password_params).call

    if result[:success]
      render json: result, status: :ok
    else
      render json: result, status: :unprocessable_entity
    end
  end

  private

  def forgot_password_params
    params.require(:user)
          .permit(:email)
  end

  def reset_password_params
    params.require(:password_reset)
          .permit(:token, :password, :password_confirmation)
  end
end