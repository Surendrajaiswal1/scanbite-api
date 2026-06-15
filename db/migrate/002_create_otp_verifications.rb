class CreateOtpVerifications < ActiveRecord::Migration[7.1]
  def change
    create_table :otp_verifications do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      
      t.string :email, null: false
      t.string :otp_code, null: false
      t.string :otp_type, default: "email"
      
      t.datetime :expires_at, null: false
      t.datetime :verified_at
      
      t.integer :attempt_count, default: 0
      t.boolean :verified, default: false
      
      t.timestamps
    end
    
    # Add indexes
    add_index :otp_verifications, :email
    add_index :otp_verifications, [:email, :otp_code]
  end
end
