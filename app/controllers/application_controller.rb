class ApplicationController < ActionController::API
    include Pundit::Authorization

    before_action :authorize_request
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    def jwt_decode(token)
        JWT.decode(token,Rails.application.secret_key_base)[0]
    rescue JWT::DecodeError => e
        Rails.logger.error("JWT Decode Error: #{e.message}")
        nil
    end

    def authorize_request
        header = request.headers['Authorization']
        if header
            token = header.split(' ').last
            decoded = jwt_decode(token)
            @current_user = User.find_by(id: decoded['user_id']) if decoded
            Rails.logger.debug "Current User: #{@current_user.inspect}"
        else
            render json: {error: "Unauthorized"}, status: :unauthorized
        end
    end

    def current_user
        @current_user
    end

    private

    def user_not_authorized
        render json: {error: "You are not authorized to perform this action."}, status: :forbidden
    end
end