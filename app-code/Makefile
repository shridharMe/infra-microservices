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
	@ docker build -t ${DOCKER_REPO_URL}/${APP_NAME} ${APP_NAME}/.

docker-tag:
	@ docker tag ${DOCKER_REPO_URL}/${APP_NAME}:${TAG} ${DOCKER_REPO_URL}/${APP_NAME}:${TAG}

docker-push:
	@ docker push ${DOCKER_REPO_URL}/${APP_NAME}:${TAG}

docker-scanning:
	@  echo "docker scanning"

 run-docker-compose:
	@ /usr/local/bin/docker-compose -f docker-compose.yml up -d --force-recreate

owsap-testing:
	@  echo "owasp testing"