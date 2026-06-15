class CreateMenuItems < ActiveRecord::Migration[7.1]
  def change
    create_table :menu_items do |t|
      t.references :business_profile, null: false, foreign_key: true
      t.string :name
      t.string :category
      t.text :description
      t.integer :quantity
      t.decimal :price
      t.decimal :discount
      t.decimal :final_price

      t.timestamps
    end
  end
end
