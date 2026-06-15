class AddCurrencyToMenuItems < ActiveRecord::Migration[7.1]
  def change
    add_column :menu_items, :currency, :string
  end
end
