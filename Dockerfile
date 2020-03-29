FROM maven as build

RUN mvn clean install

