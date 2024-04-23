docker build --no-cache --rm -f Containerfile -t gatling:demo .
docker run --interactive --tty -p 8000:8000 gatling:demo
echo "browse http://localhost:8000/"
