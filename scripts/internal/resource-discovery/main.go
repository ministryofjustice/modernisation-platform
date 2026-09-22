package main

import "fmt"

var resourceType string = "rds"
var count int = 3

func main() {
	fmt.Println("Resource Discovery")
}

func formatMessage(resourceType string, count int) string {
	return fmt.Sprintf("Discovered %d resources of type %s", count, resourceType)
}