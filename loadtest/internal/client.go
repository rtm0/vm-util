package internal

import (
	"bytes"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"net/url"
	"time"
)

// Client is a HTTP client that sends queries to vmselect.
type Client struct {
	logger        *slog.Logger
	httpCli       *http.Client
	queryRangeURL string
}

type ClientOptions struct {
	MaxConns      int
	QueryRangeURL string
}

// NewClient creates a new VM client.
func NewClient(logger *slog.Logger, opts ClientOptions) *Client {
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
		queryRangeURL: opts.QueryRangeURL,
	}
}

// Query executes a select query over a given range.
func (c *Client) QueryRange(query string, start time.Time) {
	startSecs := fmt.Sprintf("%d", start.Unix())
	res, err := c.httpCli.PostForm(c.queryRangeURL, url.Values{
		"query": {query},
		"start": {startSecs},
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
