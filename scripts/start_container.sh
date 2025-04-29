#!/bin/bash
set -e

# Pull the Docker image from Docker Hub
docker pull amarbvn/amarbvn-cicd-proj

# Run the Docker image as a container
docker run -d -p 5000:8000 amarbvn/amarbvn-cicd-proj