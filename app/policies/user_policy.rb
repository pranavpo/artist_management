# app/policies/user_policy.rb
class UserPolicy
  attr_reader :current_user, :user

  def initialize(current_user, user)
    @current_user = current_user
    @user = user
  end

  def create?
    return false unless current_user
  
    case current_user.role
    when "super_admin"
      %w[super_admin artist_manager artist].include?(user.role)
    when "artist_manager"
      user.role == "artist"
    else
      false
    end
  end

  def update?
    return true if current_user.id == user.id

    case current_user.role
    when "super_admin"
      %w[artist_manager artist].include?(user.role)
    when "artist_manager"
      user.role == "artist"
    else
      false
    end
  end

  def destroy?
    update? # same logic
  end

  def get_all_users?
    current_user&.role == "super_admin"
  end

  def get_all_artists?
    %w[super_admin artist_manager].include?(current_user&.role)
  end

  def get_all_artist_managers?
    %w[super_admin].include?(current_user&.role)
  end
end
