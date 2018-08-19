FROM clojure:latest
LABEL maintainer="Shridhar Patil @shridhar_patil"

ENV APP_PORT=8001
EXPOSE 8001
ADD ../build/quotes.jar /quotes.jar

CMD ["/opt/jdk/bin/java", "-jar", "/quotes.jar"]