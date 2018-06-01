#!/usr/bin/env bash
if [ "$(./a.out 4 5)" == "9" ]; then
    exit 0;
else
    exit 1;
fi
