#!/bin/bash
set -e

# Steps:
# Download the image.
# Figure out what kind of file it is.
# Make a new temp file with the right file extension.
# Convert the image.
# Output image name to stdout.

DOWNLOADED_IMAGE=`mktemp $TMPDIR/download-XXXXXXXXX`

wget --no-check-certificate -nv $1 -O $DOWNLOADED_IMAGE

# Get the image type. If it's animated, then it'll show up
# as GIFGIFGIF (one for each frame), so put each type 
# on a new line and use head to get the first one.
IMAGE_TYPE=`identify -format '%m\n' $DOWNLOADED_IMAGE | head -n 1`

# If bmp or pdf, change to jpg.
if [ "$IMAGE_TYPE" = 'BMP' -o "$IMAGE_TYPE" = 'PDF' ]
then 
  IMAGE_TYPE='JPG'
fi

NEW_FILENAME=$DOWNLOADED_IMAGE.$IMAGE_TYPE

shift 

convert $DOWNLOADED_IMAGE $@ $NEW_FILENAME

echo $NEW_FILENAME
