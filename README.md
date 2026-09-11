# Type-Safe Computer Vision, the blog

Source of <https://karhunen-loeve.github.io>. Static HTML, no build step, no
dependencies. Each page carries its own CSS and its diagrams as inline SVG, so
it can be opened straight from disk to proofread. The raster figures, the
icons and the preview cards are the exception and live in `images/`.

| File | Post |
|---|---|
| `index.html` | Series landing page |
| `01-rgb-bgr-the-blue-face-bug.html` | Part 1: The Blue Face Bug |
| `02-gamma-blind-interpolation.html` | Part 2: 128 Is Not the Middle |
| `03-pyramids-and-scale-space.html` | Part 3: Climbing the Pyramid. Held back, not on `main` |
| `404.html` | What Pages serves for any address that is not here |
| `tools/` | Browser tools: computer vision running client-side on WebAssembly |
| `feed.xml` | Atom feed |
| `sitemap.xml` | The live pages, with dates stamped alongside the posts |
| `robots.txt` | Nothing excluded; exists to name the sitemap |
| `llms.txt` | What the site is, in prose, for a language model that looks |
| `images/` | The external assets: figures, the portrait, the six preview cards |
| `favicon.svg`, `favicon.png`, `apple-touch-icon.png` | Site icon |
| `.nojekyll` | Tells GitHub Pages to serve the files verbatim |

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

## Browser tools

`tools/` holds pages that run `fovea` in the reader's browser. Every page in
the site carries a left rail linking to them, themed from that page's own
palette through its `--fv-*` variables.

**The rail is generated too.** In every page it sits between
`browser-tools rail: begin` and `browser-tools rail: end` markers, in both the
`<style>` block and the body. Do not hand-edit inside those markers: a script
outside this repo rewrites every page from one template, and an edit
there is lost on the next run. Changing a rail entry means changing that
template. Only the `--fv-*` values at the top of each block are per page, and
they are generated as well.

Two things in that block reach outside itself, which is worth knowing before
wondering where they came from. Its script inserts the **skip link** as the
first child of the body, and gives the first `<article>` or `<main>` an
`id="fv-content"` and `tabindex="-1"` to aim at. Neither is in the markup: the
target is named differently on every page, and a skip link pointing at nothing
would be worse than none. Both appear only once the document has parsed.

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

1. **Check that the API in the posts is released.** `tools/fast-corners.html`
   links `SegmentTest` on docs.rs and Part 3 shows the pyramid API, both of
   which arrived in 0.4.0. That version has been on crates.io since
   2026-09-05, so this gate is met; it only reopens if a later post reaches
   for something newer than the latest release, which is one of the reasons a
   post can end up held back.
2. **Move the tree onto `main`,** which is where Pages deploys from, and stamp
   it *there*. The order matters and is not the obvious one.

   Not a merge: `main` holds no content between releases, so the last time it
   was cleared it deleted the five content files, and `git merge develop` now
   raises a modify/delete conflict on each of them. And not stamp-then-move
   either: stamping leaves modified files in the working tree, `git checkout
   main` then refuses to switch, and pushing on regardless makes
   `git checkout develop -- .` quietly restore the unstamped versions. That
   route ends with placeholders in public, which is the one thing the
   placeholders exist to prevent.

   Stamping on `main` also leaves `develop` with its placeholders intact,
   which is what the next post needs.

   ```sh
   git checkout main
   git rm -rq --cached .
   git checkout develop -- .
   ```

   If a post is held back, it comes out of the tree here, before anything is
   stamped. See *Holding a post back* below.

3. **Stamp the dates.** The posts, the feed and the sitemap carry `@@DATE1@@`
   and `@@HUMAN1@@` placeholders so an invalid date can never reach a feed
   reader. The date is stamped as noon UTC, so the machine-readable date and
   the printed byline name the same day in every timezone a reader might be
   in:

   ```powershell
   ./stamp-dates.ps1 -Date1 2026-09-11 -Date2 2026-09-11
   ```

   One `-DateN` per post that is going out. `-Date3` is optional and stays
   omitted while Part 3 is held back, since its placeholders are not in this
   tree.

