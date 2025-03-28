# Log Catcher

If in the real-world there's a dream catcher. Then, in the software-world there's a log catcher.

## About

This is an example of PoC (Proof of Concept) of how to run queue and catch the logs from queue in Laravel web app in container by implement S6 Overlay. I'm using [serversideup/docker-php](https://github.com/serversideup/docker-php) Docker's image.

> NOTE: The implementation is on `etc/s6-overlay` directory + Dockerfile.

```sh
docker build -t senkulabs/logcatcher .
# By default, the Docker image from serversideup PHP expose port 8080.
docker run --rm -p "8080:8080" senkulabs/logcatcher:latest
```

Access `http://localhost:8080/hello-job` then see the logs.

## References

- [What's S6 Overlay?](https://serversideup.net/open-source/docker-php/docs/guide/using-s6-overlay)
- [Multiprocess Containers with S6 Overlay](https://www.tonysm.com/multiprocess-containers-with-s6-overlay/)
- [jhonoryza/serversideup-laravel](https://github.com/jhonoryza/serversideup-laravel)
- [Laravel Queue with Docker](https://serversideup.net/open-source/docker-php/docs/laravel/laravel-queue)
