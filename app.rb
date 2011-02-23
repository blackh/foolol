require 'rubygems'
require 'sinatra'
require 'erb'
require 'time'
require 'dm-core'
require  'dm-migrations'
require  'dm-aggregates'
require "sinatra/reloader" if development?

### CONFIGURE
require File.join(File.dirname(__FILE__), '../../config/prod') if production?
require File.join(File.dirname(__FILE__), 'config/dev') if development?


### MODELS

class Image
  include DataMapper::Resource
  property :id, Serial
  property :i_hash, String, :unique => true
  property :type, String
  property :statut, Integer
  property :karma, Integer
  property :created_at, Integer
  property :updated_at, Integer
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
            "janvier"
        when "February"
            "fevrier"
        when "March"
            "mars"
        when "April"
            "avril"
        when "May"
            "mai"
        when "June"
            "juin"
        when "July"
            "juillet"
        when "August"
            "aout"
        when "September"
            "septembre"
        when "October"
            "octobre"
        when "November"
            "novembre"
        when "December"
            "decembre"
    end
  end
end


### ROUTES

get '/' do
    redirect("/r")
end
get '/r' do
    w = Image.count(:statut => 1)
    @img = Image.get(1+rand(w))
    if @img then  redirect("/i/#{@img.id}/#{@img.i_hash}")
    else redirect("/r")  end
end

get '/new' do
    @img = Image.last(:statut => 1)
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/i/:id/*/prev' do |id, hash|
    @img = Image.first(:statut => 1, :conditions => [ 'id < ?', id.to_i], :order => [:updated_at.desc])
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/i/:id/*/next' do |id, hash|
    @img = Image.last(:statut => 1, :conditions => [ 'id > ?', id.to_i], :order => [:updated_at.desc])
    redirect("/i/#{@img.id}/#{@img.i_hash}")
end

get '/i/:id/*' do |id, hash|

    response.headers['Accept-Encoding'] = 'gzip, deflate'
    response.headers['Cache-Control'] = 'public'
    @img = Image.get(id)
  #  @img.update(:karma => @img.karma.to_i+1)

    erb :index

end

get '/cron' do
    img = Image.first(:statut => 0)
    img.statut = 1
    img.updated_at = Time.now
    img.save
end

get "/c/foolol" do
mime_type "application/x-chrome-extension"
content_type "application/x-chrome-extension"
send_file('public/foolol1-0.crx')
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
  upl =FileUtils.mv tempfile.path, $cdn+"#{dir}/#{md5}"+ext
  FileUtils.chmod 0755, $cdn+"#{dir}/#{md5}"+ext

  img = Image.new
  img.attributes = { :i_hash => md5, :type => ext, :statut => 0, :karma=>'0', :created_at => Time.now}
  if upl then img.save end

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

