class AddPaymentDetailsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :payment_method, :string
    add_column :orders, :payment_status, :string
    add_column :orders, :order_number, :string
  end
end
