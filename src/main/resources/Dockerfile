FROM openjdk:8-jre-alpine

ENV TARGET_DIR="/build"
RUN mkdir -p ${TARGET_DIR}
ADD ../../target/api/application.yml ${TARGET_DIR}
ADD ../../target/api/hello-world.jar ${TARGET_DIR}

WORKDIR ${TARGET_DIR}
ENTRYPOINT ["java", "-jar", "-DServer.port=8085", "hello-world.jar"]

