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
  set :port, 1025
  $pre_dir = "tagsystem"
end

$profile = false

$db = Sequel.connect('postgres://localhost')

$dim = def_size()

s = sizes()

$size_med = s[0]
$size_low = s[1]
$size_tin = s[2]

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

  if @max > @last
    @max = @last
  end

  @hasless = true if @min > 0
  @hasmore = true if @max < @last

  @b = Time.new.to_f
  haml :page
end

get '/empty' do
  haml :empty
end

get '/bag/:t/:id' do |t, id|
  @t = t
  @id = id
  haml :bag
end

get '/style.css' do
  sass :style
end

helpers do
  def menu(&b)
    haml :menu, {}, { :arg => b }
  end
end

enable :inline_templates

__END__

@@ layout
%html
  %head
    %link{:href=>'/style.css', :rel => 'stylesheet', :type => "text/css"}
    %script{ :src => '/jquery-1.4.2.js' }
    %script{ :src => '/jquery.hotkeys.js' }
    %script{ :src => '/nav.js' }
  %body
    = yield

@@ page_menu
%a#prev{ :href => "/page/#{Integer(@n)-1}" }
%a#next{ :href => "/page/#{Integer(@n)+1}" }
#menu
  %ul
    %li<
      %a#up{ :href => "/" } /
    %li<
      %a{ :href => "/all" } A
    %li<
      %a{ :href => "/empty" } E
  %ul
    -if @n > 0
      %li<
        %a{ :href => "/page/0" } <<
    - if @hasless
      %li<
        %a{ :href => "/page/#{@n - @win}" } <
  %ul
    - for i in @min .. @n-1
      %li<
        %a{ :href => "/page/#{i}" }=i
    %li<
      =@n

    - for i in @n+1 .. @max
      %li<
        %a{ :href => "/page/#{i}" }=i
  %ul
    - if @hasmore
      %li<
        %a{ :href => "/page/#{@n + @win}" } >
    - if @n < @last
      %li<
        %a{ :href => "/page/#{@last}" } >>

  %br{ :clear => 'left' }

@@ page
= haml :page_menu

#bags
  %ul
    - list_nonempty_bags_by_page(@gap, @n) do |r|
      %li<
        %a{ :href => "/bag/#{$dim}/#{r[:bag_id]}" }<
          =r[:dir].sub %r{.*/([^/]+/[^/]+/[^/]+)}, '\1'

- c = Time.new.to_f
- puts "X: #{@x - @a}\nB: #{@b - @a}\nC: #{c - @a}" if $profile

@@ bag_menu
#menu
  %ul
    %li
      %a#up{ :href => '/' } ^
  %ul
    %li
      %a#prev{ :href => "/bag/#{@t}/#{Integer(@id)-1}" } <

  %ul
    %li
      %a#hi{ :href => "/bag/hi-res/#{@id}" } hi
    %li
      %a#mid{ :href => "/bag/#{$size_med}/#{@id}" } mid
    %li
      %a#low{ :href => "/bag/#{$size_low}/#{@id}" } low
    %li
      %a#tin{ :href => "/bag/#{$size_tin}/#{@id}" } tin
  %ul
    %li
      %a#next{ :href => "/bag/#{@t}/#{Integer(@id)+1}" } >
  %br{ :clear => 'left' }

@@ bag
= haml :bag_menu
- list_files_with_type(@t, @id) do |r|
  %img{ :src => (link_file r[:repo_path]) }

@@ all
%a{ :href => '/' } Up
%p="Total: #{count()}"
%p="Nao vazio: #{count_bags_nonempty()}"
%p="Vazio: #{count_bags_empty()}"
- $db.fetch("select bag_id, dir from bag") do |r|
  %p
    %a{ :href => "/bag/#{$dim}/#{r[:bag_id]}" }
      =File.basename r[:dir]

@@ empty
%a{ :href => '/' } Up
- list_empty_bags do |r|
  %p
    %a{ :href => "/bag/#{$dim}/#{r[:bag_id]}" }
      =File.basename r[:dir]

@@ style
body
  font-family: DejaVu Sans
#menu
  width: 100%
  margin: 1em 0
  padding: 0px 0.5em
  background: #eee none

  padding: 0
  background: #fff none

  font-size: 105%
  ul
    float: left
    margin: 0
    padding: 0
    list-style-type: none
    margin-right: 0.15em

  li

    margin: 0
    padding: 0
    float: left

    width: 2.3em
    margin-right: 0.1em
    background: #eee none
    text-align: center

  a
    display: block
    width: 100%
    text-decoration: none
  a:hover
    background: #ff9 none

#bags
  font-size: 105%
  line-height: 1.2em
  ul
    list-style-type: none
  a
    color: #819F00
    text-decoration: none
  a:hover
    color: #710067
