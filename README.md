# Astrolab Workspace

This repo creates an environment for developing Astrolab.
 
## Requirements

* Git
* Docker

## Getting Started

1. Initialize your workspace with: `./initialize-workspace`.
2. Create your environment with `docker-compose up --build`.
3. Do your work!
4. Restart your environment with `docker-compose stop` and `docker-compose up`.
5. Tear down your environment with `docker-compose down`.

## Running the server specs:

`docker-compose run brain rbenv exec bundle exec rspec spec`

## Notes

### host-data directory

The `host-data` directory contains mock data that is intended to be auto-discovered by the host OS, stored in plaintext files, and mounted in read-only mode inside containers at `/host-data`.
