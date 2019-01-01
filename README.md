# Dalí

An image loading and caching library for flutter focused on speed and memory efficiency.

Supports iOS and Android.

Dalí saves the downloaded image in memory in case the same image is requested in the future.
Only a resized version with the desired size will be loaded in memory instead of loading the full size in order to preserve RAM memory.

Images are also saved in the cache directory of the app.

## Getting Started

### Use the *Dali* widget
The easier way is to use the Dali widget. It will get the dimensions of his container and load a resized image

```
Container(
  height: 200,
  width: 200,
  child: Dali(
    'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
  ),
)
```

You have the option to set a loading widget while the image is being loaded, and also an error widget if it occurs
```
Dali(
  imageUrl: 'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
  fit: BoxFit.cover,
  placeholder: Icon(Icons.timer),
  errorWidget: Icon(Icons.error),
)
```


### Use the *DaliImageProvider*
Alternatively you can use the DaliImageProvider in combination with the Image widget

```
Image(
  image: DaliImageProvider(
    'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
    width: 90,
    height: 90,
  ),
  fit: BoxFit.cover,
)
```

Remember it is always better to set the width and height of the image