## build
docker build . -t postarr:1.0 

## run
docker run -it --name postarr --env-file env.list postarr:1.0