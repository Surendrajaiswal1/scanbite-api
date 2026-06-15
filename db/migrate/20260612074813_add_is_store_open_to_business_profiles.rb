class AddIsStoreOpenToBusinessProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :business_profiles, :is_store_open, :boolean, default: true
  end
end
