package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"time"
)

type Environment struct {
	AccountType string `json:"account-type"`
	GoLiveDate  string `json:"go-live-date"`
}

func main() {
	dir := "../../../environments/"

	// Read the files in the directory
	files, err := ioutil.ReadDir(dir)
	if err != nil {
		fmt.Println("Error reading directory:", err)
		os.Exit(1)
	}

	// Variables to store the results
	memberFiles := []string{}
	memberUnrestrictedFiles := []string{}
	coreFiles := []string{}
	futureGoLiveFiles := []string{}
	pastGoLiveFiles := []string{}

	// Get today's date
	today := time.Now().Truncate(24 * time.Hour)

	// Process each JSON file
	for _, file := range files {
		// Check if the file is a JSON file
		if !strings.HasSuffix(file.Name(), ".json") {
			continue
		}

		// Read the JSON file
		filePath := fmt.Sprintf("%s%s", dir, file.Name())
		jsonData, err := ioutil.ReadFile(filePath)
		if err != nil {
			log.Println(err)
			continue
		}

		// Parse the JSON data into an Environment struct
		var env Environment
		err = json.Unmarshal(jsonData, &env)
		if err != nil {
			log.Println(err)
			continue
		}

		application_name := strings.TrimSuffix(file.Name(), ".json")
		// check if an mp account
		mpOwned := false
		if application_name == "example" || application_name == "sprinkler" || application_name == "cooker" || application_name == "testing" {
			mpOwned = true
		}

		// Check the account type
		if env.AccountType == "member" && mpOwned == false {
			memberFiles = append(memberFiles, application_name)
		}

		if env.AccountType == "member-unrestricted" && mpOwned == false {
			memberUnrestrictedFiles = append(memberUnrestrictedFiles, application_name)
		}

		if env.AccountType == "core" || mpOwned == true {
			coreFiles = append(coreFiles, application_name)
		}

		if env.GoLiveDate != "" {
			parsedDate, err := time.Parse("2006-01-02", env.GoLiveDate)
			if err != nil {
				log.Println(err)
				continue
			}
			// Check the go-live date
			if parsedDate.After(today) && env.AccountType == "member" {
				futureGoLiveFiles = append(futureGoLiveFiles, env.GoLiveDate+" "+application_name)
			} else if parsedDate.Before(today) && env.AccountType == "member" {
				pastGoLiveFiles = append(pastGoLiveFiles, env.GoLiveDate+" "+application_name)
			}
		}

	}

	// Output the results
	fmt.Printf("Member applications (%d):\n", len(memberFiles))
	for _, file := range memberFiles {
		fmt.Println(file)
	}

	fmt.Printf("\nMember-unrestricted applications (%d):\n", len(memberFiles))
	for _, file := range memberUnrestrictedFiles {
		fmt.Println(file)
	}

	fmt.Printf("\nMP controlled applications (%d):\n", len(memberFiles))
	for _, file := range coreFiles {
		fmt.Println(file)
	}

	fmt.Printf("\nUpcoming migrations (%d):\n", len(futureGoLiveFiles))
	for _, file := range futureGoLiveFiles {
		fmt.Println(file)
	}

	fmt.Printf("\nLive in production applications (%d):\n", len(pastGoLiveFiles))
	for _, file := range pastGoLiveFiles {
		fmt.Println(file)
	}
}
