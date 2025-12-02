# Make targets for serving the static site on your LAN
# - Detects the primary LAN IPv4 via the default route
# - Works on NixOS/Linux (iproute2) and macOS (route/ipconfig)

PORT ?= 8000
HOST ?= 0.0.0.0

# Prefer the interface used for the default route (most reliable on Linux/NixOS)
DEF_IFACE := $(shell ip -o -4 route show to default 2>/dev/null | awk '{print $$5; exit}')
IP := $(shell if [ -n "$(DEF_IFACE)" ]; then \
  ip -o -4 addr show dev $(DEF_IFACE) scope global 2>/dev/null | \
  awk '{split($$4,a,"/"); print a[1]; exit}'; \
fi)

# macOS fallback: use the default route interface, then ipconfig
ifeq ($(strip $(IP)),)
IP := $(shell IFACE=$$(route -n get default 2>/dev/null | awk '/interface:/{print $$2; exit}'); \
  if [ -n "$$IFACE" ]; then ipconfig getifaddr $$IFACE 2>/dev/null; fi)
endif

# Generic fallbacks
ifeq ($(strip $(IP)),)
IP := $(shell hostname -I 2>/dev/null | awk '{print $$1}')
endif
ifeq ($(strip $(IP)),)
IP := localhost
endif

.PHONY: serve help ip

help:
	@echo "Targets:"
	@echo "  make serve [PORT=8000 HOST=0.0.0.0]  # Serve via Python http.server bound to HOST"
	@echo "  make ip                             # Print detected LAN IP"

ip:
	@echo "Default route iface: $(DEF_IFACE)"
	@echo "Detected IP:         $(IP)"

serve:
	@echo "Serving static site"
	@echo "URL (this machine):   http://localhost:$(PORT)"
	@echo "URL (LAN, best guess): http://$(IP):$(PORT)"
	python3 -m http.server $(PORT) --bind $(HOST)
