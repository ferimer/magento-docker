#!/bin/bash

/usr/local/bin/php bin/magento cron:run
/usr/local/bin/php update/cron.php
/usr/local/bin/php bin/magento setup:cron:run

