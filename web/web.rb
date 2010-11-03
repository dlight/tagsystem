require 'rubygems'
require 'sequel'
require 'sinatra'
require 'haml'
require 'sass'

require_relative 'db'

if "dev" == `whoami`.chomp("\n")
  set :environment, :development
else
  set :environment, :production
end

set :run, true
set :bind, '127.0.0.1'

configure :development do
  set :port, 1026
  $pre_dir = "dev"
end

configure :production do
  set :port, 1026
  $pre_dir = "prod"
end

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
  @N = count_bags_nonempty()

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

get '/bag/:id' do |id|
  @id = id
  haml :bag
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

- list_nonempty_bags_by_page(@gap, @n) do |r|
  %p
    %a{ :href => "/bag/#{r[:bag_id]}" }
      =r[:dir].sub %r{.*/([^/]+/[^/]+/[^/]+)}, '\1'

- d = Time.new.to_f
- puts "X: #{@x - @a}\nB: #{@b - @a}\nC: #{c - @a}\nD: #{d - @a}"

@@ bag
%a{ :href => '/' } "Up"
%br
- list_files_of_bag(@id) do |r|
                %img{ :src => (link_file r[:repo_path]) }

@@ all
%p=count()
%p=count_bags_nonempty()
%p=count_bags_empty()
- $db.fetch("select bag_id, dir from bag") do |r|
  %p
    %a{ :href => "/bag/#{r[:bag_id]}" }
      =File.basename r[:dir]

@@ empty
- list_empty_bags do |r|
  %p
    %a{ :href => "/bag/#{r[:bag_id]}" }
      =File.basename r[:dir]

@@ style
#menu
  font-family: Andale Mono, monospace
  font-size: 130%
