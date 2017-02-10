all: build

build:
	mkdir -p dist
	lsc -b -o dist/ -c src/server-stats-mqtt.ls

run: build
	node dist/server-stats-mqtt.js

clean:
	rm -rf dist

