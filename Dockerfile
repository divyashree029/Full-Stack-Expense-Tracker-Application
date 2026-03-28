# Stage 1: Build stage (use official Maven image for reliable builds)
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /build

# Copy pom.xml and source code
COPY pom.xml ./
COPY src ./src

# Download dependencies and build
RUN mvn -B clean package -DskipTests

# Stage 2: Runtime stage
FROM eclipse-temurin:17-jre-jammy

# Set working directory
WORKDIR /app

# Copy the built JAR from the builder stage
COPY --from=builder /build/target/finance-manager-1.0.0.jar app.jar

# Expose port 8080
EXPOSE 8080

# Runtime options
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]
