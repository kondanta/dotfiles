function go_tools_update
    go install github.com/home-operations/yayamlls/cmd/yayamlls@latest
    go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest
    go install golang.org/x/tools/cmd/goimports@latest
    go install golang.org/x/tools/cmd/gofumpt@latest
    go install golang.org/x/tools/gopls@latest
end
