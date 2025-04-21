class AuthController < ApplicationController
  skip_before_action :authorize_request, only: [:login]
  def login
    user = User.find_by(email: login_params[:email])
    # Rails.logger.debug("Login param is " + login_params.to_s)
    if user&.authenticate(login_params[:password])
      token = jwt_encode(user_id:user.id)
      render json: {token:token}, status: :ok
    else
      render json: {error: 'Invalid email or password'}, status: :unauthorized
    end
  end

  private
  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.secret_key_base)
  end

  def login_params
    params.permit(:email,:password)
  end
end
