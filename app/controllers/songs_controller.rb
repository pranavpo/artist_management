class SongsController < ApplicationController
    before_action :set_song, only: [:update, :destroy, :show]
    before_action :set_artist, only:[:index, :create]
    PER_PAGE = 5
    def create
        unless current_user.role == "artist" && current_user.artist&.id == @artist.id
            return render json: {error: 'You can only create song for your own artist profile'}, status: :forbidden
        end

        song = @artist.songs.new(song_params)
        authorize song

        if song.save
            render json: song, status: :created
        else
            render json: {errors: song.errors.full_messages}, status: :unprocessable_entity
        end
    end

    def update
        authorize @song
        if @song.update(song_params)
            render json:@song, status: :ok
        else
            render json: { errors: @song.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        authorize @song
        @song.destroy
        render json: {message: 'Song deleted'}, status: :ok
    end

    def show
        authorize @song
        render json: @song, status: :ok
    end

    def index
        authorize Song, :index?
        page = params[:page].to_i || 1
        songs_query = @artist.songs.order(created_at: :desc)
        paginated_songs = songs_query.page(page).per(PER_PAGE)
        render json: {
        songs: paginated_songs,
        meta: {
            current_page: paginated_songs.current_page,
            total_pages: paginated_songs.total_pages,
            total_count: songs_query.count
        }
        }, status: :ok
    end

    private

    def set_song
        @song = Song.find(params[:id])
    rescue ActiveRecord.RecordNotFound
        render json: {error: "Song not found"}, status: :not_found
    end

    def set_artist
        @artist = Artist.find(params[:artist_id])
    rescue ActiveRecord::RecordNotFound
        render json: {error: 'Artist not found'}, status: :not_found
    end

    def song_params
        params.permit(:title, :album_name, :genre)
    end
end
