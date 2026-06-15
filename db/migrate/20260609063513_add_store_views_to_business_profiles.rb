class AddStoreViewsToBusinessProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :business_profiles, :store_views, :integer, default: 0
  end
end
