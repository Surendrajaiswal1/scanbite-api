module Api
  module V1
    class UsersController < BaseController
      def show
        render json: { success: true, data: current_user.as_json(except: [:password_digest]) }
      end

      def update
        if current_user.update(user_params)
          render json: { success: true, data: current_user.as_json(except: [:password_digest]) }
        else
          render json: { success: false, errors: current_user.errors.to_hash, message: current_user.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.require(:user).permit(:full_name, :password, :password_confirmation)
      end
    end
  end
end
