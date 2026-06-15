class UserSerializer
  def self.call(user)
    {
      user_id: user.id,
      email: user.email,
      full_name: user.full_name,
      onboarding_completed: user.onboarding_completed,
      business_name: user.business_profile&.shop_name,
      business_type: user.business_profile&.business_type,
      is_store_open: user.business_profile&.is_store_open.nil? ? true : user.business_profile.is_store_open
    }
  end
end