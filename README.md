# Astrolab Workspace

This repo manages Astrolab services via docker-compose.
 
## Requirements

* Git
* Docker

## Getting Started

1. Run `source <development|production>.sh` to load the correct environment.
2. Create your containers with `docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml up
 up --build`.
3. Do your work!
4. Restart your containers with `docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml stop` and `docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml up --build`.
5. Tear down your containers and related infrastructure with `docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml down`.

## Developing Brain

### Updating gems

```
source development.rb
docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml exec brain rbenv exec bundle install
```

### Running specs

```
source development.rb
docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml run --rm -e RACK_ENV=test brain rbenv exec bundle exec rspec spec
```

If integration specs bomb, you can cleanup integration containers with:
```
docker ps | grep phd2 | awk '{print $1}' | xargs docker rm -f
```

## Fixing connectivity between a development astrolab and a development server

In some network configurations, you won't be able to access your host IP address from within a container. If this is the case, you can access your host through the Docker gateway. You'll find this is necessary when you run `docker-compose up` and don't see any responses from the heartbeat service. Rectify as follows:

1. In a new terminal, run `source development.sh` again.
2. Run `docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml exec -T heartbeat /sbin/ip route get 1 | /usr/bin/awk '{print $3;exit}'` to get your host IP via Docker's network gateway.
3. Edit /tmp/lan_ip_address, and set it to the value returned above.
4. Run `docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml restart heartbeat`.

## Running the server specs:

`docker-compose -f docker-compose.yml -f docker-compose.development-overrides.yml run --rm -e RACK_ENV=test brain rbenv exec bundle exec rspec spec`

## Notes

### host-data directory

The `host-data` directory contains mock data that is intended to be auto-discovered by the host OS, stored in plaintext files, and mounted in read-only mode inside containers at `/host-data`.
