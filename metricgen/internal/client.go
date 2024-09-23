package internal

import (
	"bytes"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"
)

// Client is a HTTP client that inserts data into and selects data from the vmstorage.
type Client struct {
	logger        *slog.Logger
	httpCli       *http.Client
	writeURL      string
	queryRangeURL string
}

type ClientOptions struct {
	MaxConns      int
	WriteURL      string
	QueryRangeURL string
}

// NewClient creates a new VM client.
func NewClient(logger *slog.Logger, opts *ClientOptions) *Client {
	return &Client{
		logger: logger,
		httpCli: &http.Client{
			Transport: &http.Transport{
				DialContext: (&net.Dialer{
					Timeout:   30 * time.Second,
					KeepAlive: 30 * time.Second,
				}).DialContext,
				MaxIdleConns:        opts.MaxConns,
				IdleConnTimeout:     30 * time.Second,
				MaxIdleConnsPerHost: opts.MaxConns,
				MaxConnsPerHost:     opts.MaxConns,
			},
		},
		writeURL: opts.WriteURL,
		// queryRangeURL: fmt.Sprintf("http://%s/prometheus/api/v1/query_range", addr),
		queryRangeURL: opts.QueryRangeURL, // fmt.Sprintf("http://%s/select/0/prometheus/api/v1/query_range", addr),
	}
}

// Write writes data into vmstorage.
func (c *Client) Write(data string) {
	res, err := c.httpCli.Post(c.writeURL, "text/plain", strings.NewReader(data))
	if err != nil {
		c.logger.Error("failed to post data", "err", err)
		return
	}

	body := c.readAllAndClose(res.Body)

	if got, want := res.StatusCode, http.StatusNoContent; got != want {
		c.logger.Error("unexpected status code", "got", got, "want", want, "body", body)
	}
}

// Query executes a select query over a given range.
func (c *Client) QueryRange(query, start, step string) {
	res, err := c.httpCli.PostForm(c.queryRangeURL, url.Values{
		"query": {query},
		"start": {start},
		"step":  {step},
	})
	if err != nil {
		c.logger.Error("failed to post form", "err", err)
		return
	}

	body := c.readAllAndClose(res.Body)

	if got, want := res.StatusCode, http.StatusOK; got != want {
		c.logger.Error("unexpected status code", "got", got, "want", want, "body", body)
	}
}

func (c *Client) readAllAndClose(body io.ReadCloser) string {
	defer body.Close()
	b, err := io.ReadAll(body)
	if err != nil {
		c.logger.Error("failed to read response body", "err", err)
	}
	b = bytes.TrimSpace(b)
	return string(b)
}
