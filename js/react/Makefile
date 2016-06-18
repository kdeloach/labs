.PHONY: all clean watch

SRC=js/src
BIN=js/bin
BUNDLE=./node_modules/.bin/babel ${SRC}/main.js -o ${BIN}/main.js

all:  ${BIN}/main.js ${BIN}/lib.js


clean:
	rm -rf ${BIN}

watch:
	${BUNDLE} --watch

${BIN}/main.js: ${BIN} ${SRC}/main.js
	${BUNDLE}

${BIN}/lib.js: ${BIN} package.json
	cat ./node_modules/react/dist/react.js > ${BIN}/lib.js
	cat ./node_modules/react-dom/dist/react-dom.js >> ${BIN}/lib.js
	cat ./node_modules/underscore/underscore.js >> ${BIN}/lib.js

${BIN}:
	mkdir -p ${BIN}
