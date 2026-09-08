# Image credits

## `gamma-thumb_naive.png`, `gamma-thumb_linear.png`

Two thumbnails of the same crop of the same photo, reduced the same way,
differing only in whether the sRGB transfer curve was respected. Used in
`02-gamma-blind-interpolation.html`.

**Source photo:** "Autumn afternoon in Wittelsbacher Park, Augsburg (2015)"
by Paul Colin Hennig (firstdorsal.eu), 4762x3175.
<https://commons.wikimedia.org/wiki/File:Autumn_afternoon_in_Wittelsbacher_Park,_Augsburg_(2015).jpg>

**Licence:** CC BY-SA 4.0. These two files are derivative works and are
therefore published under the same licence, with attribution as above.
The licence applies to the image files only, not to the article text or to
any code in this repository.
<https://creativecommons.org/licenses/by-sa/4.0/>

**How they were produced** (from the fovea workspace, with the original photo
downloaded from the Commons page above):

```sh
cargo run --release --bin gamma_thumbnails -- \
    --input 'Autumn_afternoon_in_Wittelsbacher_Park,_Augsburg_(2015).jpg' \
    --out-dir blog/images --levels 3 --crop 160,105,2490,1640 \
    --name gamma-thumb
```

Generator: `fovea-examples/src/gamma_thumbnails.rs`. Both outputs come from
one crop (2490x1640), three halving steps of Gaussian blur plus decimation,
identical in both paths. Measured difference: the naive thumbnail is 3.4 %
darker in mean linear luminance, and the worst single channel differs by 51
codes out of 255.

The full-size original is deliberately not committed; it is 20 MB and can be
re-downloaded from the Commons page whenever the figure needs regenerating.

## `profile.jpg`

Photograph of the site author. All rights reserved; not covered by the
repository licence.
