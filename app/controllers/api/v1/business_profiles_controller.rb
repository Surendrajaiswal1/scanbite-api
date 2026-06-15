class Api::V1::BusinessProfilesController < Api::V1::BaseController

  def show
    profile = current_user.business_profile

    render json: {
      success: true,
      data: profile
    }
  end

  def create
    result = BusinessProfileService.new(
      current_user,
      business_profile_params
    ).create

    render json: result,
           status: result[:success] ? :created : :unprocessable_content
  end

  def update
    result = BusinessProfileService.new(
      current_user,
      business_profile_params
    ).update

    render json: result,
           status: result[:success] ? :ok : :unprocessable_content
  end

  def complete_onboarding
    current_user.update!(onboarding_completed: true)

    render json: {
      success: true,
      message: "Onboarding completed successfully"
    }
  end

  private

  def business_profile_params
    params.require(:business_profile).permit(
      :shop_name,
      :phone_number,
      :address,
      :upi_id,
      :business_type,
      :custom_business_type,
      :country_code,
      :is_store_open
    )
  end
end