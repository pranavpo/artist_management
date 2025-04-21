class SongPolicy
  # # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # # In most cases the behavior will be identical, but if updating existing
  # # code, beware of possible changes to the ancestors:
  # # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # class Scope < ApplicationPolicy::Scope
  #   # NOTE: Be explicit about which records you allow access to!
  #   # def resolve
  #   #   scope.all
  #   # end
  # end
  attr_reader :current_user, :song

  def initialize(current_user, song)
    @current_user = current_user
    @song = song
  end

  def show?
    true
  end

  def index?
    true
  end

  def create?
    current_user.role == 'artist' && current_user.artist.present?
  end

  def update? 
    current_user.role == 'artist' && current_user.artist.present? && current_user.artist.id == song.artist_id
  end

  def destroy?
    update?
  end
end
