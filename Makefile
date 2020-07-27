bin/hamler:
	stack --local-bin-path=./bin install hamler

clean:
	rm bin/hamler

image: bin/hamler
	docker build -t ${tag} . --build-arg local_bin_path=./bin --build-arg HAMLER_REVISION=`./hamler_revision`
