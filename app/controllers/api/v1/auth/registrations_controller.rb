class Api::V1::Auth::RegistrationsController < Api::V1::BaseController
  skip_before_action :authenticate_user!

  def create
    result = Auth::SignupService.new(signup_params).call

    if result[:success]
      render json: result, status: :created
    else
      render json: result, status: :unprocessable_content
    end
  end

  private

  def signup_params
    params.require(:user).permit(
      :full_name,
      :email,
      :password,
      :password_confirmation
    )
  end
end