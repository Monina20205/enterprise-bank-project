# Stage 1: Build
# Usamos una imagen de Maven estable
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Runtime
# Usamos Eclipse Temurin JRE (muy ligera y segura)
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
ENV APP_ENV="dev"
ENTRYPOINT ["java", "-jar", "app.jar"]
