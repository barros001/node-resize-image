Thumbnail resizing service.

You probably want to host it on Heroku.

Given a URL that contains the original/source image (https://s3.amazonaws.com/tanga-images/83y8hk5ntsq6.png), 
you can resize it on the fly.

Demos:

http://tanga-image-resizer.herokuapp.com/v1/w_200,h_200/https://s3.amazonaws.com/tanga-images/83y8hk5ntsq6.png
http://tanga-image-resizer.herokuapp.com/v1/c_fill,w_200,h_200/https://s3.amazonaws.com/tanga-images/83y8hk5ntsq6.png


Put this behind amazon cloudfront, use cloudfront to cache the thumbnails..

