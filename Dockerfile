FROM abninder/test-image
ENV LISTEN_PORT=8089

ENV dir="/src/main/app/new/"
ENV path=${dir}hello-world.jar

RUN mkdir -p ${dir}
COPY target/api/hello-world.jar ${dir}
COPY target/api/application.yml ${dir}
COPY target/api/app.sh ${dir}

WORKDIR ${dir}
CMD place [./app.sh ${LISTEN_PORT} ${path}]