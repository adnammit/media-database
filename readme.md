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

