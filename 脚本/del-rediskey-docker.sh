#!/bin/bash

# Get the container name from docker ps command
container_name=$(docker ps --format "{{.Names}}" --filter "name=redis")

# Check if container_name is empty
if [ -z "$container_name" ]; then
  echo "Error: No running Redis container found."
  exit 1
fi

# Redis CLI Command
redis_cli="docker exec -it $container_name redis-cli -a SSY@redis$"

# Execute config set stop-writes-on-bgsave-error no
$redis_cli config set stop-writes-on-bgsave-error no

# Delete Commands
keys=(
  "formative:prize:531"
  "formative:prize:532"
  "formative:prize:642"
  "formative:prize:652"
  "formative:prize:644"
  "formative:prize:683"
  "formative:prize:688"
  "formative:prize:682"
)

# Loop through keys and execute unlink command
for key in "${keys[@]}"
do
  $redis_cli unlink "$key"
done

# Execute config set stop-writes-on-bgsave-error yes
$redis_cli config set stop-writes-on-bgsave-error yes