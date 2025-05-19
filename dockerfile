# Étape 1 : utiliser une image de base Java 17
FROM eclipse-temurin:17-jdk-alpine

# Copier le jar compilé dans le conteneur
COPY target/hello-spring-boot-0.0.1-SNAPSHOT.jar app.jar

# Exposer le port 8080 (ou un autre port si tu veux)
EXPOSE 8080

# Commande pour lancer l'application
ENTRYPOINT ["java","-jar","/app.jar"]
