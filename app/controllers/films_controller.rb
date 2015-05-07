class FilmsController < ApplicationController

  before_filter :find_item, only: [:show, :edit, :update, :destroy]

  def index
    # @films = Film.all
    @films = Film.where(nil)
    @films = @films.genre(params[:category]) if params[:category].present?
  end

  def show
    unless @film
      render text: 'Page not Found', status: 404
    end
  end

  def new
    @film = Film.new
  end

  def create
    @film = Film.new(allowed_params)

    if @film.save
      redirect_to films_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @film.update_attributes(allowed_params)
      redirect_to films_path
    else
      render 'edit'
    end
  end

  def search
    if params[:search_field].present?
      @search_result = Film.where(name: params[:search_field])
    else
      render 'search'
    end
  end

  def destroy
    @film.destroy
    redirect_to films_path
  end

  private
    def allowed_params
      params.require(:film).permit(:name, :year, :genre, :rating)
    end

    def find_item
      @film = Film.find(params[:id])
    end

end
