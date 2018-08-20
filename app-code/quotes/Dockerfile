FROM clojure:latest
LABEL maintainer="Shridhar Patil @shridhar_patil"

ENV APP_PORT=8001
EXPOSE 8001
COPY build/quotes.jar /quotes.jar

CMD ["/usr/bin/java", "-jar", "/quotes.jar"]