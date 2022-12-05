do $$

begin

	create schema if not exists media;

	drop table if exists public.user cascade;
	create table public.user(
		id              serial primary key  not null,
		username        text                not null unique,
		email           text                not null unique,
		firstname       text                not null,
		lastname        text                not null,
		active          boolean             not null default true,
		datecreated     timestamptz         not null default NOW()
	);

	drop table if exists media.mediatype cascade;
	create table media.mediatype(
		id              serial primary key  not null,
		enum            text                not null unique,
		description     text                not null unique,
		datecreated     timestamptz         not null default NOW()
	);

	insert into media.mediatype("enum","description")
		values
			('movie','Movie-type media items'),
			('tv','Television-type media items');

	drop table if exists media.title cascade;
	create table media.title(
		id              serial primary key  not null,
		moviedbid       int					not null unique,
		imdbid          text                not null,
		mediatypeid     int                 not null references media.mediatype(id),
		datecreated     timestamptz         not null default NOW()
	);

	drop table if exists media.usertitle cascade;
	create table media.usertitle(
		id              serial primary key  not null,
		userid          int                 not null references public.user(id),
		titleid			int                 not null references media.title(id),
		rating          int                 check(rating >= 0 AND rating <= 5),
		watched         boolean             not null default false,
		favorite        boolean             not null default false,
		queued          boolean             not null default false,
		active          boolean             not null default true,
		datecreated     timestamptz         not null default NOW(),
		unique (userid, titleid)
	);

end $$;

drop function if exists public.addUser;
create function public.addUser(
	_username text,
	_email text,
	_firstname text,
	_lastname text)
returns table (
	userid int,
	username text,
	email text,
	firstname text,
	lastname text,
	active boolean
) as $$
begin

	insert into public.user(username, email, firstname, lastname)
	values (_username, _email, _firstname, _lastname);

	return query
	select
		u.id as "userid",
		u.username as "username",
		u.email as "email",
		u.firstname as "firstname",
		u.lastname as "lastname",
		u.active as "active"
	from public.user u
	where u.username = _username;

end;
$$ language plpgsql;

drop function if exists public.getUser;
create function public.getUser(
	_userid in int default null,
	_username in text default null,
	_email in text default null
)
returns table (
	userid int,
	username text,
	email text,
	firstname text,
	lastname text,
	active boolean
) as $$
begin

	return query
	select
		u.id as "userid",
		u.username as "username",
		u.email as "email",
		u.firstname as "firstname",
		u.lastname as "lastname",
		u.active as "active"
	from public.user u
	where (_userid is null or u.id = _userid)
		and (_username is null or u.username ilike _username)
		and (_email is null or u.email ilike _email)
	;
end;
$$ language plpgsql;

drop function if exists public.updateUser;
create function public.updateUser(
	_userid in int,
	_firstname text default null,
	_lastname text default null,
	_active boolean default null
)
returns table (
	userid int,
	username text,
	email text,
	firstname text,
	lastname text,
	active boolean
) as $$
begin

	update public.user u
	set
		firstname = coalesce(_firstname, u.firstname),
		lastname = coalesce(_lastname, u.lastname),
		active = coalesce(_active, u.active)
	where id = _userid;

	return query
	select
		u.id as "userid",
		u.username as "username",
		u.email as "email",
		u.firstname as "firstname",
		u.lastname as "lastname",
		u.active as "active"
	from public.user u
	where id = _userid;

end;
$$ language plpgsql;

-- deleteUser is somewhat redundant -- we can do this with updateUser
drop function if exists public.deleteUser;
create function public.deleteUser(
	_userid in int)
returns void as $$
begin

	update public.user
	set
		active = false
	where _userid = id;

end;
$$ language plpgsql;

drop function if exists media.addTitle;
create function media.addTitle(
	_moviedbid in int,
	_imdbid in text,
	_mediatype in text)
-- return full obj?
returns int as $$
declare _mediatypeid int;
begin

	if not exists(select from media.title where moviedbid = _moviedbid)
	then
		_mediatypeid := (select id from media.mediatype where enum = _mediatype);
		insert into media.title(moviedbid, imdbid, mediatypeid)
		values (_moviedbid, _imdbid, _mediatypeid);
	end if;

	return (select id from media.title where moviedbid = _moviedbid);

end;
$$ language plpgsql;

-- in practice we use this to add new and update existing -- updateUserTitle is just a helper for this proc
drop function if exists media.addUserTitle;
create function media.addUserTitle(
	_userid in int,
	_moviedbid in int,
	_imdbid in text,
	_mediatype in text,
	_rating in int DEFAULT null,
	_watched in boolean DEFAULT null,
	_favorite in boolean DEFAULT null,
	_queued in boolean DEFAULT null,
	_active in boolean DEFAULT true) -- ensure that if it exists and is inactive, we activate it and put it in the state we want
