class ApplicationController < ActionController::API
  before_action :authenticate_user!
  
  attr_reader :current_user
  
  def authenticate_user!
    token = extract_token
    return render_unauthorized("Missing token") unless token
    
    begin
      payload = JwtService.verify_access_token(token)
      @current_user = User.find(payload["user_id"])
      return render_unauthorized("User not found") unless @current_user
    rescue AuthenticationError => e
      render_unauthorized(e.message)
    end
  end
  
  private
  
  def extract_token
    auth_header = request.headers["Authorization"]
    return nil unless auth_header
    
    auth_header.split(" ").last
  end
  
  def render_unauthorized(message)
    render json: {
      success: false,
      message: "Unauthorized",
      error: message
    }, status: :unauthorized
  end
end
