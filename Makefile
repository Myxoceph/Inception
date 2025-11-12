BOLD_GREEN = \033[1;32m
BOLD_YELLOW = \033[1;33m
BOLD_RED = \033[1;31m
BOLD_BLUE = \033[1;34m
BOLD_MAGENTA = \033[1;35m
BOLD_CYAN = \033[1;36m
BOLD_WHITE = \033[1;37m
RESET = \033[0m

all:up

up: setup
	@total=2221; \
		done=0; \
		perc=0; \
		docker compose -f srcs/docker-compose.yml build --no-cache --progress=plain 2>&1 | \
		while read -r line; do \
			done=$$((done+1)); \
			perc=$$((done*100/total)); \
			printf "$(BOLD_CYAN)\rBuilding images [%-40s] %3d%%" $$(printf '#%.0s' $$(seq 1 $$((done*40/total)))) $$perc; \
		done; \
		printf "\n"; \
		printf "$(BOLD_GREEN)DONE!$(RESET)\n"; \
		printf "$(BOLD_BLUE)Starting services...$(RESET)\n"; \
	docker compose -f srcs/docker-compose.yml up -d

down:
	@docker compose -f srcs/docker-compose.yml down

clean:
	@printf "$(BOLD_YELLOW)Cleaning up...$(RESET)\n"
	@rm -rf /home/abakirca/data/mariadb/
	@rm -rf /home/abakirca/data/wordpress/
	@docker compose -f srcs/docker-compose.yml down -v

prune: clean
	@printf "$(BOLD_RED)Pruning Docker... $(BOLD_WHITE)(This may take a while)$(RESET)\n"
	@docker system prune -af --volumes >/dev/null 2>&1
	@printf "$(BOLD_GREEN)Done!$(RESET)\n"


re: clean up

setup:
	@printf "$(BOLD_MAGENTA)Setting up directories...$(RESET)\n"
	@mkdir -p /home/abakirca/data/mariadb
	@mkdir -p /home/abakirca/data/wordpress

nginx:
	@docker exec -it nginx bash

nginx_logs:
	@docker logs -f nginx

mariadb:
	@docker exec -it mariadb bash

mariadb_logs:
	@docker logs -f mariadb

wordpress:
	@docker exec -it wordpress bash

wordpress_logs:
	@docker logs -f wordpress

.PHONY: all up down clean prune re setup nginx nginx_logs mariadb mariadb_logs wordpress wordpress_logs