returns table (
	userid int,
	titleid int,
	moviedbid int,
	imdbid text,
	mediatype text,
	rating int,
	watched boolean,
	favorite boolean,
	queued boolean
) as $$
declare _titleid int;
begin

	_titleid := media.addTitle(_moviedbid, _imdbid, _mediatype);

	if exists (select from media.usertitle ut where ut.titleid = _titleid and ut.userid = _userid)
	then
		perform media.updateUserTitle(_userid, _titleid, _rating, _watched, _favorite, _queued, _active);
	else
		insert into media.usertitle(userid, titleid, rating, watched, favorite, queued)
		values (_userid, _titleid, _rating, coalesce(_watched, false), coalesce(_favorite, false), coalesce(_queued, false));
	end if;

	return query
	select
		ut.userid as "userid",
		t.id as "titleid",
		t.moviedbid as "moviedbid",
		t.imdbid as "imdbid",
		mt.enum as "mediatype",
		ut.rating as "rating",
		ut.watched as "watched",
		ut.favorite as "favorite",
		ut.queued as "queued"
	from media.usertitle ut
		inner join media.title t on t.id = ut.titleid
		inner join media.mediatype mt on mt.id = t.mediatypeid
	where ut.userid = _userid
		and ut.titleid = _titleid
		and ut.active;

end;
$$ language plpgsql;

drop function if exists media.getUserTitle;
create function media.getUserTitle(
	_userid in int default null,
	_titleid in int default null,
	_imdbid in text default null
)
returns table (
	userid int,
	titleid int,
	moviedbid int,
	imdbid text,
	mediatype text,
	rating int,
	watched boolean,
	favorite boolean,
	queued boolean
) as $$
begin

	return query
	select
		ut.userid as "userid",
		t.id as "titleid",
		t.moviedbid as "moviedbid",
		t.imdbid as "imdbid",
		mt.enum as "mediatype",
		ut.rating as "rating",
		ut.watched as "watched",
		ut.favorite as "favorite",
		ut.queued as "queued"
	from media.usertitle ut
		inner join media.title t on t.id = ut.titleid
		inner join media.mediatype mt on mt.id = t.mediatypeid
	where (_userid is null or ut.userid = _userid)
		and (_titleid is null or ut.titleid = _titleid)
		and (_imdbid is null or t.imdbid = _imdbid)
		and ut.active
	;

end;
$$ language plpgsql;

drop function if exists media.updateUserTitle;
create function media.updateUserTitle(
	_userid in int,
	_titleid in int,
	_rating in int DEFAULT null,
	_watched in boolean DEFAULT null,
	_favorite in boolean DEFAULT null,
	_queued in boolean DEFAULT null,
	_active in boolean DEFAULT null)
returns table (
	userid int,
	titleid int,
	moviedbid int,
	imdbid text,
	mediatype text,
	rating int,
	watched boolean,
	favorite boolean,
	queued boolean
) as $$
begin

	update media.usertitle ut
	set
		rating = coalesce(_rating, ut.rating),
		watched = coalesce(_watched, ut.watched),
		favorite = coalesce(_favorite, ut.favorite),
		queued = coalesce(_queued, ut.queued),
		active = coalesce(_active, ut.active)
	where ut.titleid = _titleid and ut.userid = _userid;

	return query
	select
		ut.userid as "userid",
		t.id as "titleid",
		t.moviedbid as "moviedbid",
		t.imdbid as "imdbid",
		mt.enum as "mediatype",
		ut.rating as "rating",
		ut.watched as "watched",
		ut.favorite as "favorite",
		ut.queued as "queued"
	from media.usertitle ut
		inner join media.title t on t.id = ut.titleid
		inner join media.mediatype mt on mt.id = t.mediatypeid
	where ut.userid = _userid
		and ut.titleid = _titleid;

end;
$$ language plpgsql;

drop function if exists media.deleteUserTitle;
create function media.deleteUserTitle(
	_userid in int,
	_titleid in int)
returns void as $$
begin

	update media.usertitle
	set
		active = false
	where _userid = userid and _titleid = titleid;

end;
$$ language plpgsql;


-- FOR NOW, DO THESE SEEDS EVERYTIME WE REBUILD
select * from public.addUser('test','test@test.com','Testy','McTesterson'); -- immutable demo account -- do not change username/email
select * from public.addUser('mfpilot','solo@test.com','han','solo');

select * from media.addUserTitle(
	_userid => 1,
	_moviedbid => 299536,
	_imdbid => 'tt4154756',
	_mediatype => 'movie',
	_rating => null,
	_watched => null,
	_favorite => true,
	_queued => true);

select * from media.addUserTitle(1, 280, 'tt0103064', 'movie', 3, true, false, true);
select * from media.addUserTitle(1, 541305, 'tt8143990', 'movie', 5, true, true, false);
select * from media.addUserTitle(1, 2108, 'tt0088847', 'movie', 0, false, false, false);
select * from media.addUserTitle(1, 95, 'tt0118276', 'tv', 5, true, true, false);
select * from media.addUserTitle(1, 115004, 'tt10155688', 'tv', 0, false, false, true);
select * from media.addUserTitle(1, 299536, 'tt4154756', 'movie', 0, false, false, true);
select * from media.addUserTitle(1, 61174, 'tt4163486', 'tv', 0, false, false, true);
select * from media.addUserTitle(1, 92685, 'tt8050756', 'tv', 0, false, false, true);
select * from media.addUserTitle(1, 97, 'tt0084827', 'movie', 0, false, false, true);
select * from media.addUserTitle(1, 364, 'tt0103776', 'movie', 0, false, false, true);
select * from media.addUserTitle(1, 13403, 'tt0248845', 'movie', 0, false, false, true);
select * from media.addUserTitle(1, 83631, 'tt7908628', 'tv', 0, false, false, true);
select * from media.addUserTitle(1, 545611, 'tt6710474', 'movie', 0, false, false, true);

select * from media.addUserTitle(2, 95, 'tt0118276', 'tv');
select * from media.addUserTitle(2, 280, 'tt0103064', 'movie', null, null, true);
