module Api
  module V1
    class OrdersController < BaseController
      def index
        business_profile = current_user.business_profile
        unless business_profile
          return render json: { success: false, message: "Business profile not found" }, status: :not_found
        end

        orders = business_profile.orders.includes(order_items: :menu_item).order(created_at: :desc)
        
        render json: {
          success: true,
          data: orders.as_json(
            include: {
              order_items: {
                include: {
                  menu_item: { only: [:id, :name] }
                }
              }
            }
          )
        }
      end

      def update
        business_profile = current_user.business_profile
        unless business_profile
          return render json: { success: false, message: "Business profile not found" }, status: :not_found
        end

        order = business_profile.orders.find_by(id: params[:id])
        unless order
          return render json: { success: false, message: "Order not found" }, status: :not_found
        end

        update_params = {}
        update_params[:status] = params[:status] if params[:status].present?
        update_params[:payment_status] = params[:payment_status] if params[:payment_status].present?

        if update_params[:status] == 'completed' && !update_params.key?(:payment_status)
          update_params[:payment_status] = 'Paid'
        end

        was_cancelled = ['cancelled', 'rejected'].include?(order.status)
        will_be_cancelled = ['cancelled', 'rejected'].include?(params[:status])

        if order.update(update_params)
          if !was_cancelled && will_be_cancelled
            order.order_items.each do |item|
              if item.menu_item
                item.menu_item.update!(quantity: item.menu_item.quantity + item.quantity)
              end
            end
          end

          render json: { 
            success: true, 
            data: order.as_json(
              include: {
                order_items: {
                  include: {
                    menu_item: { only: [:id, :name] }
                  }
                }
              }
            )
          }
        else
          render json: { success: false, message: order.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end
    end
  end
end
