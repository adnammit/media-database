select * from public.user;
select * from media.title;
select * from media.usertitle;
select * from media.mediatype;

select * from public.addUser('test','test@test.com','Testy','McTesterson'); -- immutable demo account -- do not change username/email
select * from public.addUser('mfpilot','solo@test.com','han','solo');
select * from public.addUser('foo','foo@test.com','foo','bar');
select * from public.addUser('foo','foo@test.com');

select * from public.getUser();
select * from public.getUser(_userid => 1);
select * from public.getUser(_username => 'test');
select * from public.getUser(_username => 'FOO', _userid => null);
select * from public.getUser(_username => null, _userid => 3, _email => null);
select * from public.getUser(_username => null, _userid => null, _email => 'TEST@TEST.COM');

select * from public.updateUser(
	_userid => 1,
	_firstname => 'marty',
	_lastname => 'fillmore',
	_active => false
);

-- select * from media.addUserTitle(
-- 	_userid => 1,
-- 	_moviedbid => 299536,
-- 	_imdbid => 'tt4154756',
-- 	_mediatype => 'movie',
-- 	_rating => null,
-- 	_watched => null,
-- 	_favorite => true,
-- 	_queued => true);

-- select * from media.addUserTitle(1, 280, 'tt0103064', 'movie', 3, true, false, true);
-- select * from media.addUserTitle(1, 541305, 'tt8143990', 'movie', 5, true, true, false);
-- select * from media.addUserTitle(1, 2108, 'tt0088847', 'movie', 0, false, false, false);
-- select * from media.addUserTitle(1, 95, 'tt0118276', 'tv', 5, true, true, false);
-- select * from media.addUserTitle(1, 115004, 'tt10155688', 'tv', 0, false, false, true);
-- select * from media.addUserTitle(1, 32726, 'tt1561755', 'tv', 5, false, false, true);
-- select * from media.addUserTitle(2, 95, 'tt0118276', 'tv');
-- select * from media.addUserTitle(2, 280, 'tt0103064', 'movie', null, null, true);

select * from media.getUserTitle(_userid => 1);
select * from media.getUserTitle(_userid => 1, _titleid => 2);
select * from media.getUserTitle(_userid => 1, _imdbid => 'tt0103064');

select * from media.getUserTitle(1, 1);

select * from media.updateUserTitle(
	_userid => 1,
	_titleid => 13,
	_rating => null,
	_watched => null,
	_favorite => false,
	_queued => null);

select media.deleteusertitle(1,1);

select * from media.userlist
select * from media.userlistitem
select * from media.getUserLists(_userid => 1);


-- -- add to seeders list
-- select * from media.addUserList(
-- 	_userid => 1,
-- 	_name => 'Wind Down Cartoons',
-- 	_description => 'Mindless cartoons to watch at the end of the day');

-- select * from media.addUserListItem(
-- 	_listid => 1,
-- 	_titleid => 7
-- );
-- select * from media.addUserListItem(
-- 	_listid => 1,
-- 	_titleid => 8
-- );
-- select * from media.addUserListItem(
-- 	_listid => 1,
-- 	_titleid => 14
-- );

-- select * from media.addUserList(
-- 	_userid => 1,
-- 	_name => 'Sci-Fi');

-- select * from media.addUserListItem(
-- 	_listid => 2,
-- 	_titleid => 2
-- );

-- select * from media.addUserListItem(
-- 	_listid => 2,
-- 	_titleid => 9
-- );


