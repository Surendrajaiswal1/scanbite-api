class AddCustomBusinessTypeToBusinessProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :business_profiles, :custom_business_type, :string
  end
end
