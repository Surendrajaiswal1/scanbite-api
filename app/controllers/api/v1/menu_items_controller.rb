require 'csv'

class Api::V1::MenuItemsController < Api::V1::BaseController
  before_action :set_business_profile

  def index
    @menu_items = @business_profile.menu_items.order(created_at: :desc)
    
    render json: {
      success: true,
      data: @menu_items.as_json(methods: :image_url)
    }
  end

  def create
    @menu_item = @business_profile.menu_items.build(menu_item_params)

    if @menu_item.save
      render json: {
        success: true,
        message: "Menu item created successfully",
        data: @menu_item.as_json(methods: :image_url)
      }, status: :created
    else
      render json: {
        success: false,
        errors: @menu_item.errors.to_hash
      }, status: :unprocessable_content
    end
  end

  def update
    @menu_item = @business_profile.menu_items.find(params[:id])

    if @menu_item.update(menu_item_params)
      render json: {
        success: true,
        message: "Menu item updated successfully",
        data: @menu_item.as_json(methods: :image_url)
      }
    else
      render json: {
        success: false,
        errors: @menu_item.errors.to_hash
      }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Menu item not found" }, status: :not_found
  end

  def destroy
    @menu_item = @business_profile.menu_items.find(params[:id])
    @menu_item.destroy
    render json: { success: true, message: "Menu item deleted successfully" }
  rescue ActiveRecord::RecordNotFound
    render json: { success: false, message: "Menu item not found" }, status: :not_found
  end

  def import_csv
    unless params[:file].present?
      return render json: { success: false, message: "No CSV file provided" }, status: :unprocessable_content
    end

    success_count = 0
    errors = []

    begin
      CSV.foreach(params[:file].path, headers: true) do |row|
        item_params = {
          name: row['Product_Name'],
          category: row['Product_Category'],
          description: row['Product_Description'],
          quantity: row['Product_Quantity'].to_i,
          price: row['Product_Price'].to_f,
          discount: row['Discount'].to_f,
          currency: row['Currency']
        }
        
        item = @business_profile.menu_items.build(item_params)
        if item.save
          success_count += 1
        else
          errors << { name: row['Product_Name'], errors: item.errors.full_messages }
        end
      end

      render json: {
        success: true,
        message: "Successfully imported #{success_count} items",
        errors: errors
      }
    rescue => e
      render json: {
        success: false,
        message: "Error parsing CSV: #{e.message}"
      }, status: :unprocessable_content
    end
  end

  private

  def set_business_profile
    @business_profile = current_user.business_profile
    unless @business_profile
      render json: { success: false, message: "Business profile not found" }, status: :not_found
    end
  end

  def menu_item_params
    params.permit(
      :name,
      :category,
      :description,
      :quantity,
      :price,
      :discount,
      :image,
      :currency
    )
  end
end
