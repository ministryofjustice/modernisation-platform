#!/bin/sh
echo "{\"branch\": \"$(git rev-parse --abbrev-ref HEAD)\"}"