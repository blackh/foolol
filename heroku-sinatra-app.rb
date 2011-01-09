require 'rubygems'
require 'sinatra'
require 'erb'
require 'time'
require 'dm-core'
require  'dm-migrations'
require "sinatra/reloader" if development?


### CONFIGURE

configure :development do
    $url = "http://192.168.1.5:4567"
    $iurl = "http://192.168.1.5:4567"

    DataMapper.setup(:default, {
        :adapter  => 'mysql',
        :host     => 'localhost',
        :username => 'root',
        :password => 'haribo',
        :database => 'foolol'})
end

configure :production do
    disable :raise_errors, :sessions, :show_exceptions

    $url = "http://foolol.heroku.com"
    $iurl = "http://foolol.heroku.com"
    DataMapper.setup(:default, ENV['DATABASE_URL'])

    error do
       erb :error, :layout => false
    end
end

### MODELS

class Image
  include DataMapper::Resource
  property :id, Serial
  property :i_hash, String
  property :type, String
  property :statut, String
  property :karma, Integer
  property :created_at, Integer
end

DataMapper.auto_upgrade!

### HELPERS

helpers do
  def lol(img, folder='cdn')
    "<img src='#{$iurl}/#{folder}/#{Time.at(img.created_at).strftime("%Y")}/#{Time.at(@img.created_at).strftime("%m")}/#{img.i_hash}.#{img.type}' alt='#{img.i_hash}.#{img.type}' />"
  end

  def img(img, folder)
    "<img src='#{$iurl}/#{folder}/#{img}' />"
  end

  def js(name)
    "<script src='#{$iurl}/js/#{name}' type='text/javascript'></script>"
  end

  def css(name, media='')
    "<link rel='stylesheet' href='#{$iurl}/css/#{name}.css' type='text/css' media='#{media}'>"
  end

  def iurl(img, perm='', folder='cdn')
    if perm == 1 then
    "#{$iurl}/i/#{img.id}/r"
    else
    "#{$iurl}/#{folder}/#{Time.at(img.created_at).strftime("%Y")}/#{Time.at(img.created_at).strftime("%m")}/#{img.i_hash}.#{img.type}"
    end
  end
end


### ROUTES

get '/r?' do
    @img = Image.get(1+rand(Image.count))
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/new' do
    @img = Image.last
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/star' do
    @img = Image.first(:order => [:karma.desc])
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/i/:id/*/prev' do |id, hash|
    @img = Image.last(:conditions => [ 'id < ?', id.to_i])#, :order => [:created_at.desc])
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/i/:id/*/next' do |id, hash|
    @img = Image.last(:conditions => [ 'id > ?', id.to_i])#, :order => [:created_at.desc])
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/i/:id/*' do |id, hash|

    response.headers['Accept-Encoding'] = 'gzip, deflate'
    response.headers['Cache-Control'] = 'public'
    @img = Image.get(id)
    @img.update(:karma => @img.karma.to_i+1)

    erb :index

end

get '/about' do
    erb :about
end

get '/add' do
    img = Image.new
    img.attributes = { :i_hash => '2deb75c8755db04326c9bafd99b5556d', :type => 'jpg', :statut => '0', :karma=>'0', :created_at => Time.now}
    img.save
end
## XML

get '/rss.xml' do
@img = Image.all(:limit => 10,  :order => [ :created_at.desc ])

  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => "2.0" do
      xml.channel do
        xml.title "FooLOL.fr"
        xml.description "Retrouvez sur FooLOL.fr, toutes les heures de nouvelles images, vidéos et jeux droles ou insolites"
        xml.link "http://foolol.fr/"

        @img.each do |img|
          xml.item do
            xml.title img.i_hash.to_s+"."+img.type
            xml.link iurl(img,1)
            xml.pubDate img.created_at
            xml.guid iurl(img,1)
          end
        end
      end
    end
  end
end

