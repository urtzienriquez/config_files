-- nvim/lsp/yamlls.lua
-- YAML language server configuration (including Quarto frontmatter)

return {
	cmd = { 'yaml-language-server', '--stdio' },
	filetypes = { 'yaml', 'yaml.docker-compose', 'yaml.gitlab' },
	root_markers = { '.git' },
	settings = {
		yaml = {
			schemas = {
				-- Kubernetes schemas
				['https://json.schemastore.org/kustomization.json'] = 'kustomization.{yml,yaml}',
				['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = 'docker-compose*.{yml,yaml}',
				-- GitHub workflows
				['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*',
				-- Quarto schema for _quarto.yml files
				['https://json.schemastore.org/quarto.json'] = '*.{yml,yaml}',
			},
			format = {
				enable = true,
			},
			validate = true,
			completion = true,
			hover = true,
		},
	},
}
