
class FilmsController < ApplicationController

  before_filter :find_item, only: [:show, :edit, :update, :destroy]

  def index
    # @films = Film.all
    @films = Film.where(nil)
    @films = @films.genres(params[:category]) if params[:category].present?
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
    require 'net/http'
    require 'open-uri'
    @film = Film.new

    add_field = params[:add_field]
    request =  Net::HTTP.get(URI.parse(URI.encode("http://fs.to/search.aspx?f=quick_search&search=#{add_field}&section=video")))
    result = ActiveSupport::JSON.decode(request)

    @film.title = result[0]['title']
    @film.genres = result[0]['genres'].join(', ')
    @film.category = result[0]['subsection']
    @film.year = result[0]['year'][0]
    @film.link = 'http://fs.to' + result[0]['link']
    doc = Nokogiri::HTML(open("#{ @film.link }"))

    # FIXME
    # что делать с аниме?
    # и с фильмами, которых нету на имдб
    original_title = doc.xpath("//div[@itemprop='alternativeHeadline']").text
    @film.original_title = original_title
    @film.image = doc.xpath("//img[@itemprop='image']").attr('src').value
    @film.country = result[0]['country'][0]

    imdb = FilmBuff::IMDb.new
    @film.rating = imdb.find_by_title(@film.original_title).rating

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
      @search_result = Film.where(title: params[:search_field])
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
      params.require(:film).permit(:title, :year, :genres, :rating)
    end

    def find_item
      @film = Film.find(params[:id])
    end

end
