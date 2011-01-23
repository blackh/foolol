require 'rubygems'
require 'sinatra'
require 'erb'
require 'time'
require 'dm-core'
require  'dm-migrations'
require "sinatra/reloader" if development?

### CONFIGURE
require File.join(File.dirname(__FILE__), '../../config/prod') if production?
require File.join(File.dirname(__FILE__), 'config/dev') if development?


### MODELS

class Image
  include DataMapper::Resource
  property :id, Serial
  property :i_hash, String
  property :type, String
  property :statut, Integer
  property :karma, Integer
  property :created_at, Integer
end

DataMapper.auto_upgrade!

### HELPERS

helpers do
  def lol(img)
    "<img src='#{$cdnurl}/#{Time.at(img.created_at).strftime("%Y")}/#{Time.at(@img.created_at).strftime("%m")}/#{img.i_hash}#{img.type}' alt='#{img.i_hash}.#{img.type}' />"
  end

  def img(img, folder='images')
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
    "#{$cdnurl}/#{Time.at(img.created_at).strftime("%Y")}/#{Time.at(img.created_at).strftime("%m")}/#{img.i_hash}#{img.type}"
    end
  end

  def mois(t)
    case t.strftime("%B")
        when "January"
            "Janvier"
        when "February"
            "Février"
        when "March"
            "Mars"
        when "April"
            "Avril"
        when "May"
            "Mai"
        when "June"
            "Juin"
        when "July"
            "Juillet"
        when "August"
            "Août"
        when "September"
            "Septembre"
        when "October"
            "Octobre"
        when "November"
            "Novembre"
        when "December"
            "Décembre"
    end
  end
end


### ROUTES

get '/r?' do
    w = Image.count(:conditions => ["statut = 1"])
    puts w
    @img = Image.get(1+rand(w))
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
  #  @img.update(:karma => @img.karma.to_i+1)

    erb :index

end


### UPLOAD

post '/upload'+@salt do

  file = params[:file]
  filename = file[:filename]
  tempfile = file[:tempfile]
  md5 = Digest::MD5.hexdigest(tempfile.read)
  ext = File.extname(filename)

  dir = Time.now.strftime("%Y")+"/"+Time.now.strftime("%m")
  FileUtils.mkdir_p $cdn+dir
  FileUtils.mv tempfile.path, $cdn+"#{dir}/#{md5}"+ext
  FileUtils.chmod 0755, $cdn+"#{dir}/#{md5}"+ext

  img = Image.new
  img.attributes = { :i_hash => md5, :type => ext, :statut => 0, :karma=>'0', :created_at => Time.now}
  img.save

  puts "ok!"
end


## XML

get '/rss.xml' do
@img = Image.all(:limit => 10,  :order => [ :created_at.desc ])

  builder do |xml|
    xml.instruct! :xml, :version => '1.0'
    xml.rss :version => "2.0" do
      xml.channel do
        xml.title "FooLOL.fr"
        xml.description "Retrouvez sur FooLOL.fr, toutes les heures de nouvelles images, videos et jeux droles ou insolites"
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

