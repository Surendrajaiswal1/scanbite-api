module Api
  module V1
    class PublicMenusController < ApplicationController
      skip_before_action :authenticate_user! # Public endpoint

      def show
        business_profile = BusinessProfile.find_by(business_slug: params[:slug])

        unless business_profile
          return render json: { success: false, message: "Shop not found" }, status: :not_found
        end

        business_profile.increment!(:store_views)

        render json: {
          success: true,
          data: {
            business_profile: business_profile.as_json(except: [:created_at, :updated_at, :user_id]),
            menu_items: business_profile.menu_items.order(id: :asc).as_json(methods: :image_url, except: [:created_at, :updated_at, :business_profile_id])
          }
        }
      end

      def create_order
        business_profile = BusinessProfile.find_by(business_slug: params[:slug])
        
        unless business_profile
          return render json: { success: false, message: "Shop not found" }, status: :not_found
        end

        unless business_profile.is_store_open
          return render json: { success: false, message: "Sorry, this store is currently not accepting orders." }, status: :unprocessable_content
        end

        items = params[:items]
        customer_details = params[:customerDetails] || {}
        
        unless items && items.is_a?(Array)
          return render json: { success: false, message: "Invalid order payload" }, status: :unprocessable_content
        end

        total_amount = 0
        order_number = "ORD-#{SecureRandom.hex(4).upcase}"
        order = nil

        ActiveRecord::Base.transaction do
          order = Order.create!(
            business_profile: business_profile,
            customer_name: customer_details[:name],
            customer_phone: customer_details[:phone],
            customer_email: customer_details[:email],
            notes: customer_details[:notes],
            status: "pending",
            total_amount: 0,
            payment_method: params[:paymentMethod] || "Cash on Counter",
            payment_status: params[:paymentStatus] || "Pending",
            order_number: order_number
          )

          items.each do |item_data|
            menu_item = business_profile.menu_items.find_by(id: item_data[:id])
            if menu_item
              requested_qty = item_data[:quantity].to_i
              if menu_item.quantity >= requested_qty
                menu_item.update!(quantity: menu_item.quantity - requested_qty)
                price = menu_item.final_price || menu_item.price
                
                OrderItem.create!(
                  order: order,
                  menu_item: menu_item,
                  quantity: requested_qty,
                  unit_price: price
                )
                
                total_amount += (price * requested_qty)
              else
                raise ActiveRecord::Rollback
              end
            end
          end

          order.update!(total_amount: total_amount)
        end

        render json: { 
          success: true, 
          message: "Order placed successfully",
          order: {
            order_number: order.order_number,
            payment_method: order.payment_method,
            payment_status: order.payment_status,
            total_amount: order.total_amount
          }
        }
      rescue => e
        render json: { success: false, message: "Failed to place order: #{e.message}" }, status: :unprocessable_content
      end
    end
  end
end
