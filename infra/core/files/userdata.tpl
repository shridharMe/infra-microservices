#!/bin/bash

#!/bin/bash

echo '====================Removing older versions of Docker ======================='
 yum -y  remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine

echo '====================Install devicemapper storage driver dependencies ==========='
 yum install -y yum-utils curl device-mapper-persistent-data lvm2 unzip
 yum install -y wget vim


echo '====================Setup the stable docker repository.  ======================'
 yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo



echo '=========================== Installting Docker  ===========================' 
 yum -y install docker-ce
 systemctl start docker        
  

echo '=========================== Installing Docker Compose =========================='
 curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` > ./docker-compose
 mv ./docker-compose /usr/bin/
 chmod +x /usr/bin/docker-compose


 curl -L https://github.com/docker/machine/releases/download/v0.15.0/docker-machine-`uname -s`-`uname -m` > ./docker-machine 
echo '=========================== Installing Docker Machine =========================='
 mv ./docker-machine /usr/bin/
 chmod +x /usr/bin/docker-machine

echo '=========================== Creating Docker TLS certificates =================='
  docker-machine create default || true
 ls -lrt /root/.docker/machine/certs

echo '=========================== Creating Docker Network =========================='
if !  docker network create ${CUSTOM_NETWORK_NAME} &> /dev/null; then
      echo "Network already exists: ${CUSTOM_NETWORK_NAME}"
else
      echo "Created Docker network: ${CUSTOM_NETWORK_NAME}"
fi

echo '=========================== Checking the software installtion folder ========='
 ls -lrt /usr/bin/

 
echo '=========================== checking the version ========================'
 docker --version 
docker-compose --version
docker-machine --version
echo '=========================== END=========================================='

service docker restart

echo '=========================== Creating Docker Network =========================='
if !  docker network create ${CUSTOM_NETWORK_NAME} &> /dev/null; then
      echo "Network already exists: ${CUSTOM_NETWORK_NAME}"
else
      echo "Created Docker network: ${CUSTOM_NETWORK_NAME}"
fi
echo "==================== Checking all tools are installed==============="
  
docker --version  
docker-compose --version
echo "==================== End of Checking all tools are installed========"


cat > ./docker-compose.yaml <<-'EOF'
front-end:
  container_name: front-end
  image: shridharpatil01/front-end
  ports:
    - "80:8080"
  links:
    - quotes:quotes
    - newsfeed:newsfeed
  environment:
    APP_PORT: 8080
    STATIC_URL: http://localhost:8080
    QUOTE_SERVICE_URL: http://quotes:8001
    NEWSFEED_SERVICE_URL: http://newsfeed:8002
    NEWSFEED_SERVICE_TOKEN: T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX
  net: local_network
quotes:
  container_name: quotes
  image: shridharpatil01/quotes
  ports:
  - "8001:8001"
  net: local_network  
newsfeed:
  container_name: newsfeed
  image: shridharpatil01/newsfeed
  ports:
  - "8002:8002"
  net: local_network
EOF

 
/usr/local/bin/docker-compose -f ./docker-compose.yaml up -d