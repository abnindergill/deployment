FROM maven as build

COPY pom.xml /build/
COPY src /build/src/

WORKDIR /build/
RUN mvn clean install

