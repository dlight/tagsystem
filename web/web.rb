require 'rubygems'
require 'sequel'
require 'sinatra'

set :environment, :production

set :run, true
set :port, 1025

db = Sequel.connect('postgres://localhost')

get '/' do
  @db = db
  haml :index
end

get '/set/:id' do |id|
  @db = db
  @id = id
  haml :set
end

enable :inline_templates

__END__

@@ layout
= yield

@@ index
- @db.fetch("select id, dir from set") do |r|
  %p
    %a{ :href => "set/#{r[:id]}" }
      =File.basename r[:dir]

@@ set
%a{ :href => '/' } "Up"
%br
- @db.fetch("select path from file where image = true and id in (select file_id from set_file where set_id = #{@id} order by pos desc)") do |r|
    %img{ :src => "http://127.0.0.1:4567#{r[:path]}" }
