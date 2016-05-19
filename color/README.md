# Color

```bash
source color.sh

echo "This is ${pred}RED$preset."
echo "This is $(c IndianRed)Indian Red$preset."
```

## Using

1. Define `c_truecolor` to `true` or `false`. There is not (yet) any automatic
   detection to distinguish 6-bit (256) color terminals from 8-bit (16
   million). The Mac OS X system terminal lags behind most others in this
   respect. The default is `true`.
2. Optionally set `X11_RGB_TXT` to the full path of your [`rgb.txt`](rgb.txt)
   such as provided with X11. If unset, defaults to `/usr/share/X11/rgb.txt`,
   or if that file is unreadable, to an `rgb.txt` provided with `colors.sh`.
3. Source [`color.sh`](color.sh).

## Pre-defined variables

```bash
echo "This is $pbold${pred}bold red$preset."
echo "This is $pitalic${pgreen}italic green$preset."
```

All predefined variables are prefixed with `p`, as in `$pred` or
`${preset}`.

### Reset

To restore default text properties: 

* reset

### Colors

The basic ANSI 8 colors as foreground:

* black
* red
* green
* yellow
* blue
* magenta
* cyan
* white

### Effects

The most supported ANSI text effects:

* bold
* light
* italic
* underscore
* blink
* reverse
* invisible
* strikethrough

## X11 colors

```bash
cat <<EOM
Reds include:
* $(c IndianRed)Indian red$preset
* $(c OrangeRed)orange red$preset
* $(c VioletRed)violet red$preset
* $(c DarkRed)dark red$preset
EOM
echo "Or you can make $(c 210 30 30)your own red$preset."
```

Using an 8-bit color palette, and to a lesser degree 6-bit, you can use around
500 X11-defined colors by name, or provide your own RGB values.

## TODO

* Detect 8- vs 6-bit color.
* Detect and handle non-color, e.g., output is not to a terminal.
