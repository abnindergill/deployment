FROM openjdk:8-jre-alpine
ENV LISTEN_PORT=8089
EXPOSE 8085

ENV dir="/src/main/app/new/"
ENV path=${dir}hello-world.jar

RUN mkdir -p ${dir}
COPY target/api/hello-world.jar ${dir}
COPY target/api/application.yml ${dir}
COPY target/api/app.sh ${dir}

WORKDIR ${dir}
CMD ["java", "-jar", "-DServer.port=8085","/src/main/app/new/hello-world.jar"]