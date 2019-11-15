DEV_IMAGE=trotttrotttrott.github.com

docker-build:
	docker build -f _dev/Dockerfile -t ${DEV_IMAGE} _dev/

shotgun:
	docker run --rm \
		-v "${PWD}/_dev:/root/app" \
		-v "${PWD}/fonts:/root/app/fonts" \
		-v "${PWD}/images:/root/app/images" \
		-v "${PWD}/stylesheets:/root/app/stylesheets" \
		-p 9393:9393 ${DEV_IMAGE}
