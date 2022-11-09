select * from public.user;
select * from media.title;
select * from media.usertitle;
select * from media.mediatype;

select public.addUser('test','test@test.com','testy','mctesterson');
select public.addUser('mfpilot','solo@test.com','han','solo');
select public.addUser('ss','s@test.com','testy','mctesterson') as userid;

select * from public.getUser();
select * from public.getUser(_userid => 1);
select * from public.getUser(_username => 'test');
select * from public.getUser(_username => 'foo', _userid => 3);
select * from public.getUser(_username => 'foo', _userid => 4, _email => 'foo@test.com');

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

