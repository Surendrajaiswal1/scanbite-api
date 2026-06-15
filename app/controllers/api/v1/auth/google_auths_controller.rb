class Api::V1::Auth::GoogleAuthsController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def create
    result = Auth::GoogleAuthService.new(
      google_auth_params[:token]
    ).call

    if result[:success]
      render json: result, status: :ok
    else
      render json: result, status: :unauthorized
    end
  end

  private

  def google_auth_params
    params.permit(:token)
  end
end