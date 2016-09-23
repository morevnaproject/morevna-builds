#!/bin/bash

docker stop "builder" || true
docker rm "builder" || true
