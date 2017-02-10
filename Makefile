all:
	mkdir -p dist
	lsc -b -o dist/ -c src/server-stats-mqtt.ls

clean:
	rm -rf dist

