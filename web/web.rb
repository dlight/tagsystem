require 'rubygems'
require 'sequel'
require 'sinatra'

set :environment, :production

set :run, true
set :bind, '127.0.0.1'
set :port, 1025

$db = Sequel.connect('postgres://localhost')

helpers do
  def db
    $db
  end
  def count()
    $db.fetch("select count(*) from set")[''][:count]
  end
end

get '/' do
  redirect '/page/0'
end

get '/all' do
  haml :all
end

get '/page/:n' do |n|
  @n = Integer(n)
  @N = count()
  @gap = 100


  @min = 0
  @max = (@N / @gap)

  if @n > 20 then
    @min = @n - 20
    @hasless = true
  end
  if @max - @n > 20 then
    @max = @n + 20
    @hasmore = true
  end

  haml :page
end

get '/set/:id' do |id|
  @id = id
  haml :set
end

enable :inline_templates

__END__

@@ layout
= yield

@@ page
%a{ :href => "/all" } All

="..." if @hasless
- for i in @min .. @n-1
  %a{ :href => "/page/#{i}" }=i

=@n

- for i in @n+1 .. @max
  %a{ :href => "/page/#{i}" }=i
="..." if @hasmore


- db.fetch("select id, dir from set limit #{@gap} offset #{@n * @gap}") do |r|
  %p
    %a{ :href => "/set/#{r[:id]}" }
      =File.basename r[:dir]

@@ all
%p=count()
- db.fetch("select id, dir from set") do |r|
  %p
    %a{ :href => "/set/#{r[:id]}" }
      =File.basename r[:dir]

@@ set
%a{ :href => '/' } "Up"
%br
- db.fetch("select path from file where image = true and id in (select file_id from set_file where set_id = #{@id} order by pos desc)") do |r|
    %img{ :src => "http://127.0.0.1:4567#{r[:path]}" }
