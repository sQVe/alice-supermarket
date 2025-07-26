.PHONY: help format lint format-scripts lint-scripts check setup-hooks find-shell-files

help:
	@echo "Available commands:"
	@echo "  format         - Format all GDScript files with gdformat"
	@echo "  lint           - Lint all GDScript files with gdlint"
	@echo "  format-scripts - Format all shell scripts with shfmt"
	@echo "  lint-scripts   - Lint all shell scripts with shellcheck"
	@echo "  check          - Run all formatting and linting checks"
	@echo "  setup-hooks    - Install git pre-commit hooks"
	@echo "  help           - Show this help message"

check-gdformat:
	@command -v gdformat >/dev/null 2>&1 || { \
		echo "❌ Error: gdformat not installed"; \
		echo "💡 Install with: pip install \"gdtoolkit==4.*\""; \
		echo "💡 See CONTRIBUTING.md for detailed installation instructions"; \
		exit 1; \
	}

check-gdlint:
	@command -v gdlint >/dev/null 2>&1 || { \
		echo "❌ Error: gdlint not installed"; \
		echo "💡 Install with: pip install \"gdtoolkit==4.*\""; \
		echo "💡 See CONTRIBUTING.md for detailed installation instructions"; \
		exit 1; \
	}

check-shfmt:
	@command -v shfmt >/dev/null 2>&1 || { \
		echo "❌ Error: shfmt not installed"; \
		echo "💡 Install with: go install mvdan.cc/sh/v3/cmd/shfmt@latest"; \
		echo "💡 Or via package manager (apt install shfmt, brew install shfmt, etc.)"; \
		exit 1; \
	}

check-shellcheck:
	@command -v shellcheck >/dev/null 2>&1 || { \
		echo "❌ Error: shellcheck not installed"; \
		echo "💡 Install with package manager (apt install shellcheck, brew install shellcheck, etc.)"; \
		exit 1; \
	}

format: check-gdformat
	@echo "🔧 Formatting all GDScript files..."
	@GD_FILES=$$(find . -name "*.gd" -type f ! -path "./.godot/*" 2>/dev/null); \
	if [ -n "$$GD_FILES" ]; then \
		echo "$$GD_FILES" | xargs gdformat; \
		echo "✅ GDScript formatting completed!"; \
	else \
		echo "⚠️  No GDScript files found - skipping formatting"; \
	fi

lint: check-gdlint
	@echo "🔍 Linting all GDScript files..."
	@GD_FILES=$$(find . -name "*.gd" -type f ! -path "./.godot/*" 2>/dev/null); \
	if [ -n "$$GD_FILES" ]; then \
		echo "$$GD_FILES" | xargs gdlint; \
		echo "✅ GDScript linting completed!"; \
	else \
		echo "⚠️  No GDScript files found - skipping linting"; \
	fi

# Helper to find shell files - used by both format-scripts and lint-scripts to avoid duplication
find-shell-files:
	@$(eval SHELL_FILES := $(shell find . -name "*.sh" -type f ! -path "./.godot/*" ! -path "./.git/*" 2>/dev/null || true))

format-scripts: check-shfmt find-shell-files
	@echo "🔧 Formatting shell scripts..."
	@if [ -n "$(SHELL_FILES)" ]; then \
		find . -name "*.sh" -type f ! -path "./.godot/*" ! -path "./.git/*" -exec shfmt -w -i 2 -bn -ci -sr {} \; && \
		echo "✅ Shell script formatting completed!"; \
	else \
		echo "⚠️  No shell scripts found - skipping shell script formatting"; \
	fi

lint-scripts: check-shellcheck find-shell-files
	@echo "🔍 Linting shell scripts..."
	@if [ -n "$(SHELL_FILES)" ]; then \
		find . -name "*.sh" -type f ! -path "./.godot/*" ! -path "./.git/*" -exec shellcheck --enable=require-variable-braces {} \; && \
		echo "✅ Shell script linting completed!"; \
	else \
		echo "⚠️  No shell scripts found - skipping shell script linting"; \
	fi

check: format lint format-scripts lint-scripts
	@echo "🎉 All code quality checks completed successfully!"

setup-hooks:
	@echo "⚙️  Installing git pre-commit hooks..."
	@HOOK_SCRIPT=$$(find . -name "pre-commit.sh" -type f ! -path "./.godot/*" ! -path "./.git/*" 2>/dev/null | head -1); \
	if [ -n "$$HOOK_SCRIPT" ]; then \
		cp "$$HOOK_SCRIPT" .git/hooks/pre-commit && \
		chmod +x .git/hooks/pre-commit && \
		echo "✅ Git hooks installed successfully!"; \
	else \
		echo "❌ Error: Pre-commit hook script (pre-commit.sh) not found"; \
		echo "💡 Ensure a pre-commit.sh script exists in your project"; \
		exit 1; \
	fi

