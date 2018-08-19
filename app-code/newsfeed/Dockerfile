FROM clojure:latest
LABEL maintainer="Shridhar Patil @shridhar_patil"

ENV APP_PORT=8002
EXPOSE 8002
ADD ./build/newsfeed.jar /newsfeed.jar
CMD ["/opt/jdk/bin/java", "-jar", "/newsfeed.jar"]