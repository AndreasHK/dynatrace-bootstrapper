package main

import (
	"fmt"
	"net/http"
	"os"

	bootstrapper "github.com/Dynatrace/dynatrace-bootstrapper/cmd"
)

func ready(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Ready")
}

func deploy(w http.ResponseWriter, r *http.Request) {
	err := bootstrapper.New().Execute()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
	fmt.Fprintf(w, "Deployed")
}

func main() {
	err := bootstrapper.New().Execute()
	if err != nil {
		os.Exit(1)
	}

	http.HandleFunc("/v1/ready", ready)
	http.HandleFunc("/v1/deploy", deploy)
	err = http.ListenAndServe(":8081", nil)
	if err != nil {
		os.Exit(2)
	}
}
