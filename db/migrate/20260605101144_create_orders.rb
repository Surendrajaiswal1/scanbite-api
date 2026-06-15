class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :business_profile, null: false, foreign_key: true
      t.string :customer_name
      t.string :customer_phone
      t.string :customer_email
      t.text :notes
      t.decimal :total_amount
      t.string :status

      t.timestamps
    end
  end
end
