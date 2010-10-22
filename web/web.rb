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
  def list_sets_by_page(gap, n, &blk)
    $db.fetch("select id, dir from set limit ? offset ?", gap, n * gap) { |r| blk.call(r) }
  end
  def list_files_of_set(id, &blk)
    $db.fetch("select file.path from file, set_file
                where file.id = set_file.file_id
                  and file.image = true
                  and set_file.set_id = ?
                order by set_file.pos", id) { |r| blk.call(r) }
  end

  def list_empty_sets(&blk)
    $db.fetch("select set.id, set.dir from set_file, set, file
                where set_file.set_id = set.id
                  and set_file.file_id = file.id
                group by set.id, set.dir
                having count(case when
                              file.image then 1 end) = 0") { |r| blk.call(r) }
  end

  def count_sets(nonempty)
    s = '='
    s = '>' if nonempty
    #ugly

    $db.fetch("select count(*) from set
                where id in (select set.id from set_file, set, file
                              where set_file.set_id = set.id
                                     and set_file.file_id = file.id
                              group by set.id
                              having count(case when
                                            file.image then 1 end) #{s} 0)").first[:count];
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
- list_files_of_set(@id) do |r|
    %img{ :src => "http://127.0.0.1:4567#{r[:path]}" }

@@ all
%p=count()
%p=count_sets(true)
%p=count_sets(false)
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
