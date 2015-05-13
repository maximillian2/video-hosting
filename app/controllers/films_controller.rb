
class FilmsController < ApplicationController

  before_filter :find_item, only: [:show, :edit, :update, :destroy]

  def index
    @films = Film.where(nil)
    @films = @films.where('genres LIKE ?', "%#{params[:genre]}%") if params[:genre]
    @films = @films.category(params[:category]) if params[:category]
  end

  def show
    unless @film
      render text: 'Page not Found', status: 404
    end
  end

  def new
    require 'net/http'
    require 'open-uri'

    @film = Film.new

    if params[:add_field]
      add_field = params[:add_field]
      request =  Net::HTTP.get(URI.parse(URI.encode("http://fs.to/search.aspx?f=quick_search&search=#{add_field}&section=video")))
      @add_result = ActiveSupport::JSON.decode(request)
      @add_result.map do |i|
        p i
        # TODO skip if not in section video
        # doc = Nokogiri::HTML(open("#{ 'http://www.fs.to' + i['link'] }"))
        # itemprop_image = doc.xpath("//img[@itemprop='image']")
        # unless itemprop_image.nil?
        #   i['poster'] = itemprop_image.attr('src').value
        # end
      end
    else
      render 'new'
    end
  end

  def create
    @film = Film.new

    p params[:post]
    @film.image = params['poster']
    @film.title = params['title']
    @film.link = params['link']
    @film.genres = params['genres']
    @film.category = params['category']
    @film.year = params['year']
    @film.country = params['country']
    # TODO make original title and ratings
    # doc = Nokogiri::HTML(open("#{ @film.link }"))

    # FIXME
    # что делать с аниме?
    # и с фильмами, которых нету на имдб
    # original_title = doc.xpath("//div[@itemprop='alternativeHeadline']").text
    # @film.original_title = original_title.empty? ? '–' : original_title

    # @film.image = doc.xpath("//img[@itemprop='image']").attr('src').value
    # @film.country = result[0]['country'][0]

    # TODO add rating search for rus tv shows
    # TODO  fix this code pls :/
    # if @film.original_title == '–'
    #   @film.rating = 0
    # else
    #   imdb = FilmBuff::IMDb.new
    #   rating_value = imdb.find_by_title(@film.original_title)
    #   @film.rating = rating_value.nil? ? 0 : rating_value.rating
    # end

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
    if params[:search_field]
      # TODO make search input text capitalized
      p params[:search_field]
      search_result = params[:search_field].titleize
      p search_result
      @search_result = Film.where('title LIKE ?', "%#{search_result}%")
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
