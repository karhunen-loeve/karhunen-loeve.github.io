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

A star field is the strong case, because a single bright pixel among fifteen
dark ones lands on code 16 when the bytes are averaged and on 71 when the light
is. An ordinary backlit photograph loses around 3 % under the same treatment —
real, measurable, and invisible to the eye.

The full-size original is deliberately not committed; it can be re-downloaded
from the Commons page whenever the figure needs regenerating.

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

## `profile.jpg`, `profile-comic.jpg`

Photograph of the site author and an AI-stylised version of it. Own work; all
rights reserved, not covered by the repository licence.
