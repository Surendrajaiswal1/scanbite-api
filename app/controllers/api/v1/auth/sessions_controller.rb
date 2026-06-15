class Api::V1::Auth::SessionsController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def create
    result = Auth::LoginService.new(login_params).call

    render json: result,
           status: result[:success] ? :ok : :unauthorized
  end

  private

  def login_params
    params.require(:credentials).permit(:email, :password)
  end
end