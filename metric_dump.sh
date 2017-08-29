#!/bin/bash
while true; do
  curl -s http://130.211.160.177:9990/admin/metrics.json > l5d_metrics_`date -u +'%s'`.json
  sleep 60;
done
