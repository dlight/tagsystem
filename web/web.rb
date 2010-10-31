require 'rubygems'
require 'sequel'
require 'sinatra'
require 'haml'
require 'sass'

require_relative 'db'

set :environment, :production

set :run, true
set :bind, '127.0.0.1'
set :port, 1025

$db = Sequel.connect('postgres://localhost')

get '/' do
  redirect '/page/0'
end

get '/all' do
  haml :all
end

get '/page/:n' do |n|
  @a = Time.new.to_f

  @gap = 100
  @half = 10

  @n = Integer(n)

  @N = count_sets_nonempty()

  @x = Time.new.to_f

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

  @b = Time.new.to_f
  haml :page
end

get '/empty' do
  haml :empty
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
  %a{ :href => "/empty" } Empty
  |

  -if @n > 0
    %a{ :href => "/page/0" } <<
  - if @hasless
    %a{ :href => "/page/#{@n - @win}" } <

  - for i in @min .. @n-1
    %a{ :href => "/page/#{i}" }=i

  - c = Time.new.to_f
  =@n

  - for i in @n+1 .. @max
    %a{ :href => "/page/#{i}" }=i

  - if @hasmore
    %a{ :href => "/page/#{@n + @win}" } >
  - if @n < @last
    %a{ :href => "/page/#{@last}" } >>

  - d = Time.new.to_f
- list_nonempty_sets_by_page(@gap, @n) do |r|
  %p
    %a{ :href => "/set/#{r[:id]}" }
      =r[:dir].sub %r{.*/([^/]+/[^/]+/[^/]+)}, '\1'

- e = Time.new.to_f
- puts "X: #{@x - @a}\nB: #{@b - @a}\nC: #{c - @a}\nD: #{d - @a}\nE: #{e - @a}"


@@ set
%a{ :href => '/' } "Up"
%br
- list_files_of_set(@id) do |r|
    %img{ :src => "http://127.0.0.1:4567/ts#{r[:path]}" }

@@ all
%p=count()
%p=count_sets_nonempty()
%p=count_sets_empty()
- $db.fetch("select id, dir from set") do |r|
  %p
    %a{ :href => "/set/#{r[:id]}" }
      =File.basename r[:dir]

@@ empty
- list_empty_sets do |r|
  %p
    %a{ :href => "/set/#{r[:id]}" }
      =File.basename r[:dir]

@@ style
#menu
  font-family: Andale Mono, monospace
  font-size: 130%
