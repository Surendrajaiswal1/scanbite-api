# app/controllers/api/v1/base_controller.rb

class Api::V1::BaseController < ApplicationController
  private

  def render_success(data = {}, status = :ok)
    render json: {
      success: true,
      data:
    }, status:
  end

  def render_error(message, status = :unprocessable_entity)
    render json: {
      success: false,
      error: message
    }, status:
  end
end