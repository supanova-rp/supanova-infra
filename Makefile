up:
	docker pull jdgarner/supanova-server:latest && \
	docker pull jdgarner/supanova-maintenance:latest && \
	cd docker && \
	docker-compose up -d

down:
	cd docker && docker-compose down
