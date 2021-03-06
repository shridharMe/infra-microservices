BUILD_DIR=build
APPS=front-end quotes newsfeed
LIBS=common-utils
STATIC_BASE=front-end/public
STATIC_PATHS=css
STATIC_ARCHIVE=$(BUILD_DIR)/static.tgz
INSTALL_TARGETS=$(addsuffix .install, $(LIBS))
APP_JARS=$(addprefix $(BUILD_DIR)/, $(addsuffix .jar, $(APPS)))

all: $(BUILD_DIR) $(APP_JARS) $(STATIC_ARCHIVE)

libs: $(INSTALL_TARGETS)

static: $(STATIC_ARCHIVE)

%.install:
	cd $* && lein install

test: $(addsuffix .test, $(LIBS) $(APPS))

%.test:
	cd $* && lein midje

clean:
	rm -rf $(BUILD_DIR) $(addsuffix /target, $(APPS))

$(APP_JARS): | $(BUILD_DIR)
	cd $(notdir $(@:.jar=)) && lein uberjar && cp target/uberjar/*-standalone.jar ../$@

$(STATIC_ARCHIVE): | $(BUILD_DIR)
	tar -c -C $(STATIC_BASE) -z -f $(STATIC_ARCHIVE) $(STATIC_PATHS)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

docker-build:
	@ docker build -t ${DOCKER_REPO_URL}/${APP_NAME} .

docker-tag:
	@ docker tag ${DOCKER_REPO_URL}/${APP_NAME}:${TAG} ${DOCKER_REPO_URL}/${APP_NAME}:${TAG}

docker-push:
	@ docker push ${DOCKER_REPO_URL}/${APP_NAME}:${TAG}

docker-scanning:
	@  echo "docker scanning"

docker-push:
	@ docker push ${DOCKER_REPO_URL}/${APP_NAME}:${TAG}

 run-docker-compose:
	@ docker network create local_network
	@ /usr/local/bin/docker-compose -f docker-compose.yml up -d --force-recreate

docker-login:
	@  docker login --username=${DOCKER_REPO_URL} --password=${DOCKER_REPO_PWD}

owsap-testing:
	@  echo "owasp testing"
	@ /usr/local/bin/docker-compose -f docker-compose.yml down

clean-up:    
	@ docker stop $(docker ps -qa)
	@ docker rm  $(docker ps -qa)
	@ docker system prune -f    
	@ docker  network rm local_network
