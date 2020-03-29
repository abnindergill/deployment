FROM openjdk:8-jre-alpine

EXPOSE 8085
WORKDIR /app
COPY --from=MAVEN_BUILD /build/target/api/hello-world.jar /app/

CMD ["java", "-jar", "-DServer.port=8085","hello-world.jar"]