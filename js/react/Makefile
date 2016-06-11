.PHONY: all clean

SRC=js/src
BIN=js/bin

all:  ${BIN}/main.js ${BIN}/lib.js


clean:
	rm -rf ${BIN} node_modules/

${BIN}/main.js: ${SRC}/main.js
	./node_modules/.bin/babel ${SRC}/main.js -o ${BIN}/main.js

${BIN}/lib.js: package.json
	cat ./node_modules/react/dist/react.js > ${BIN}/lib.js
	cat ./node_modules/react-dom/dist/react-dom.js >> ${BIN}/lib.js
	cat ./node_modules/underscore/underscore.js >> ${BIN}/lib.js
