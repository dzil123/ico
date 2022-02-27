#!/bin/bash

rm -fdr build/web/*
mkdir -v -p build/web
(cd ico; godot -v --no-window --export "HTML5" ../build/web/index.html)
