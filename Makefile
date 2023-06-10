.PHONY: start_db stop_db


### DOCKER ###
start_db:
	docker-compose -f docker-compose.db.yml up

stop_db:
	docker-compose -f docker-compose.db.yml down --remove-orphans

### DEV ###
setup_dev:
	mix deps.get
	mix ecto.setup