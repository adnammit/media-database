# MEDIA DATABASE

Relations and seeds for the PostgreSQL database that supports the movie app and service

## LOCAL QUICKSTART
```sh
# login to manage db locally
psql -d media -U postgres
```
* to seed, copy/paste `/seeders/media.sql` into the psql cli or just use PGAdmin GUI

## RESOURCES
* [Remember how psql do](https://www.tutorialspoint.com/postgresql/postgresql_insert_query.htm)
* [deploying a psql db to render](https://render.com/docs/databases#creating-a-database).  after configuring the db on Render, you can connect with pgadmin and seed/manage the db from there

## TO DO
* consider adding a DateModified to User and UserTitle tables
* as it stands, if a user has a title stored, then deletes it, then adds it again, we really just set the existing object to inactive and then active again: one titleId/imdbId per userId is strictly enforced.
	- for now this seems good but it might get weird if we attach more metadata to userTitle
	- ex: you have an entry and take notes on it, then delete it, then add it again and see the notes. is that what you expect?


