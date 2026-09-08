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
    --levels 4 --crop 440,220,5120,2560 --name gamma-thumb
```

Generator: `fovea-examples/src/gamma_thumbnails.rs`. One crop, four halving
steps of Gaussian blur plus decimation, identical in both paths. The generator
prints the measured difference; for this crop the naive thumbnail is 19.9 %
darker in mean linear luminance, worst single channel off by 43 codes out of
255. A star field is the strong case, because a single bright pixel among
fifteen dark ones lands on code 16 when the bytes are averaged and on 71 when
the light is. An ordinary backlit photograph loses around 3 % under the same
treatment — visible in a measurement, not to the eye.

The full-size original is deliberately not committed; it can be re-downloaded
from the Commons page whenever the figure needs regenerating.

## `profile.jpg`

Photograph of the site author. All rights reserved; not covered by the
repository licence.
