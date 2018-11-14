.PHONY: test clean

test: deploy.done
	curl -fsSL -D - "$$(terraform output url)?name=Lambda"

clean:
	terraform destroy
	rm -f init.done deploy.done goServer.zip goServer

init.done:
	terraform init
	touch $@

deploy.done: init.done main.tf goServer.zip
	terraform apply
	touch $@

goServer.zip: goServer
	zip $@ $<

goServer: goServer.go
	go get .
GOOS=linux GOARCH=amd64 go build -o $@