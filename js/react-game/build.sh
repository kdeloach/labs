#!/bin/bash
node_modules/.bin/browserify -t reactify src/main.js > bin/main.js
