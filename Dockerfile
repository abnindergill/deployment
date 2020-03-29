FROM maven as build

COPY ./src /app/
RUN mkdir /app/target/

WORKDIR /app/
RUN mvn clean install

