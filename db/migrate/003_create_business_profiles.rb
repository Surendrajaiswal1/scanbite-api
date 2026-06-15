class CreateBusinessProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :business_profiles do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      
      t.string :shop_name, null: false
      t.string :phone_number, null: false
      t.text :address, null: false
      t.string :upi_id, null: false
      t.string :business_type, null: false
      
      t.timestamps
    end
    
  end
end
