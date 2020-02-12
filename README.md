# matrixPics
create image definitions suitable for 16x16 LED matrix from all .png in folder

I discovered those 16x16 pixel WS2812b LED matrix displays on aliexpress and found them really neat and quite easy to control using 
an ESP8266 mcu. FastLED is the library and as it comes with examples it is no big thing to show some colorful animations on the 
matrix. But how to make it display pictures?

## How to convert images to Arduino arrays values for use on displays?
There is one place on the net with an answer to that question, https://www.brainy-bits.com/arduino-16x16-matrix-frame/ discusses 
the hardware and how to show images with it and https://www.brainy-bits.com/create-arduino-array-from-pictures/ explains his way to 
build up the image data.
There is even a youtube tutorial. I recommend to go there and read the pages, he sort of pioneered the topic and I learned a lot.
But the proposed way to create those zig-zag arrays of rgb values did not really convince me. I had no luck with the image-converter 
linked there and the workflow involves lots of manual copying of array parts. 
I wanted hundreds of images and then it took me hours to get just six. And why use indexed colors on a displays with 24 bit rgb?

Well, one thing that happens when converting images to an indexed colr palette is that any dithering of the image will be reduced. 
And that can help when looking at the matrix as it is (i.e.: with no diffuser) and from a short distance. Dithering will just not 
work under those cirumstances. You see a pixel salad and the brain won't get the picture. Images with few flat colors like shown 
there work best.

On the other hand, with some diffusor (like: a thin sheet of white plastic) between the matrix and the eye, and seen from some 
meters distance dithered images show so much more. A suitable diffusor is available at thingiverse and the bash script here uses 
imagemagick's convert to resize images, set a black background and output the rgb which xxd dumps into a temp file. Bash opens that 
file, takes the rgb values as hex from it and writes them line by line in reversed order, formatted as c variable.

Say we have an image file u1f349.png which happens to show a watermelon in 136x128px. Convert outputs 256 rgb values. xxd writes a 
file with 16 rows which have the data in groups of 3 (rgb) and 48 values per row (3x16). (It does have some other elements like you 
would expect from a hex dump but we just ignore those).

Bash reads that, line by line. The rgb values still have their natural order but the matrix is sorted in a zig-zag order so the 
script writes the values in 1,2..16 for even lines and 16, 15..1 for odd lines. Adds some sugar and writes a file 1f349.dat which 
has the image like so:

const long pic[]  ={
0x030303, 0x030303, 0x030303, 0x030303, 0x030303, 0x030303, 0x030303, 0x030303, 0x030303, 0x030303, 0x030303, ...
...
};

You can copy/paste it in your Arduino source code or write it to flash and read it at runtime or whatever. The ESP8266 has 
flash space for hundreds of images.

