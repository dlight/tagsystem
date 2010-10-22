require 'rubygems'
require 'sequel'
require 'sinatra'
require 'sass'

set :environment, :production

set :run, true
set :bind, '127.0.0.1'
set :port, 1025

$db = Sequel.connect('postgres://localhost')

helpers do
  def count()
    $db.fetch("select count(*) from set").first[:count]
  end

  def get_file_by_set_id(id, &blk)
    $db.fetch("select file.path from file, set_file
                where file.id = set_file.file_id
                  and file.image = true
                  and set_file.set_id = ?
                order by set_file.pos", id) { |r| blk.call(r) }
  end

  def list_sets_by_page(gap, n, &blk)
    $db.fetch("select id, dir from set limit ? offset ?", gap, n * gap) { |r| blk.call(r) }
  end
end

get '/' do
  redirect '/page/0'
end

get '/all' do
  haml :all
end

get '/page/:n' do |n|
  @gap = 100
  @half = 10

  @n = Integer(n)
  @N = count()

  @last = @N / @gap
  @win = 2*@half + 1

  if @n < @win then
    @min = 0
    @max = @win
  elsif @last - @n < @win then
    @min = @last - @win
    @max = @last
  else
    @min = @n - @half
    @max = @n + @half
  end

  @hasless = true if @min > 0
  @hasmore = true if @max < @last

  haml :page
end

get '/set/:id' do |id|
  @id = id
  haml :set
end

get '/style.css' do
  sass :style
end

enable :inline_templates

__END__

@@ layout
%html
  %head
    %link{:href=>'/style.css', :rel => 'stylesheet', :type => "text/css"}
  %body
    = yield

@@ page
#menu
  %a{ :href => "/all" } All
  |
  -if @n > 0
    %a{ :href => "/page/0" } <<
  - if @hasless
    %a{ :href => "/page/#{@n - @win}" } <

  - for i in @min .. @n-1
    %a{ :href => "/page/#{i}" }=i

  =@n

  - for i in @n+1 .. @max
    %a{ :href => "/page/#{i}" }=i

  - if @hasmore
    %a{ :href => "/page/#{@n + @win}" } >
  - if @n < @last
    %a{ :href => "/page/#{@last}" } >>

- list_sets_by_page(@gap, @n) do |r|
  %p
    %a{ :href => "/set/#{r[:id]}" }
      =r[:dir].sub %r{.*/([^/]+/[^/]+/[^/]+)}, '\1'

@@ set
%a{ :href => '/' } "Up"
%br
- get_file_by_set_id(@id) do |r|
    %img{ :src => "http://127.0.0.1:4567#{r[:path]}" }

@@ all
%p=count()
- $db.fetch("select id, dir from set") do |r|
  %p
    %a{ :href => "/set/#{r[:id]}" }
      =File.basename r[:dir]

@@ style
#menu
  font-family: Andale Mono, monospace
  font-size: 130%
