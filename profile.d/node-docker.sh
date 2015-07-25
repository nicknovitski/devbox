node-version() {
	x=`pwd`
	while [ "$x" != "/" ]; do
		if [ -f "$x/.node-version" ]; then
			cat "$x/.node-version"
			break
		fi
		x=`dirname "$x"`
	done
}

node-docker() {
	version=$(node-version | cut -b 2-)
	sudo docker run -it --rm \
		--workdir /var/local \
		-v $(host-pwd):/var/local \
		node:${version-latest} "$@"
}

node() {
	node-docker node "$@"
}

npm() {
	# TODO: somehow handle global installation
	node-docker npm "$@"
}
