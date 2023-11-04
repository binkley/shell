# Color

```bash
source color.sh

echo "This is ${pred}RED$preset."
echo "This is $(c IndianRed)Indian Red$preset."
```

## Using

1. Define `c_truecolor` to `true` or `false`.
   There is not (yet) any automatic detection to distinguish 8-bit (256) color
   terminals from 24-bit (16 million)[^1].
   The Mac OS X system terminal lags behind most others in this respect[^2].
   The default is `true`.
2. Optionally set `X11_RGB_TXT` to the full path of your [`rgb.txt`](rgb.txt)
   such as provided with X11. If unset, defaults to `/usr/share/X11/rgb.txt`,
   or if that file is unreadable, to an `rgb.txt` provided with `colors.sh`.
3. Source [`color.sh`](color.sh).

[^1]: I need to investigate [_test if your terminal supports 24 bit true
  color_](https://gist.github.com/weimeng23/60b51b30eb758bd7a2a648436da1e562).
  This formula may work, but needs testing, and integration into `color.sh`:
  ```bash
  printf "\x1b[38;2;255;100;0mTRUECOLOR\x1b[0m\n"
  ```
[^2]: Since I last wrote this, it seems improved on MacOS.

Please note the default MacOS terminal is anemic, and does not show colors as
nicely as Linux or Windows.

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

Using an 24-bit color palette, and to a lesser degree 8-bit, you can use around
500 X11-defined colors by name, or provide your own RGB values.

## Reading

* [_Terminal Colors_](https://github.com/termstandard/colors)

## TODO

* Detect 24- vs 8-bit color.
  See [_Check if terminal supports 24-bit / true
  color_](https://unix.stackexchange.com/a/450366)
* Detect and handle non-color, e.g., output is not to a terminal.
