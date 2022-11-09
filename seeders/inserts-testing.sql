select * from public.user;
select * from media.title;
select * from media.usertitle;
select * from media.mediatype;

select * from public.addUser('test','test@test.com','testy','mctesterson');
select * from public.addUser('mfpilot','solo@test.com','han','solo');
select * from public.addUser('foo','foo@test.com','foo','bar');

select * from public.getUser();
select * from public.getUser(_userid => 1);
select * from public.getUser(_username => 'test');
select * from public.getUser(_username => 'foo', _userid => null);
select * from public.getUser(_username => null, _userid => 3, _email => null);
select * from public.getUser(_username => null, _userid => null, _email => null);

select * from public.updateUser(
	_userid => 1,
	_firstname => 'marty',
	_lastname => 'fillmore',
	_active => false
);

select media.addUserTitle(
	_userid => 1,
	_moviedbid => 299536,
	_imdbid => 'tt4154756',
	_mediatype => 'movie',
	_rating => null,
	_watched => null,
	_favorite => true,
	_queued => true);

select media.addUserTitle(1, 280, 'tt0103064', 'movie', 3, true, false, true);
select media.addUserTitle(1, 541305, 'tt8143990', 'movie', 5, true, true, false);
select media.addUserTitle(1, 2108, 'tt0088847', 'movie', 0, false, false, false);
select media.addUserTitle(1, 95, 'tt0118276', 'tv', 5, true, true, false);
select media.addUserTitle(1, 115004, 'tt10155688', 'tv', 0, false, false, true);
select media.addUserTitle(2, 95, 'tt0118276', 'tv');
select media.addUserTitle(2, 280, 'tt0103064', 'movie', null, null, true);

select * from media.getUserTitles(1);
select * from media.getUserTitles(2);

select media.deleteusertitle(1,1);

