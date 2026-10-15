### =========================================================
### Build stage
### =========================================================
##FROM maven:3.9.9-eclipse-temurin-21 AS builder
##
##WORKDIR /app
##
### Copy Maven configuration first for dependency caching
##COPY pom.xml .
##
##RUN mvn dependency:go-offline -B
##
### Copy source
##COPY src ./src
##
### Build application
##RUN mvn clean package -DskipTests
##
##
### =========================================================
### Runtime stage
### =========================================================
##FROM eclipse-temurin:21-jre
##
##WORKDIR /app
##
### Create non-root user
##RUN useradd --system --create-home --uid 1001 springuser
##
### Copy generated JAR
##COPY --from=builder /app/target/*.jar app.jar
##
### Give application ownership to non-root user
##RUN chown springuser:springuser /app/app.jar
##
##USER springuser
##
### Render supplies PORT dynamically
##EXPOSE 8080
##
### Start Spring Boot
##ENTRYPOINT ["java", "-jar", "app.jar"]
#
#```dockerfile
## =========================================================
## BUILD STAGE
## =========================================================
#FROM maven:3.9.9-eclipse-temurin-21 AS builder
#
#WORKDIR /app
#
## Copy Maven configuration first
## This allows Docker to cache dependencies
#COPY pom.xml .
#
#RUN mvn dependency:go-offline -B
#
## Copy application source
#COPY src ./src
#
## Build the Spring Boot application
#RUN mvn clean package -DskipTests
#
#
## =========================================================
## RUNTIME STAGE
## =========================================================
#FROM eclipse-temurin:21-jre
#
#WORKDIR /app
#
## Create a non-root application user
#RUN useradd --system --create-home --uid 1001 springuser
#
## Copy the generated Spring Boot JAR
#COPY --from=builder /app/target/*.jar app.jar
#
## Give ownership to the application user
#RUN chown springuser:springuser /app/app.jar
#
#USER springuser
#
## Render supplies the actual PORT environment variable
#EXPOSE 8080
#
## Start Spring Boot
#ENTRYPOINT ["java", "-jar", "app.jar"]
#```

# Build stage
FROM maven:3.9.9-eclipse-temurin-21 AS builder

WORKDIR /app

# Copy Maven configuration first
COPY pom.xml .

# Download dependencies
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Build the application
RUN mvn clean package -DskipTests


# Runtime stage
FROM eclipse-temurin:21-jre

WORKDIR /app

# Create non-root user
RUN useradd --system --create-home --uid 1001 springuser

# Copy Spring Boot JAR
COPY --from=builder /app/target/*.jar app.jar

# Set ownership
RUN chown springuser:springuser /app/app.jar

# Run application as non-root user
USER springuser

# Render provides PORT
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]