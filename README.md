# Barion Design System

Static reference page documenting Barion's brand tokens, components, and UI patterns. **This folder is the single source of truth** for the `barion-design` skill — edit here and the AI design system updates from it.

Live mirror: <https://barion-design-system.vercel.app/>

## What's in here

| File / folder | Role |
|---|---|
| `index.html` | The rendered component catalogue — 22 numbered sections (Color, Typography, Logo, Shape … Hard rules). The "what it should look like" reference. |
| `brand-tokens.css` | The canonical, machine-readable tokens — every colour, font size, weight, radius, shadow, spacing step, gradient and motion value as a CSS custom property. **The authoritative token source.** |
| `assets/` | Logo SVGs (`barion-mark[-white].svg`, `barion-wordmark[-white].svg`). |
| `icons/` | Icon PNGs (mostly superseded by inline `<symbol>` SVGs in `index.html`). |

## Local preview

Open `index.html` in a browser, or serve the folder:

```
python3 -m http.server 8000
```

## Deploy

Auto-deploys to Vercel on push to `main`. **Cowork reads the deployed copy (see below), so push/deploy after finalizing changes** or Cowork won't see them.

---

## How the `barion-design` skill consumes this folder

The skill is the *behavioural* layer (triggering, the audit checklist + hard rules, the real WeblySleek `.ttf` fonts, logo assets, and component specs). This folder is the *data* layer (tokens + rendered catalogue). They're complementary — the skill reads its tokens **from here** rather than carrying its own copy, which is what keeps everything from drifting.

There are two builds of the skill, and each reads the freshest source it can reach:

| Platform | Reads tokens from | Why |
|---|---|---|
| **Claude Code** (`~/.claude/skills/barion-design/`) | the **local** files in this folder, by absolute path (live-point) | You *edit* here, so local is the freshest source — it can be ahead of the Vercel deploy. Offline, zero-cost, and the skill ships the real `.ttf` fonts. |
| **Cowork** (`barion-po-assistant` plugin) | **fetches** `https://barion-design-system.vercel.app/brand-tokens.css` at runtime | The Cowork runtime can't reach your local path, so it reads the deployed mirror. A bundled `references/brand-tokens.css` is only an offline fallback snapshot. |

**Net result: no hand-synced token copy is maintained anywhere.** Edit `brand-tokens.css` / `index.html` → Claude Code is instantly current; push to deploy → Cowork is current.

### What the skill adds on top of this folder
- Real **WeblySleek UI `.ttf`** fonts (the deployed page renders in system fallback — it ships no fonts).
- **Logos** (SVG/PNG) and a merchant-dashboard **UI kit**.
- **Component specs** (`specs/*.md`) — the *when / why / edge-cases* prose and code patterns that the rendered HTML doesn't carry.
- **Guardrails**: the pre-output audit, hard rules (sentence case, flat shadows, no orange in product UI, status-chip ≠ alert-surface, 8px button default / pill only for onboarding), and `when-to-use.md` token-intent guide.
- A note on Cowork: the fetched `brand-tokens.css` omits Fira Sans (it assumes WeblySleek is installed), so the Cowork skill injects `"Fira Sans"` into `--font-brand` after fetching.

## Editing rules for `index.html`
- **Section numbering must stay in sync:** body `<h2>N · Title</h2>` ↔ sidenav `<span class="sidenav__num">N</span>`. Inserting a section means renumbering both and fixing any in-text "section N" cross-references.
- `brand-tokens.css` is the source of truth for values — don't hardcode hexes in `index.html`; reference `var(--…)`.
- The page changes between sessions; treat any prior read as stale and re-read before editing.

## Background
- Architecture decisions: `Claude/DECISIONS/2026-06-03_barion-design-live-pointer.md` and `2026-06-04_cowork-design-tokens-url-fetch.md`.
- Figma origin: Brand Guidelines – Design System `OmeynxsvYTEtnkZ4d6gWrR`.
