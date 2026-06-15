class Api::V1::Auth::OtpVerificationsController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def create
    result = Auth::VerifyOtpService.new(
      **verify_otp_params.to_h.symbolize_keys
    ).call

    render json: result,
           status: result[:success] ? :ok : :unprocessable_entity
  end

  def resend
    result = Auth::ResendOtpService.new(
      **resend_otp_params.to_h.symbolize_keys
    ).call

    render json: result,
           status: result[:success] ? :ok : :unprocessable_entity
  end

  private

  def verify_otp_params
    params.require(:verification)
          .permit(:email, :otp_code)
  end

  def resend_otp_params
    params.require(:user)
          .permit(:email)
  end
end