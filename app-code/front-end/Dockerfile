FROM clojure:latest
LABEL maintainer="Shridhar Patil @shridhar_patil"

ENV APP_PORT=8080
ENV STATIC_URL=http://localhost:8000
ENV QUOTE_SERVICE_URL=http://quotes:8001
ENV NEWSFEED_SERVICE_URL=http://newsfeed:8002
ENV NEWSFEED_SERVICE_TOKEN=T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX
EXPOSE 8080
COPY build/front-end.jar /front-end.jar
RUN which java
CMD ["/usr/bin/java", "-jar", "/front-end.jar"]