any_bundle_SRC := $(wildcard $(CURDIR)/any-bundle/*.t)
any-bundle:
	@bats -t $(any_bundle_SRC)

bundles_SRC := $(wildcard $(CURDIR)/bundles/*/*.t)
bundles := $(notdir $(wildcard $(CURDIR)/bundles/*))
$(bundles):
	@bats -t $(wildcard $(CURDIR)/bundles/$@/*.t)

SRC := $(any_bundle_SRC) $(bundles_SRC)
all:
	@bats -t $(SRC)

.PHONY: any-bundle $(bundles)

# Static Code Analysis
# ====================
check_CHECKOPTS := --exclude=1091,2155 ${CHECKOPTS}
check:
	@echo "Shellcheck [All Bundles]:"
	shellcheck -s bash -x $(check_CHECKOPTS) $(SRC)

check_BUNDLES = $(addprefix check-,$(bundles))
$(check_BUNDLES): bundle = $(patsubst check-%,%,$@)
$(check_BUNDLES): tests = $(wildcard $(CURDIR)/bundles/$(bundle)/*.t)
$(check_BUNDLES):
	@echo "Shellcheck: [$(bundle)]:"
	shellcheck -s bash -x $(check_CHECKOPTS) $(tests)

check-any-bundle:
	@echo "Shellcheck: [any-bundle]:"
	shellcheck -s bash -x $(check_CHECKOPTS) $(any_bundle_SRC)
