# How many images are in 
docker image ls 

# What is the size of the ubuntu image
docker image ls # size column 

# what is the tag on the newly pulled nginx image?
docker image ls # tag column

# what is the image use in Dockerfile
cat Dockerfile # FROM field

# To what locaiton the container is the application copied to
cat Dockerfile # COPY <from> <to>

# What is the command to run the application
cat Dockerfile # ENTRYPOINT ["python", "app.py"]. Can also be CMD command 

# What port is the web application run within the container
cat Dockerfile # EXPOSE 8080

# Build a docker image using the Dockerfile and name it webapp-color. No tag to be specified.
docker build . -t webapp-color

# Run an instance of the image webapp-color and publish port 8080 on the container to 8282 on the host.
docker container run -p 8282:8080 -d webapp-color

# What is the base Operating System used by the python:3.6 image?
docker run python:3.6 cat /etc/*release

# What is the approximate size of webapp-color image
docker image inspect webapp-color # Size field, 912 MB!!

# Build a new smaller docker image by modifying the same Dockerfile and name it webapp-color and tag it lite.
# go here to check : https://hub.docker.com/_/python/tags?page=1&name=3.6 . Found 3.6-slim tag 
vim Dockerfile # change base image to 3.6-slim
docker build . --tage webapp-color:alpine
docker image inspect webapp-color:alpine # got 52 MB

# Run an instance of the new image webapp-color:lite and publish port 8080 on the container to 8383 on the host.
docker container run -p 8383:8080 -d  webapp-color:lite
