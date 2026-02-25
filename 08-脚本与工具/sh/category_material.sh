#!/bin/bash

profile=uat
mainClass=product.CategoryMaterial
dir=/usr/local/stream

/usr/local/flink-1.14.3/bin/flink run -d -c ${mainClass} -p 1 ${dir}/shushangyun-stream-2.0.0.jar --profile=${profile}
