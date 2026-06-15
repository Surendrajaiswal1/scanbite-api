class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      # Identity Information
      t.string :full_name, null: false
      t.string :email, null: false
      
      # Authentication
      t.string :password_digest, null: false
      
      # Account Status
      t.integer :status, default: 0, null: false
      t.boolean :email_verified, default: false
      t.datetime :email_verified_at
      
      # OAuth (optional for future implementation)
      t.string :google_uid
      t.boolean :onboarding_completed, default: false
      
      t.timestamps
    end
    
    # Indexes for commonly searched fields
    add_index :users, :email, unique: true
    add_index :users, :status
  end
end
