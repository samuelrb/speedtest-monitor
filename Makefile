YML = docker-compose.yml

MAKEFLAGS += --no-print-directory

all:
	@bash -c '\
	if grep -q -E "^[[:space:]]*CRON_SCHEDULE:[[:space:]]*$$" ${YML}; then \
		echo "🕒 Select the execution frequency:"; \
		echo "1) Every minute"; \
		echo "2) Every 15 minutes"; \
		echo "3) Every 30 minutes"; \
		echo "4) Every hour"; \
		echo "5) Custom cron expression"; \
		read -rp "Enter choice [1-5]: " option; \
		case "$$option" in \
			1) schedule="\"* * * * *\"";; \
			2) schedule="\"*/15 * * * *\"";; \
			3) schedule="\"*/30 * * * *\"";; \
			4) schedule="\"0 * * * *\"";; \
			5) read -rp "Enter custom cron expression: " schedule;; \
			*) echo "❗ Invalid option. Using default: Every 30 minutes."; schedule="*/30 * * * *";; \
		esac; \
		sed -i "s|^\([[:space:]]*CRON_SCHEDULE:\)[[:space:]]*$$|\1 $$schedule|" ${YML}; \
	fi; \
	if grep -q -E "^[[:space:]]*MIN_DOWNLOAD:[[:space:]]*$$" ${YML}; then \
		echo "⬇️  MIN_DOWNLOAD is empty. Enter a value or press enter to use default 270:"; \
		read -r min_download; \
		if [ -z "$$min_download" ]; then min_download=270; fi; \
		sed -i "s|^\([[:space:]]*MIN_DOWNLOAD:\)[[:space:]]*$$|\1 $$min_download|" ${YML}; \
	fi; \
	if grep -q -E "^[[:space:]]*MIN_UPLOAD:[[:space:]]*$$" ${YML}; then \
		echo "⬆️  MIN_UPLOAD is empty. Enter a value or press enter to use default 260:"; \
		read -r min_upload; \
		if [ -z "$$min_upload" ]; then min_upload=260; fi; \
		sed -i "s|^\([[:space:]]*MIN_UPLOAD:\)[[:space:]]*$$|\1 $$min_upload|" ${YML}; \
	fi; \
	if grep -q -E "^[[:space:]]*TELEGRAM_BOT_TOKEN:[[:space:]]*$$" ${YML}; then \
		echo "🤖 TELEGRAM_BOT_TOKEN is empty. Enter a value or press enter to skip:"; \
		read -r token; \
		if [ -z "$$token" ]; then token=\"\"; else token=\"$$token\"; fi; \
		sed -i "s|^\([[:space:]]*TELEGRAM_BOT_TOKEN:\)[[:space:]]*$$|\1 $$token|" ${YML}; \
	fi; \
	if grep -q -E "^[[:space:]]*TELEGRAM_CHAT_ID:[[:space:]]*$$" ${YML}; then \
		echo "📩 TELEGRAM_CHAT_ID is empty. Enter a value or press enter to skip:"; \
		read -r chat_id; \
		if [ -z "$$chat_id" ]; then chat_id=\"\"; else chat_id=\"$$chat_id\"; fi; \
		sed -i "s|^\([[:space:]]*TELEGRAM_CHAT_ID:\)[[:space:]]*$$|\1 $$chat_id|" ${YML}; \
	fi; \
	echo "✅ docker-compose.yml updated."; \
	docker compose -f ${YML} up -d; \
	'

down:
	docker compose -f ${YML} down

clean:
	docker rmi samuelrb/speedtest-monitor:latest -f

fclean:
	@${MAKE} down && ${MAKE} clean

re: fclean all

PHONY: all down clean fclean re
