# Magento 2.4 docker image

Docker image with all required dependencies for Magento 2.4

## Build and publish image

You need Magento Marketplace user and pass, see:

https://devdocs.magento.com/guides/v2.4/install-gde/prereq/connect-auth.html

```shell
docker build --build-arg MAGENTO_USER=<magentoUser> --build-arg MAGENTO_PASS=<magentoPass> -t ferimer/magento:2.4 .
docker push ferimer/magento:2.4
```

## Setup (first time)

Provision database

```shell
bin/magento setup:install --base-url=http://localhost --db-host=192.168.1.82 --db-name=<dbschema> --db-user=<dbuser> --db-password=<dbpass> --admin-firstname=admin --admin-lastname=admin --admin-email=admin@admin.com --admin-user=admin --admin-password=admin123 --language=es_ES --currency=EUR --timezone=Europe/Madrid --use-rewrites=1
```
If MariaDB version is more modern than Magento "supported" one:

```shell
sed -i '/MariaDB-(10.2-10.4)/a                 <item name="MariaDB-(10.5.9)" xsi:type="string">^10\.5\.</item>' app/etc/di.xml
```

## Run

```
docker run -d --name my-magento-shop -v data_folder:/var/www/html -p 8080:80 ferimer/magento:2.4
```











## Setup

Open a browser:

```
http://localhost:8080/setup
```

and follow all steps

## Periodic maintenance (cronjobs)

```
docker exec my-magento-shop /opt/cron.sh
docker exec my-magento-shop /opt/reindex.sh
```
