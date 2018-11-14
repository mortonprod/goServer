# Introduction 

This repository will deploy a go app to google cloud. It should work for any simple go app. 

## Custom

The app included is an introduction to me. Forever a self promoter. 

Remember to change accounts:

```
export AWS_PROFILE=personal
```

# To build go app

```
go build -o ./dist/main  ./src/main.go
```


# Notes

Google does not support go serverless. 
Terraform far too complicated a setup
Serverless setup failed.

# To do 

export GOPATH=$HOME
export GOBIN=$GOPATH/bin

# Reference 

https://github.com/snsinfu/terraform-lambda-example