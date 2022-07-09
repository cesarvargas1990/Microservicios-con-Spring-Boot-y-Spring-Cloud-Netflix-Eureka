echo "springboot-servicio-config-server..."
cd springboot-servicio-config-server
chmod +x mvnw
./mvnw clean package 
./Users/mac/Documents/Documentos Cesar/Supergiros/workspace/springboot-servicio-config-server/mvnw install:install-file -Dfile=/Users/mac/Documents/Documentos Cesar/Supergiros/workspace/springboot-servicio-config-server/target/springboot-servicio-config-server-0.0.1-SNAPSHOT.jar
docker build -t config-server:v1 .
docker network create springcloud
docker run -p 8080:8080 --name config-server --network springcloud config-server:v1 &
cd ..


echo "springboot-servicio-eureka-server..."
cd springboot-servicio-eureka-server
chmod +x mvnw
./mvnw clean package
docker build -t servicio-eureka-server:v1 .
docker run -p 8761:8761 --name servicio-eureka-server --network springcloud servicio-eureka-server:v1 &
cd ..

echo "mysql..."
docker pull mysql:8
docker run -p 3306:3306 --name microservicios-mysql8 --network springcloud -e MYSQL_ROOT_PASSWORD=sasa -e MYSQL_DATABASE=db_springboot_cloud -d mysql:8 &
docker logs -f microservicios-mysql8 &

echo "postgresql..."
docker pull postgres:12-alpine
docker run -p 5432:5432 --name microservicios-postgres12 --network springcloud -e POSTGRES_PASSWORD=sasa -e POSTGRES_DB=db_springboot_cloud -d postgres:12-alpine &
docker logs -f microservicios-postgres12 &


echo "springboot-servicio-productos..."
cd springboot-servicio-productos
chmod +x mvnw
./mvnw clean package -DskipTests
docker build -t servicio-productos:v1 .
docker run -P --network springcloud servicio-productos:v1 &
cd ..

echo "springboot-servicio-zuul-server..."
cd springboot-servicio-zuul-server
chmod +x mvnw
./mvnw clean package -DskipTests
docker build -t servicio-zuul-server:v1 .
docker run -p 8090:8090 --network springcloud servicio-zuul-server:v1 &
cd ..


echo "springboot-servicio-usuarios..."
cd springboot-servicio-usuarios
chmod +x mvnw
./mvnw clean package -DskipTests
docker build -t servicio-usuarios:v1 .
docker run -P --network springcloud servicio-usuarios:v1 &
cd ..


echo "springboot-servicio-oauth..."
cd springboot-servicio-oauth
chmod +x mvnw
./mvnw clean package -DskipTests
docker build -t servicio-oauth:v1 .
docker run -p 9100:9100 --network springcloud servicio-oauth:v1 &
cd ..

echo "springboot-servicio-item..."
cd springboot-servicio-item
chmod +x mvnw
./mvnw clean package -DskipTests
docker build -t servicio-items:v1 .
docker run -p 8002:8002 -p 8005:8005 -p 8007:8007 --network springcloud servicio-items:v1 &
cd ..

echo "rabbitmq:3.8-management-alpine..."
docker pull rabbitmq:3.8-management-alpine
docker run -p 15672:15672 -p 5672:5672 --name microservicios-rabbitmq38 --network springcloud -d rabbitmq:3.8-management-alpine &
docker logs -f microservicios-rabbitmq38 &

echo "zipkin-server:v1..."
docker build -t zipkin-server:v1 .
docker run -p 9411:9411 --name zipkin-server --network springcloud -e RABBIT_ADDRESSES=microservicios-rabbitmq38:5672 -e STORAGE_TYPE=mysql -e MYSQL_USER=zipkin -e MYSQL_PASS=zipkin -e MYSQL_HOST=microservicios-mysql8 zipkin-server:v1 &
docker logs -f zipkin-server &
