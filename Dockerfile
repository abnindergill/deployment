FROM maven:3.5.2-jdk-8-alpine AS MAVEN_BUILD

EXPOSE 8085
WORKDIR /app
COPY --from=MAVEN_BUILD /build/target/api/hello-world.jar /app/

CMD ["java", "-jar", "-DServer.port=8085","hello-world.jar"]