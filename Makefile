any_bundle_SRC := $(wildcard $(CURDIR)/any-bundle/*.t)
bundles_SRC := $(wildcard $(CURDIR)/bundles/*/*.t)

SRC := $(any_bundle_SRC) $(bundles_SRC)

bundles := $(notdir $(wildcard $(CURDIR)/bundles/*))

# Static Code Analysis
# ====================
check_CHECKOPTS := --exclude=1091,2155
check:
	@echo "Shellcheck [All Bundles]:"
	shellcheck -x $(check_CHECKOPTS) $(SRC)

check_BUNDLES = $(addprefix check-,$(bundles))
$(check_BUNDLES): bundle = $(patsubst check-%,%,$@)
$(check_BUNDLES): tests = $(wildcard $(CURDIR)/bundles/$(bundle)/*.t)
$(check_BUNDLES):
	@echo "Shellcheck: [$(bundle)]:"
	shellcheck -x $(check_CHECKOPTS) $(tests)

check-any-bundle:
	@echo "Shellcheck: [any-bundle]:"
	shellcheck -x $(check_CHECKOPTS) $(any_bundle_SRC)
