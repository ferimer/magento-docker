# Magento 2.1 docker image

Docker image with all required dependencies for Magento 2.1

## Build and publish image

```
docker build -t ferimer/magento:2.1 .
docker push ferimer/magento:2.1
```

## Setup (first time)

There is a copy of the CE of Magento 2.1 in /opt, if you mount a new volumne, you should copy the data

```
docker run --rm -v data_folder:/var/www/html ferimer/magento:2.1 /opt/setup.sh
```

## Run

```
docker run -d --name my-magento-shop -v data_folder:/var/www/html -p 8080:80 ferimer/magento:2.1
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
