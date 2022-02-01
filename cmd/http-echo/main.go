package main

import (
	"bytes"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	server := http.NewServeMux()
	server.HandleFunc("/", handler)

	log.Printf("Server listening on port %s", port)
	err := http.ListenAndServe(":"+port, server)
	if err != nil {
		panic(err)
	}
}

func handler(resp http.ResponseWriter, req *http.Request) {
	log.Printf("serving %s | %s %s\n", req.RemoteAddr, req.Method, req.URL)

	if os.Getenv("LOG_HTTP_HEADERS") != "" {
		for k, v := range req.Header {
			log.Printf("header %q : %q\n", k, v)
		}
	}

	resp.Header().Add("Content-Type", "text/plain")
	resp.WriteHeader(200)
	echoHTTP(resp, req)
}

func echoHTTP(resp http.ResponseWriter, req *http.Request) {

	fmt.Fprintf(resp, "%s %s %s\n", req.Proto, req.Method, req.URL)
	fmt.Fprintln(resp, "")

	fmt.Fprintf(resp, "Host: %s\n", req.Host)
	for key, values := range req.Header {
		for _, value := range values {
			fmt.Fprintf(resp, "%s: %s\n", key, value)
		}
	}

	var body bytes.Buffer
	io.Copy(&body, req.Body)

	if body.Len() > 0 {
		fmt.Fprintln(resp, "")
		body.WriteTo(resp)
	}
}
