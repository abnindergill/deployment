FROM openjdk:8-jdk-alpine
ENV LISTEN_PORT=8082

RUN mkdir -p /src/main/app

COPY target/api/hello-world.jar /src/main/app
COPY target/api/application.yml /src/main/app

ENTRYPOINT ["java","-DServer.port=${LISTEN_PORT}", "-jar", "/src/main/app/hello-world.jar"]