4. **Refuse to publish with a placeholder left.** This is the one step whose
   failure is both silent and public: a live byline reading `@@HUMAN2@@`. The
   stamper says so at the end of its run, and this says it again from the
   other side, over exactly the files that go out:

   ```powershell
   $left = Select-String -Path *.html, tools/*.html, feed.xml, sitemap.xml `
                         -Pattern '@@(DATE|HUMAN)\d@@'
   if ($left) { $left; throw 'placeholders left, do not publish' }
   ```

5. **Commit and push.** `git diff develop main` is expected to be non-empty
   now. With nothing held back it contains only the stamped dates; with a post
   held back it also shows that post's file and its preview card, present on
   `develop` and absent here. Read it before pushing; it is the shortest
   complete description of what goes live.

   ```sh
   git add -A
   git commit -m "Publish"
   git diff develop main            # stamped dates, plus any held-back post
   git push origin main
   git checkout develop             # placeholders here are untouched
   ```

   Pages needs no setting changed: source is already branch `main`, path `/`,
   with HTTPS enforced. `.nojekyll` means the files are served exactly as
   committed.

6. **Verify.** Feed at <https://validator.w3.org/feed/>, structured data at
   <https://validator.schema.org/>, link preview by pasting the URL into a
   Mastodon draft. Then fetch a retina figure and a preview card by hand, since
   those are the two paths a desktop browser never takes, and ask the API
   whether it noticed the 404 page:

   ```sh
   curl -sI https://karhunen-loeve.github.io/images/blue-face-480_rgb.png | head -1
   curl -sI https://karhunen-loeve.github.io/images/og-02.png | head -1
   gh api repos/karhunen-loeve/karhunen-loeve.github.io/pages --jq .custom_404
   ```
7. **Announce, one post per week.** Nothing about this is tied to the stamped
   date: every page is reachable from the moment of the push, and none of the
   channels below checks how old a link is. So one publication can carry weeks
   of announcements. Lead with Part 2 (`128 Is Not the Middle`), the strongest
   standalone hook.

   Two kinds of channel, and only one of them can be staggered.

   **Submitted by hand, one at a time, whenever you like:** r/rust, This Week
   in Rust, Hacker News, lobste.rs, r/computervision. Each post has its own
   URL and its own preview card, so each submission stands on its own. Use the
   address in that page's `<link rel="canonical">` so the preview and any
   later mention agree on one URL.

   **Fed from `feed.xml`, so they arrive all at once:** the Atom subscribers,
   and daily.dev, which onboards a source from its feed. Registering the feed
   pulls in whatever it holds at that moment, which for this push is Parts 1
   and 2 on one date. Worth confirming when you set daily.dev up rather than
   taking this on trust. It costs nothing: feed audiences are small and
   self-selected, and the reach comes from the hand-submitted list above.

   Because Part 3 is held back, it enters the feed as a genuinely new entry on
   its own publishing push. The feed audience gets a second arrival instead of
   three posts landing on one date.

   One thing has no way back. Once the feed has gone out with a date, do not
   move `<published>` afterwards: the entry ids stay the same, and a
   retroactively shifted date is exactly the kind of quiet wrongness the date
   placeholders exist to prevent. Whether a post gets a date of its own has to
   be decided before its publishing push, not after it.

## Holding a post back

Held back as of 2026-09-10: **Part 3, `03-pyramids-and-scale-space.html`.** The
prose is finished, the fovea code at the end of it is not, so it does not go out
with Parts 1 and 2.

The file stays on `develop`, with its `@@DATE3@@` placeholders intact. What is
removed on `develop` is everything that would point a reader or a crawler at it:
its entry in `feed.xml` and in `sitemap.xml`, its URL in the landing page's
JSON-LD, its item on the 404 page, its bullet in `llms.txt`, and its link in the
series navigation of Parts 1 and 2. Its card on the landing page stays, as a
`card draft` marked `in review`, so the series still reads as three parts.

Three dates elsewhere mean "publication day" rather than "Part 3": the `lastmod`
of `/`, of `/tools/` and of `/tools/fast-corners.html`. So does the feed-level
`<updated>`. All four point at `@@DATE2@@` while Part 3 is held, and back at
`@@DATE3@@` once it goes out.

In the publishing move, after `git checkout develop -- .`, take the two files
that must not go live out of the tree:

```sh
git rm -q --cached 03-pyramids-and-scale-space.html images/og-03.png
rm 03-pyramids-and-scale-space.html images/og-03.png
```

`images/og-03.png` is referenced by that post and by nothing else. Leaving the
post in the tree and merely unlinked is not enough: an unlinked page is still
served by Pages to anyone who guesses the address or is told it.

**Releasing it later is one revert.** The hold is a single commit on `develop`,
so reverting that commit restores the feed entry, the sitemap entry, the JSON-LD
URL, the 404 item, the `llms.txt` bullet, the two navigation links and the live
card in one step. Then publish as above, with `-Date3` set to that day and the
two lines above dropped from the move.

## Custom domain

Add a `CNAME` file containing the bare hostname, then point a `CNAME` DNS
record at `karhunen-loeve.github.io`. Afterwards, update the absolute URLs in
`feed.xml`, `sitemap.xml`, `llms.txt`, `robots.txt`, and in every page the
`<link rel="canonical">`, the `og:url`, the `og:image` and every absolute URL
inside the JSON-LD block. `grep -rl karhunen-loeve.github.io .` finds all of
them, and there are more of them than there used to be.

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
