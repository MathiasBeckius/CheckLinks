TEST_DIR := test
LIB_DIR := lib

OUTPUT_DIR := .output

TESTS := $(shell find $(TEST_DIR) -name *.t)
REPORTS := $(TESTS:%=$(OUTPUT_DIR)/%.txt)

.PHONY: test

unit_test: _create_dirs _clean_tests $(REPORTS)

test: _create_dirs _clean_tests .output/test/expected/dir_with_broken_links.txt .output/test/expected/dir_with_no_files.txt

.output/test/expected/dir_with_broken_links.txt: $(TEST_DIR)/expected/dir_with_broken_links.txt
	./check_links.pl test/input/broken_links > $@
	cmp $@ $<

.output/test/expected/dir_with_no_files.txt: $(TEST_DIR)/expected/dir_with_no_files.txt
	./check_links.pl test/input/no_files > $@ ||:
	cmp $@ $<

create_expected_output: _create_dirs
	./check_links.pl $(TEST_DIR)/input/no_files > $(TEST_DIR)/expected/dir_with_no_files.txt ||:
	./check_links.pl test/input/broken_links > $(TEST_DIR)/expected/dir_with_broken_links.txt

clean:
	@rm -rf $(OUTPUT_DIR)

$(OUTPUT_DIR)/%.t.txt: %.t
	@perl -I$(LIB_DIR) $< > $@

_create_dirs:
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(OUTPUT_DIR)/$(TEST_DIR)
	@mkdir -p $(OUTPUT_DIR)/$(TEST_DIR)/expected
	@mkdir -p $(TEST_DIR)/input/no_files

_clean_tests:
	@rm -f $(OUTPUT_DIR)/$(TEST_DIR)/*.txt
	@rm -f $(OUTPUT_DIR)/$(TEST_DIR)/expected/*.txt
