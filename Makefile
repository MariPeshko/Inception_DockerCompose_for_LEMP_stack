NAME			= inception
SRCS			= srcs/
DOCKER-COMPOSE	= $(SRCS)/docker-compose.yml

# Rules

all: $(NAME)

$(NAME): up

# start the containers trough docker compose
up:
# why create_dir here? I have them persistently... Is it for safety?
	@docker compose -p $(NAME) -f $(DOCKER-COMPOSE) up --build || (echo " $(FAIL)" && exit 1)
	@echo " $(UP)"

# stop the containers through docker compose
down:
	@docker compose -p $(NAME) down
	@echo " $(DOWN)"

# Customs

GREEN		= \033[0;32m
RED			= \033[0;31m
RESET		= \033[0m

MARK		= $(GREEN)✔$(RESET)
EXECUTED	= $(GREEN)Executed$(RESET)

# Messages

UP			= $(MARK) $(NAME)		$(EXECUTED)

FAIL		= $(RED)✔$(RESET) $(NAME)		$(RED)Failed$(RESET)
