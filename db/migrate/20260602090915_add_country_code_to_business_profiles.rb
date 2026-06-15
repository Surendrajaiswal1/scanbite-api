class AddCountryCodeToBusinessProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :business_profiles, :country_code, :string
  end
end
