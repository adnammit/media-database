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

create or replace function public.addUser(
	_username text,
	_email text,
	_firstname text,
	_lastname text)
returns int as $$
declare _userid int;
begin

	insert into public.user(username, email, firstname, lastname)
	values (_username, _email, _firstname, _lastname);
	return (select id from public.user where username = _username);

end;
$$ language plpgsql;

create or replace function public.getUser(_username in text)
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
	where u.username = _username;

end;
$$ language plpgsql;

create or replace function public.deleteUser(
	_userid in int)
returns void as $$
begin

	update public.user
	set
		active = false
	where _userid = id;

end;
$$ language plpgsql;

create or replace function media.addTitle(
	_moviedbid in int,
	_imdbid in text,
	_mediatype in text)
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

create or replace function media.addUserTitle(
	_userid in int,
	_moviedbid in int,
	_imdbid in text,
	_mediatype in text,
	_rating in int DEFAULT null,
	_watched in boolean DEFAULT null,
	_favorite in boolean DEFAULT null,
	_queued in boolean DEFAULT null,
	_active in boolean DEFAULT null)
returns void as $$
declare _titleid int;
begin

	_titleid := media.addTitle(_moviedbid, _imdbid, _mediatype);

	if exists (select from media.usertitle where titleid = _titleid and userid = _userid)
	then
		perform media.updateUserTitle(_userid, _titleid, _rating, _watched, _favorite, _queued, _active);
	else
		insert into media.usertitle(userid, titleid, rating, watched, favorite, queued)
		values (_userid, _titleid, _rating, coalesce(_watched, false), coalesce(_favorite, false), coalesce(_queued, false));
	end if;

end;
$$ language plpgsql;

create or replace function media.updateUserTitle(
	_userid in int,
	_titleid in int,
	_rating in int DEFAULT null,
	_watched in boolean DEFAULT null,
	_favorite in boolean DEFAULT null,
	_queued in boolean DEFAULT null,
	_active in boolean DEFAULT null)
returns void as $$
begin

	update media.usertitle
	set
		rating = coalesce(_rating, rating),
		watched = coalesce(_watched, watched),
		favorite = coalesce(_favorite, favorite),
		queued = coalesce(_queued, queued),
		active = coalesce(_active, active)
	where titleid = _titleid and userid = _userid;

end;
$$ language plpgsql;

create or replace function media.getUserTitles(_userid in int)
returns table (
	userid int,
	titleid int,
	moviedbid int,
	imdbid text,
	rating int,
	watched boolean,
	favorite boolean,
	queued boolean
) as $$
begin

	return query
	select
		um.userid as "userid",
		t.id as "titleid",
		t.moviedbid as "moviedbid",
		t.imdbid as "imdbid",
		um.rating as "rating",
		um.watched as "watched",
		um.favorite as "favorite",
		um.queued as "queued"
	from media.usertitle um
		inner join media.title t on t.id = um.titleid
	where um.userid = _userid and um.active;

end;
$$ language plpgsql;

create or replace function media.deleteUserTitle(
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

