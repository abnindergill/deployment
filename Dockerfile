FROM maven:3.5.2-jdk-8-alpine AS MAVEN_BUILD

COPY pom.xml /build/
COPY src /build/src/
WORKDIR /build/
RUN mvn install

FROM openjdk:8-jre-alpine
WORKDIR /app

COPY --from=MAVEN_BUILD /build/target/api/hello-world.jar /app/
COPY --from=MAVEN_BUILD /build/target/api/application.yml /app/
ENTRYPOINT ["java", "-jar", "-DServer.port=8085", "hello-world.jar"]
