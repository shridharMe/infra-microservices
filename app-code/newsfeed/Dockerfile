FROM clojure:latest
LABEL maintainer="Shridhar Patil @shridhar_patil"

ENV APP_PORT=8002
EXPOSE 8002
COPY build/newsfeed.jar /newsfeed.jar
CMD ["/usr/bin/java", "-jar", "/newsfeed.jar"]