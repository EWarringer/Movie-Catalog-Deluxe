require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end
get '/' do
	redirect '/actors'
end

get '/actors' do
	db_connection do |conn|
	actors_table = conn.exec('SELECT name FROM actors ORDER BY name')
 	actors = actors_table.values.flatten
	erb :'actors/index', locals: { actors: actors }
	end
end

get "/actors/:name" do

  roles = db_connection { |conn| conn.exec("SELECT movies.title, cast_members.character
  FROM cast_members
  JOIN movies ON cast_members.movie_id = movies.id
  JOIN actors ON cast_members.actor_id = actors.id
  WHERE actors.name = '#{params[:name]}';")}
  erb :'actors/show', locals: { name: params[:name], roles: roles }
end

get '/movies' do
	db_connection do |conn|
	movies = conn.exec('SELECT title, year FROM movies ORDER BY title')
	erb :'movies/index', locals: { movies: movies }
	end
end

get "/movies/:name" do
  movies = db_connection { |conn| conn.exec("SELECT cast_members.character,
    genres.name AS gname, actors.name, studios.name AS sname
    FROM cast_members
    JOIN movies ON cast_members.movie_id = movies.id
    JOIN actors ON cast_members.actor_id = actors.id
    JOIN studios ON movies.studio_id = studios.id
    JOIN genres ON movies.genre_id = genres.id
    WHERE movies.title = '#{params[:name]}';")}
  erb :'movies/show', locals: { title: params[:name], studio: movies[0]["sname"], genre: movies[0]["gname"], cast: movies }
end
