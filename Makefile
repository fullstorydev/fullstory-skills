CLAUDE_DIR := .claude

.PHONY: setup setup-mn
setup: $(CLAUDE_DIR)/skills $(CLAUDE_DIR)/agents

$(CLAUDE_DIR)/skills: skills
	mkdir -p $@
	@for d in skills/*/; do \
		name=$$(basename $$d); \
		target=$(CURDIR)/$$d; \
		link=$(CURDIR)/$(CLAUDE_DIR)/skills/$$name; \
		if [ ! -L $$link ]; then \
			ln -s $$target $$link && echo "linked $$link -> $$target"; \
		fi; \
	done

$(CLAUDE_DIR)/agents: agents
	mkdir -p $@
	@for f in agents/*; do \
		name=$$(basename $$f); \
		target=$(CURDIR)/$$f; \
		link=$(CURDIR)/$(CLAUDE_DIR)/agents/$$name; \
		if [ ! -L $$link ]; then \
			ln -s $$target $$link && echo "linked $$link -> $$target"; \
		fi; \
	done