FROM openjdk:8-jdk-alpine
ARG JAR_FILE=target/api/hello-world.jar
ARG YML_FILE=target/api/application.yml
ENV LISTEN_PORT=8082

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY ${JAR_FILE} hello-world.jar
COPY ${YML_FILE} application.yml
ENTRYPOINT ["java","-DServer.port=${LISTEN_PORT}", "-jar", "/hello-world.jar"]
