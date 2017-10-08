# Astrolab Workspace

This repo manages Astrolab services via docker-compose.
 
## Requirements

* Git
* Docker

## Getting Started

1. Run `source <development|production>.sh` to load the correct environment.
2. Create your containers with `docker-compose create --build`.
3. Do your work!
4. Restart your containers with `docker-compose stop` and `docker-compose up`.
5. Tear down your containers and related infrastructure with `docker-compose down`.

## Running the server specs:

`docker-compose run --rm -e RACK_ENV=test brain rbenv exec bundle exec rspec spec`

## Notes

### host-data directory

The `host-data` directory contains mock data that is intended to be auto-discovered by the host OS, stored in plaintext files, and mounted in read-only mode inside containers at `/host-data`.
