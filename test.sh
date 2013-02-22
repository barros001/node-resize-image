#!/bin/sh

URLS[0]="https://s3.amazonaws.com/tanga-images/7fq9xwcejzh2.jpg"
URLS[1]="https://s3.amazonaws.com/tanga-images/ynez934suqts.gif"
URLS[2]="https://s3.amazonaws.com/tanga-images/zx298m2pw33m.jpg"
URLS[3]="http://people.sc.fsu.edu/~jburkardt/data/bmp/blackbuck.bmp"
URLS[4]="http://samplepdf.com/sample.pdf"

for url in "${URLS[@]}" 
do /usr/bin/open -a "/Applications/Google Chrome.app" `./resize.sh $url -resize 100x100`
done
