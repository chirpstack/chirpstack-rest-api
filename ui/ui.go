package ui

import "embed"

// FS contains the static FS.
//go:embed *.json *.png *.css *.html *.js *.map
var FS embed.FS
