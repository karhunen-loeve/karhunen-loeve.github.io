# Type-Safe Computer Vision — blog

Source of <https://karhunen-loeve.github.io>. Static HTML, no build step, no
dependencies. Each post is a single self-contained file (inline CSS, inline
SVG, no external assets) and can be opened straight from disk to proofread.

| File | Post |
|---|---|
| `index.html` | Series landing page |
| `01-rgb-bgr-the-blue-face-bug.html` | Part 1 — The Blue Face Bug |
| `02-gamma-blind-interpolation.html` | Part 2 — 128 Is Not the Middle |
| `03-pyramids-and-scale-space.html` | Part 3 — Climbing the Pyramid |
| `feed.xml` | Atom feed |
| `.nojekyll` | Tells GitHub Pages to serve the files verbatim |

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
4. **Verify** — feed at <https://validator.w3.org/feed/>, link preview at
   <https://cards-dev.twitter.com/validator> or by pasting the URL into a
   Mastodon draft.
5. **Announce, one post per week.** Lead with Part 2 (`128 Is Not the Middle`) —
   the strongest standalone hook. r/rust → This Week in Rust → Hacker News →
   lobste.rs → r/computervision.

## Custom domain

Add a `CNAME` file containing the bare hostname, then point a `CNAME` DNS
record at `karhunen-loeve.github.io`. Afterwards, update the absolute URLs in
`feed.xml`, the `<link rel="canonical">` and the `og:url` in every post —
`grep -rl karhunen-loeve.github.io .` finds all of them.

## Adding a post

The shared `<style>` block is copied into every file, so a design change is an
N-file edit. That is deliberate at this size — the payoff is that each post
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
