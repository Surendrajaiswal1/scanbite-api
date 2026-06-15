class AddBusinessSlugToBusinessProfiles < ActiveRecord::Migration[7.1]
  def change
    add_column :business_profiles, :business_slug, :string
    add_index :business_profiles, :business_slug, unique: true
  end
end
