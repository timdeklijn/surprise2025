# Joke Poem (NOS.nl‑style mock)

A single‑file static page that playfully mimics the desktop layout vibe of nos.nl for a joke poem. Content is placeholder/lorem ipsum; no scripts, no external assets.

## Files
- `index.html` — all markup and CSS inline

## Run locally
Serve the folder with any static file server. The simplest is Python’s built‑in HTTP server.

### Using Python 3 (Linux/macOS)
```bash
python3 -m http.server 8000
```
Then open:
```
http://localhost:8000
```

### Using Python on Windows
PowerShell:
```powershell
py -3 -m http.server 8000
```
Then open `http://localhost:8000` in your browser.

### Custom port (optional)
Change `8000` to any open port you prefer.

## Notes
- This is intentionally desktop‑only. No responsive tweaks were added.
- Styling and structure are inspired by the look and feel of news sites; this is not an official NOS page and uses only placeholder content.
