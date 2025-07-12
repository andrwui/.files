grim -t ppm -o $1 - | ffmpeg -f image2pipe -i - -vf "gblur=sigma=5" -qscale:v 10 -frames:v 1 $2

