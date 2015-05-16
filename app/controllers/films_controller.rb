class FilmsController < ApplicationController

  before_filter :find_item, only: [:show, :edit, :update, :destroy]

  def index
    @films = Film.where(nil)
    @films = @films.where('genres LIKE ?', "%#{params[:genre]}%") if params[:genre]
    @films = @films.category(params[:category]) if params[:category]
    # @films = @films.includes(:film)
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
      # Strip whitespaces for '+' to build correct GET request
      add_field = params[:add_field].tr(' ', '+')
      url = "http://fs.to/search.aspx?f=quick_search&search=#{add_field}&section=video"
      request = Net::HTTP.get(URI.parse(URI.encode(url)))
      # Parse JSON response and delete records that don't belong to 'video' section
      @add_result = ActiveSupport::JSON.decode(request).delete_if { |hash| hash['section'] != 'video' }
      @add_result.map do |i|
        doc = Nokogiri::HTML(open("#{ 'http://www.fs.to' + i['link'] }"))
        itemprop_image = doc.xpath("//img[@itemprop='image']")
        # Get the link of original image poster through XPath
        i['poster'] = itemprop_image.attr('src').value unless itemprop_image.nil?
      end
    else
      render 'new'
    end
  end

  def create
    @film = Film.new

    @film.image = params['poster']
    @film.title = params['title']
    @film.link = params['link']
    @film.genres = params['genres']
    @film.category = params['category']
    @film.year = params['year']
    @film.country = params['country']

    p @film

    doc = Nokogiri::HTML(open("#{ @film.link }"))

    original_title = doc.xpath("//div[@itemprop='alternativeHeadline']").text
    if original_title.empty?
      @film.original_title = '–'
      @film.rating = 0
    else
      @film.original_title = original_title
      ## TODO вопрос аниме открыт
      # imdb = FilmBuff::IMDb.new
      # rating_value = imdb.find_by_title(@film.original_title)
      # @film.rating = rating_value.rating
      # @film.rating = rating_value.nil? ? 0 : rating_value.rating
    end

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
      search_result = params[:search_field]
      p search_result.capitalize
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
