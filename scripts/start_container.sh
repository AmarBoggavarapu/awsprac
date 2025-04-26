#!/bin/bash
set -e

# Pull the Docker image from Docker Hub
docker pull amarbvn/awsprac-ci-proj-app

# Run the Docker image as a container
docker run -d -p 5000:5000 amarbvn/awsprac-ci-proj-app
