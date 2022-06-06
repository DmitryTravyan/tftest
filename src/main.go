package main

import (
	"fmt"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/gohcl"
	"github.com/hashicorp/hcl/v2/hclparse"
)

type Main struct {
	Terraform TerraformBlock `hcl:"terraform,block"`
    Data Data `hcl:"data,block"`
}

type TerraformBlock struct {
	RequiredProviders RequiredProviders `hcl:"required_providers,block"`
}

type RequiredProviders struct {
	Yandex hcl.Expression `hcl:"yandex"`
}

// TODO
type Yandex struct {
	Source string `hcl:"source,attr"`
}

type Data struct {
    BlockType string `hcl:"type,label"`
    BlockName string `hcl:"name,label"`
    Name string `hcl:"name"`
}

func main() {
    var main Main

	parser := hclparse.NewParser()
	file, err := parser.ParseHCLFile("simple.tf")
	if err != nil {
		fmt.Println(err)
	}

    if err = gohcl.DecodeBody(file.Body, nil, &main); err != nil {
        fmt.Println(err)
    }
    fmt.Printf("%T",main)
}
