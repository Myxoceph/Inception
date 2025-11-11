# ANSI color codes for terminal output formatting
# These variables store escape sequences that change text color in the terminal
BOLD_GREEN = \033[1;32m      # Bold green text - used for success messages
BOLD_YELLOW = \033[1;33m     # Bold yellow text - used for warning/cleaning messages
BOLD_RED = \033[1;31m        # Bold red text - used for destructive operations
BOLD_BLUE = \033[1;34m       # Bold blue text - used for informational messages
BOLD_MAGENTA = \033[1;35m    # Bold magenta text - used for setup messages
BOLD_CYAN = \033[1;36m       # Bold cyan text - used for progress indicators
BOLD_WHITE = \033[1;37m      # Bold white text - used for additional info
RESET = \033[0m              # Reset all formatting back to terminal default

# Default target - runs when you simply type 'make' without arguments
# This target depends on 'up' target, so it will execute the 'up' recipe
all:up

# Main target to build and start all Docker containers
# Depends on 'setup' target which must complete first before this runs
up: setup
	# @ symbol suppresses the command from being echoed to the terminal
	# total=2221: Sets total number of expected lines from docker build output (approximate)
	# done=0: Initialize counter to track processed lines
	@total=2221; \
		done=0; \
		# docker compose: Modern Docker Compose command (v2)
		# -f srcs/docker-compose.yml: Specify the compose file location
		# build: Build or rebuild services defined in compose file
		# --no-cache: Build images from scratch without using Docker's layer cache
		# --progress=plain: Show build output in plain text format (not fancy UI)
		# 2>&1: Redirect stderr (2) to stdout (1) so all output goes through the pipe
		# |: Pipe the output to the next command
		docker compose -f srcs/docker-compose.yml build --no-cache --progress=plain 2>&1 | \
		# while loop reads each line of docker build output
		# read -r: Read line without interpreting backslashes
		# line: Variable name to store each line
		while read -r line; do \
			# Increment the done counter for each line processed
			# $$((done+1)): Double $ escapes it in Makefile, performs arithmetic
			done=$$((done+1)); \
			# Calculate percentage: (done * 100) / total
			perc=$$((done*100/total)); \
			# printf: Print formatted output
			# \r: Carriage return - moves cursor to beginning of line (overwrites previous output)
			# [%-40s]: Left-aligned string in 40-character field (for progress bar)
			# %3d%%: 3-digit decimal followed by literal % (for percentage)
			# $$(printf '#%.0s' $$(seq 1 $$((done*40/total)))): Creates string of # characters
			#   - seq 1 N: generates sequence from 1 to N
			#   - printf '#%.0s': prints # for each number in sequence
			#   - done*40/total: scales done count to 40 characters for bar width
			printf "$(BOLD_CYAN)\rBuilding images [%-40s] %3d%%" $$(printf '#%.0s' $$(seq 1 $$((done*40/total)))) $$perc; \
		done; \
		# \n: Print newline to move to next line after progress bar completes
		printf "\n$(BOLD_GREEN)DONE!$(RESET)\n"; \
		# Print informational message about starting services
		printf "$(BOLD_BLUE)Starting services...$(RESET)\n"; \
	# docker compose up: Create and start containers
	# -d: Detached mode - run containers in background
	docker compose -f srcs/docker-compose.yml up -d

# Target to stop and remove all running containers
down:
	# @ symbol suppresses command echo
	# docker compose down: Stop and remove containers, networks, volumes, and images created by 'up'
	# -f srcs/docker-compose.yml: Specify the compose file location
	@docker compose -f srcs/docker-compose.yml down

# Target to clean up all data and stop containers
clean:
	# Print cleaning message in yellow color
	@printf "$(BOLD_YELLOW)Cleaning up...$(RESET)\n"
	# rm: Remove command
	# -r: Recursive - remove directories and their contents
	# -f: Force - ignore nonexistent files, never prompt
	# /home/ahmet/data/mariadb/: Remove MariaDB persistent data directory
	@rm -rf /home/ahmet/data/mariadb/
	# Remove WordPress persistent data directory
	@rm -rf /home/ahmet/data/wordpress/
	# docker compose down: Stop and remove containers
	# -v: Also remove named volumes declared in the `volumes` section of compose file
	@docker compose -f srcs/docker-compose.yml down -v

# Target to perform complete cleanup including Docker system prune
# Depends on 'clean' target which runs first
prune: clean
	# Print warning message in red that this operation may take time
	@printf "$(BOLD_RED)Pruning Docker... $(BOLD_WHITE)(This may take a while)$(RESET)\n"
	# docker system prune: Remove unused Docker data
	# -a: Remove all unused images, not just dangling ones
	# -f: Force - don't prompt for confirmation
	# --volumes: Also prune volumes
	# >/dev/null: Redirect stdout to null device (suppress normal output)
	# 2>&1: Redirect stderr to stdout (also suppressed)
	@docker system prune -af --volumes >/dev/null 2>&1
	# Print completion message in green
	@printf "$(BOLD_GREEN)Done!$(RESET)\n"


# Target to rebuild everything from scratch
# Depends on 'clean' and 'up' targets which run in sequence
re: clean up

# Target to create necessary directories before building
setup:
	# Print setup message in magenta color
	@printf "$(BOLD_MAGENTA)Setting up directories...$(RESET)\n"
	# mkdir: Make directory command
	# -p: Create parent directories as needed, no error if directory exists
	# /home/ahmet/data/mariadb: Create directory for MariaDB persistent storage
	@mkdir -p /home/ahmet/data/mariadb
	# Create directory for WordPress persistent storage
	@mkdir -p /home/ahmet/data/wordpress

# .PHONY declares targets that don't represent actual files
# This prevents make from confusing these targets with files of the same name
# and ensures they always run when called, regardless of file timestamps
.PHONY: all up down clean prune re setup
