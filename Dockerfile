FROM eclipse-temurin:17-jre

WORKDIR /app

RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Download the latest release
RUN curl -L -o entralinked-release.zip \
  "https://github.com/kuroppoi/entralinked/releases/download/v1.4.1/entralinked.%2BPCN.Skins.zip" && \
  unzip -q entralinked-release.zip && \
  cp entralinked/entralinked.jar . && \
  rm -rf entralinked entralinked-release.zip

EXPOSE 80 443 29900 53/udp

CMD ["java", \
     "-Djdk.tls.server.protocols=TLSv1,TLSv1.1,TLSv1.2,TLSv1.3", \
     "-Dhttps.protocols=TLSv1,TLSv1.1,TLSv1.2,TLSv1.3", \
     "-Djdk.tls.disabledAlgorithms=", \
     "-jar", "/app/entralinked.jar", "disablegui"]
