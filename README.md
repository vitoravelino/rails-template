# Rails Template

The focus (so far) of this rails template is only API applications.

## Requirements

- Ruby
- Bundler: `gem install bundler`
- Rails: `gem install rails`

If you want to run locally you'll need:

- Database (MySQL/PostgreSQL): your preferred database and its development library (e.g.: postgresql13-devel, libmariadb-devel, libpq-dev, libmariadbclient-dev)
- Redis (optional)
- MongoDB (optional)

Or use containers (optional):

- Docker
- docker-compose

## Usage

```shell
rails new myapp -d postgresql -m https://raw.githubusercontent.com/vitoravelino/rails-template/master/template.rb  --api
```

or if you download the repo you can enter the folder and run:

```shell
rails new myapp -d postgresql -m template.rb --api
```

You can use environment variables to enable

- Redis: REDIS=1
- Docker/Compose: COMPOSE=1
- MongoDB: MONGO=1

An example with all of them enabled would be

```shell
REDIS=1 MONGO=1 COMPOSE=1 rails new myapp -m https://raw.githubusercontent.com/vitoravelino/rails-template/master/template.rb --api
```

## Roadmap

- [ ] Account model
- [ ] Account routes
- [ ] Account controller
- [ ] Session controller
- [ ] Admin Panel (?)
