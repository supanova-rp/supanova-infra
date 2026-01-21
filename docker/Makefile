up:
	docker pull jdgarner/supanova-server:latest && \
	docker pull jdgarner/supanova-maintenance:latest && \
	docker-compose up -d

up-demo:
	docker pull jdgarner/supanova-server:latest && \
	docker pull jdgarner/supanova-maintenance:latest && \
	docker-compose -f docker-compose.yml -f docker-compose.demo.yml up -d

down:
	docker-compose down
