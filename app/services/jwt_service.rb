class JwtService
  SECRET_KEY = ENV.fetch("JWT_SECRET_KEY") { Rails.application.secret_key_base || Rails.application.credentials.secret_key_base }
  
  class << self
    def encode(payload, expiration = 24.hours)
      payload_with_exp = payload.merge(exp: (Time.current + expiration).to_i)
      JWT.encode(payload_with_exp, SECRET_KEY, "HS256")
    end
    
    def decode(token)
      begin
        decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" })
        decoded.first
      rescue JWT::DecodeError, JWT::ExpiredSignature => e
        raise AuthenticationError, e.message
      end
    end
    
    def generate_tokens(user)
      access_token = encode({ user_id: user.id, type: "access" }, 24.hours)
      refresh_token = encode({ user_id: user.id, type: "refresh" }, 7.days)
      
      {
        access_token: access_token,
        refresh_token: refresh_token,
        expires_in: 24 * 60 * 60 # 24 hours in seconds
      }
    end
    
    def verify_access_token(token)
      payload = decode(token)
      raise AuthenticationError, "Invalid token type" if payload["type"] != "access"
      payload
    end
  end
end

class AuthenticationError < StandardError; end
