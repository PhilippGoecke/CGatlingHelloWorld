podman build --no-cache --rm --file Containerfile --tag gatling:demo .
podman run --interactive --tty --publish 8000:8000 gatling:demo
echo "browse http://localhost:8000/"
