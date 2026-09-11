# Image credits

## `gamma-thumb_naive.png`, `gamma-thumb_linear.png`

Two thumbnails of the same crop of the same photo, reduced the same way,
differing only in whether the sRGB transfer curve was respected. Fig. 5 in
`02-gamma-blind-interpolation.html`.

**Source photo:** "ESO - Milky Way" by ESO/S. Brunier, 6000x3000.
<https://commons.wikimedia.org/wiki/File:ESO_-_Milky_Way.jpg>
Original release: <https://www.eso.org/public/images/eso0932a/>

**Licence:** CC BY 4.0 — attribution as above, no share-alike obligation.
<https://creativecommons.org/licenses/by/4.0/>

**How they were produced** (from the fovea workspace, with the original photo
downloaded from the Commons page above):

```sh
cargo run --release --bin gamma_thumbnails -- \
    --input ESO_-_Milky_Way.jpg --out-dir blog/images \
    --levels 3 --crop 0,600,2560,1280 --name gamma-thumb
```

Generator: `fovea-examples/src/gamma_thumbnails.rs`. One crop, three halving
steps of Gaussian blur plus decimation, identical in both paths. The generator
prints the measured difference; for this crop the naive thumbnail is 21.7 %
darker in mean linear luminance, worst single channel off by 35 codes out of
255. A crop of empty sky without the galactic band reaches 36 %.

Both files are re-runnable to the byte: regenerating them from the Commons
original reproduces the committed PNGs exactly, checked 2026-09-09.

A star field is the strong case, because a single bright pixel among fifteen
dark ones lands on code 16 when the bytes are averaged and on 71 when the light
is. An ordinary backlit photograph loses around 3 % under the same treatment —
real, measurable, and invisible to the eye.

The full-size original is deliberately not committed; it can be re-downloaded
from the Commons page whenever the figure needs regenerating.

### `gamma-thumb-640_naive.png`, `gamma-thumb-640_linear.png`

The same figure at twice the size, served through `srcset` so a phone or a
retina screen stops upsampling a figure whose whole subject is fine detail.
Same crop, one halving step fewer, which is what doubles the output:

```sh
cargo run --release --bin gamma_thumbnails -- \
    --input ESO_-_Milky_Way.jpg --out-dir blog/images \
    --levels 2 --crop 0,600,2560,1280 --name gamma-thumb-640
```

The other route to 640x320, keeping three steps and doubling the crop to
5120x2560, was measured and rejected: it reports 18.6 % rather than 21.0 %,
because the wider crop drags in a great deal of empty sky and dilutes the
difference. Two steps on the same crop keeps both the framing and the effect,
and the worst single channel is further off than at 1x, 47 codes against 35,
since the finer output averages less of it away.

## `blue-face_rgb.png`, `blue-face_bgr.png`

Fig. 2 in `01-rgb-bgr-the-blue-face-bug.html`. One image written twice: as it
is, and as code that believes the buffer is BGR displays it. No colour is
invented; the pixels are relabelled and then converted honestly.

**Source:** `profile-comic.jpg`, an AI-stylised version of the author's own
portrait photograph. Own work, no third-party rights.

**How they were produced:**

```sh
cargo run --release --bin channel_swap -- \
    --input blog/images/profile-comic.jpg --out-dir blog/images \
    --width 320 --name blue-face
```

Generator: `fovea-examples/src/channel_swap.rs`. The reduction to 320 px runs
in linear light, so a figure about channel order does not quietly demonstrate
the gamma bug from part 2 as well.

Re-runnable to the byte: regenerating from `profile-comic.jpg` reproduces the
committed PNGs exactly, checked 2026-09-09.

### `blue-face-480_rgb.png`, `blue-face-480_bgr.png`

A larger pair, served through `srcset`, so a phone or a retina screen stops
upsampling the figure. Nothing changes but the width, since the 1024 px source
has the resolution to spare:

```sh
cargo run --release --bin channel_swap -- \
    --input blog/images/profile-comic.jpg --out-dir blog/images \
    --width 480 --name blue-face-480
```

**Why 1.5x and not 2x, while fig. 5 is at 2x.** Both were generated and
weighed. At 640 px the pair comes to 1295 kB, at 480 px to 652 kB, against
324 kB for the 1x pair. The two figures do not need the same treatment: fig. 5
turns on whether individual stars survive a reduction, which is detail at the
pixel, while this one turns on a hue shift across a whole face and a whole
wall. Paying twice the bytes to sharpen the outline of a colour cast buys
little, so this figure gets 1.5x and fig. 5 gets 2x.

They are photographic, 52781 distinct colours at 640 px, so a palette is not
an option and PNG is the price of a figure that invites you to read exact
channel values off it.

### `profile-comic-web.jpg`

The copy served to readers as the Portrait sample in `tools/fast-corners.html`.
The master beside it stays as it is, because the figures above are cut from it.

```sh
cargo run --release --bin web_copy -- \
    --input blog/images/profile-comic.jpg \
    --out blog/images/profile-comic-web.jpg --quality 95
```

Generator: `fovea-examples/src/web_copy.rs`, which prints what the copy cost.
Here: 402354 bytes against 638205, so 63 %, for a worst single channel 14 code
values off and a mean of 0.907 out of 255.

The master is a quality 100 baseline JPEG, its luminance quantisation table
all ones, which is why it weighs 0.609 bytes per pixel where a copy nobody can
tell apart weighs a third of that.

**Quality 95 and no lower, for a measured reason.** This particular image is
fed to a corner detector, and JPEG ringing along an inked line does not just
blur, it manufactures corners. Run through `fast` with the page's own defaults
(t = 0.08, n = 9, nms = 3), the master reports 1893 corners. The same image
re-encoded reports:

| quality | bytes | corners found | of the master's top 400 recurring |
|---|---|---|---|
| 100, the master | 638205 | 1893 | reference |
| 95 | 402354 | 2003, up 6 % | 358 |
| 90 | 278736 | 2296, up 21 % | 316 |
| 85 | 186643 | 2474, up 31 % | 299 |

Nobody reading the tool can compare it against the master, so a 6 % inflation
harms no claim on the page. A fifth more would mean the artefacts were doing a
noticeable share of the detecting, on a page whose whole point is what the
segment test decides. Hence the stop at 95.

Progressive encoding was tried, on the received wisdom that it is smaller at
the same quality. With this encoder it came out 6 % larger, 427130 bytes, so
the copy is baseline.

Worth knowing before calling this a saving: the master has to stay committed,
since unlike the Milky Way photograph it is own work and cannot be
re-downloaded. So the repository grows by 402 kB in order to take 236 kB off
each reader who clicks that sample. It pays in bandwidth, not in repository
size.

## `profile.jpg`, `profile-comic.jpg`

Photograph of the site author and an AI-stylised version of it. Own work; all
rights reserved, not covered by the repository licence.
