#!/usr/bin/env bash
./a.out 4 5 6
if [ "$?" == "0" ]; then
    exit 1;
else
    exit 0;
fi
