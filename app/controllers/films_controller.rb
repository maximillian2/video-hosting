class FilmsController < ApplicationController

  before_action :authenticate_user!
  before_filter :find_item, only: [:show, :edit, :update, :destroy]

  before_action :update_tags, only: [:index, :new, :search]
  after_action :update_tags, only: [:update]

  def index
    @user = current_user
    ## FIXME replace with scope user_films
    @films = Film.joins(:users).where(users: { id: current_user.id })
    @films = @films.genres(current_user.id, params[:genre]) if params[:genre]
    @films = @films.category(current_user.id, params[:category]) if params[:category]
    @films = @films.tags(current_user.id, params[:tag]) if params[:tag]
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
      @add_result.map do |i|
        doc = Nokogiri::HTML(open("#{ 'http://fs.to' + i['link'] }"))
        itemprop_image = doc.xpath("//img[@itemprop='image']")
        itemprop_description = doc.xpath("/html/body/div[1]/div/div[2]/div/div[1]/div[2]/div[1]/div[1]/div/div[4]/span/p")

        # Get description
        i['description'] = itemprop_description.children.text

        # Get the link of original image poster through XPath
        if itemprop_image.empty?
          i['poster'] = '/assets/help.png'
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
      f.description = params['description']
    end

    doc = Nokogiri::HTML(open("#{ @film.link }"))

    original_title = if @film.category == 'Телепередачи'
                       doc.xpath('/html/body/div[1]/div/div[2]/div/div[1]/div[2]/div[1]/div[1]/div[2]/div[1]/div/div').children.text
                     else
                       doc.xpath("//div[@itemprop='alternativeHeadline']").text
                     end

    @film.original_title = original_title

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
    @film.tags = params[:tags]
    @film.save

    redirect_to  root_path
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

  def update_tags
    @uniq_tags = []
    arr = []
    Film.user_films(current_user.id).to_a.each {|i| arr << i.tags unless i.tags.nil? }

    @uniq_tags = arr.join(', ').split(', ').uniq.reject!(&:empty?)
  end

end
