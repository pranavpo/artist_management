class UsersController < ApplicationController
  before_action :set_user, only: [:update, :destroy]

  def create
    user = User.new(user_params)
    authorize user
    if user.role == 'artist' && !artist_params_present?
      return render json: { error: 'First released year and number of albums released are required' }, status: :unprocessable_entity
    end
    if user.save
      if user.role == 'artist'
        artist = Artist.new(
          user_id: user.id,
          first_released_year: params[:first_released_year],
          number_of_albums_released: params[:number_of_albums_released]
        )
        unless artist.save
          user.destroy # rollback
          return render json: { artist_errors: artist.errors.full_messages }, status: :unprocessable_entity
        end
      end
      render json: {
        user: user.as_json(except: [:password_digest, :created_at, :updated_at]),
        artist: artist
      }, status: :created
    else
      render json: user.errors, status: :unprocessable_entity
    end
  end
  

  def update
    authorize @user
  
    previous_role = @user.role
    if @user.update(user_params)
      if @user.role == 'artist'
        unless artist_params_present?
          return render json: { error: 'First released year and number of albums released are required' }, status: :unprocessable_entity
        end
  
        artist = @user.artist || Artist.new(user_id: @user.id)
        if artist.update(
          first_released_year: params[:first_released_year],
          number_of_albums_released: params[:number_of_albums_released]
        )
          render json: {
            user: @user.as_json(except: [:password_digest, :created_at, :updated_at]),
            artist: artist
          }, status: :ok
        else
          render json: { error: artist.errors.full_messages }, status: :unprocessable_entity
        end
      else
        # DO NOT delete artist, just leave it so songs stay intact
        render json: {
          user: @user.as_json(except: [:password_digest, :created_at, :updated_at]),
          notice: previous_role == 'artist' ? 'Artist profile preserved in case of future role change' : nil
        }, status: :ok
      end
    else
      render json: { error: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  

  def destroy
    authorize @user # calls UserPolicy#destroy?
    @user.destroy
    render json: { message: 'User deleted' }, status: :ok
  end

  def get_all_users
    authorize User, :get_all_users?
    users = User.all.as_json(except: [:password_digest, :created_at, :updated_at])
    render json: users, status: :ok
  end
  
  def get_all_artists
    authorize User, :get_all_artists?
    artists = Artist.includes(:user).joins(:user).where(users: {role: 'artist'}).order('users.created_at ASC')
    formatted_artists = artists.map do |artist|
      {
        id: artist.id,
        first_released_year: artist.first_released_year,
        number_of_albums_released: artist.number_of_albums_released,
        user: artist.user.as_json(except: [:password_digest, :created_at, :updated_at])
      }
    end
    render json: formatted_artists, status: :ok
  end

  def get_all_artist_managers
    authorize User, :get_all_artist_managers?
    artist_managers = User.where(role: 'artist_manager').order(created_at: :asc).as_json(except: [:password_digest, :created_at, :updated_at])
    render json: artist_managers, status: :ok
  end

  def show
    user = User.find_by(id: params[:id])
    if user
      if user.role == 'artist'
        artist = user.artist
        Rails.logger.debug("ARTIST LOADED: #{artist.to_json.length} bytes")
        render json: {
          user: user.attributes.except("password_digest", "created_at", "updated_at"),
          artist: artist.attributes.except("created_at", "updated_at")
        }, status: :ok
      else
        render json: { user: user }, status: :ok
      end
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_params
    permitted = params.permit(:first_name, :last_name, :email, :password, :phone, :dob, :gender, :address)
    permitted[:role] = params[:role] if current_user.role == 'super_admin'
    permitted
  end

  def artist_params_present?
    params[:first_released_year].present? && params[:number_of_albums_released].present?
  end

  def jwt_encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secret_key_base)
  end
end