SELECT movies.title, movies.id, actors.name, actors.id, cast_members.character
	FROM movies
	JOIN cast_members
	ON movies.id = cast_members.movie_id
	JOIN actors
	ON actors.id = cast_members.actor_id
	;
