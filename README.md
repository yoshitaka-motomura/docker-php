# Docker php8.2 FPM from alpine
[![Dockles](https://github.com/yoshitaka-motomura/docker-php-image/actions/workflows/dockle.yml/badge.svg?branch=main)](https://github.com/yoshitaka-motomura/docker-php-image/actions/workflows/dockle.yml)
## Overview

docker php8.2-fpm image.
This image is for Laravel 10. The installed extensions are listed below.

docker image
```
docker pull staydaybreak/php:8.2.8-fpm-alpine
```

##　Build

```
export DOCKER_CONTENT_TRUST=1
make build
```

- https://github.com/goodwithtech/dockle/blob/master/CHECKPOINT.md
