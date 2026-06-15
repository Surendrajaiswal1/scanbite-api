class BusinessProfileService

  def initialize(user, params)
    @user = user
    @params = params
  end

  def create
    profile = @user.build_business_profile(@params)

    if profile.save
      {
        success: true,
        message: "Business profile created successfully",
        data: profile
      }
    else
      {
        success: false,
        errors: profile.errors.to_hash
      }
    end
  end

  def update
    profile = @user.business_profile

    if profile.update(@params)
      {
        success: true,
        message: "Business profile updated successfully",
        data: profile
      }
    else
      {
        success: false,
        errors: profile.errors.to_hash
      }
    end
  end
end