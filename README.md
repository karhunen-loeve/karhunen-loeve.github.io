# Type-Safe Computer Vision, the blog

Source of <https://karhunen-loeve.github.io>. Static HTML, no build step, no
dependencies. Each post is a single self-contained file (inline CSS, inline
SVG, no external assets) and can be opened straight from disk to proofread.

| File | Post |
|---|---|
| `index.html` | Series landing page |
| `01-rgb-bgr-the-blue-face-bug.html` | Part 1: The Blue Face Bug |
| `02-gamma-blind-interpolation.html` | Part 2: 128 Is Not the Middle |
| `03-pyramids-and-scale-space.html` | Part 3: Climbing the Pyramid |
| `tools/` | Browser tools: computer vision running client-side on WebAssembly |
| `404.html` | What Pages serves for any address that is not here |
| `feed.xml` | Atom feed |
| `images/` | The only external assets, currently just the portrait on `index.html` |
| `.nojekyll` | Tells GitHub Pages to serve the files verbatim |

## Browser tools

`tools/` holds pages that run `fovea` in the reader's browser. Every page in
the site carries a left rail linking to them, themed from that page's own
palette through its `--fv-*` variables.
## Metadata

Four things are worth knowing about because they are easy to break silently.

**Preview cards.** Each page names a 1200x630 card in `images/og-*.png` and
sets `twitter:card` to `summary_large_image`, so a link pasted into Mastodon,
Slack or LinkedIn arrives as a card and not as a bare URL. The cards are
generated, not drawn: one template with a per-page motif, kept in the private
workspace. Re-rendering one means re-rendering it from there, since nothing in
this repo can rebuild it.

**Structured data.** A `application/ld+json` block per page: `BlogPosting` for
the posts, `WebSite` plus `Blog` on the landing page, `CollectionPage` and
`WebApplication` for the tools. This is the only description of the page a
search engine or an assistant will parse rather than guess at. It repeats
what the visible text already says, which means it can drift from it: if a
title or a description changes, change it in both places.

**The 404 page is served under the address that was missed,** not under
`/404.html`. So every link in it, the generated rail included, has to start at
the site root or it breaks for any missing address one directory down. That is
why `add-rail.py` carries `up="/"` for this one page and a relative prefix for
every other.

**`llms.txt`** is a bet, not a standard. It is a 2024 convention for telling a
language model in prose what a site is and which pages matter. No crawler is
obliged to read it. It costs nothing to keep correct and nothing is lost if it
is ignored.


**The rail is generated too.** In every page it sits between
`browser-tools rail: begin` and `browser-tools rail: end` markers, in both the
`<style>` block and the body. Do not hand-edit inside those markers: a script
outside this repo rewrites every page from one template, and an edit
there is lost on the next run. Changing a rail entry means changing that
template. Only the `--fv-*` values at the top of each block are per page, and
they are generated as well.

`tools/fovea-wasm.js` is **generated**, not written: it is the compiled
WebAssembly module, base64-encoded into a classic script. Do not edit it. It
is rebuilt from the `fovea` sources by a script kept outside this repo.

Two decisions are worth knowing before touching those pages:

- **The module is inlined, not fetched.** A `.wasm` cannot be fetched over
  `file://`, and neither can an ES module script, so both would have broken
  the open-from-disk property above. Base64 in a classic script keeps it.
  The cost is a third more bytes, which gzip mostly gives back.
- **Sample images are generated in the page.** A `file://` page cannot read
  pixels back out of a canvas it drew a `file://` image into: the origin is
  opaque, so the canvas is tainted. The procedural samples avoid that
  entirely; the one sample that is a real photograph says so when it fails.

## Publishing

1. **Wait for fovea 0.4.0 on crates.io.** Part 3 shows the pyramid API; until
   0.4.0 is released, a reader running `cargo add fovea` gets 0.3.0 and the
   code in that post does not exist yet.
2. **Stamp the dates.** The posts and the feed carry `@@DATE1@@` /
   `@@HUMAN1@@` placeholders so an invalid date can never reach a feed reader:

   ```powershell
   ./stamp-dates.ps1 -Date1 2026-08-18 -Date2 2026-08-18 -Date3 2026-08-18
   ```

3. **Push to `main`.** Pages → Deploy from branch → `main` / root.
4. **Verify.** Feed at <https://validator.w3.org/feed/>, link preview at
   <https://cards-dev.twitter.com/validator> or by pasting the URL into a
   Mastodon draft.
5. **Announce, one post per week.** Lead with Part 2 (`128 Is Not the Middle`), the strongest standalone hook. r/rust → This Week in Rust → Hacker News →
   lobste.rs → r/computervision.

## Custom domain

Add a `CNAME` file containing the bare hostname, then point a `CNAME` DNS
record at `karhunen-loeve.github.io`. Afterwards, update the absolute URLs in
`feed.xml`, the `<link rel="canonical">` and the `og:url` in every post. `grep -rl karhunen-loeve.github.io .` finds all of them.

## Adding a post

The shared `<style>` block is copied into every file, so a design change is an
N-file edit. That is deliberate at this size: the payoff is that each post
survives as a single portable file. Once that gets annoying (around post 5 or
6), move to [Zola](https://www.getzola.org): single Rust binary, no npm, and
the CSS becomes one template.

Checklist for a new post: copy the `<head>` of an existing one and change the
five metadata strings, add an entry to `index.html` and `feed.xml`, and update
the `footer-nav` in *every* post of the series.

The writing style guide lives in the private workspace repo, not here.

## License

Prose and figures © Thomas Stephan. Code snippets are MIT/Apache-2.0, matching
[fovea](https://github.com/karhunen-loeve/fovea).
