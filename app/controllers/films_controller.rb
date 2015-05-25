class FilmsController < ApplicationController

  before_action :authenticate_user!
  before_filter :find_item, only: [:show, :edit, :update, :destroy]

  def index
    @user = current_user
    @films = Film.joins(:users).where(users: { id: current_user.id })
    @films = @films.genres(current_user.id, params[:genre]) if params[:genre]
    @films = @films.category(current_user.id, params[:category]) if params[:category]
  end

  def show
    unless @film
      render text: 'Page not Found', status: 404
    end
  end

  def new
    @film = Film.new

    if params[:add_field] && !params[:add_field].empty?
      # Strip whitespaces for '+' to build correct GET request
      add_field = params[:add_field].tr(' ', '+')
      url = "http://#{Rails.env.production? ? 'brb' : 'fs'}.to/search.aspx?f=quick_search&search=#{add_field}&section=video"
      encoded_url = URI.encode(url)
      client = HTTPClient.new
      request = client.get(encoded_url)
      # Parse JSON response and delete records that don't belong to 'video' section
      @add_result = ActiveSupport::JSON.decode(request.body).delete_if { |hash| hash['section'] != 'video' }
      # if subsection is tv shows, use
      @add_result.map do |i|
        puts 'im in map method'
        doc = Nokogiri::HTML(open("#{ 'http://fs.to' + i['link'] }"))
        itemprop_image = doc.xpath("//img[@itemprop='image']")
        # Get the link of original image poster through XPath
        if itemprop_image.empty?
          #  temp image
          i['poster'] = 'https://dl-web.dropbox.com/get/help.png?_subject_uid=39946975&w=AAB622yAPa4tOG-fG4xt4PTrrhycOlmfoDryDahmzot1aw'
        else
          i['poster'] = itemprop_image.attr('src').value
        end
      end
    elsif params[:add_field] && params[:add_field].empty?
      @add_result = ''
    else
      render 'new'
    end
  end

  def create
    @user = current_user

    @film = Film.new.tap do |f|
      f.image = params['poster']
      f.title = params['title']
      f.link = params['link']
      f.genres = params['genres']
      f.category = params['category']
      f.year = params['year']
      f.country = params['country']
    end

    doc = Nokogiri::HTML(open("#{ @film.link }"))

    original_title = doc.xpath("//div[@itemprop='alternativeHeadline']").text
    if original_title.empty?
      @film.original_title = '–'
      # @film.rating = 0
    else
      @film.original_title = original_title
      ## TODO вопрос аниме открыт
      # imdb = FilmBuff::IMDb.new
      # rating_value = imdb.find_by_title(@film.original_title)
      # @film.rating = rating_value.rating
      # @film.rating = rating_value.nil? ? 0 : rating_value.rating
    end

    if @film.save
      @user.films << @film
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
    if params[:search_field] && !params[:search_field].empty?
      search_result = params[:search_field]
      user = current_user.id # => squeel workimg properly after this
      @search_result = Film.joins(:users).where { (users.id == user) & (title.matches "%#{search_result}%") }
    elsif params[:search_field] && params[:search_field].empty?
      @search_result = ''
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
