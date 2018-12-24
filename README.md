# Dalí

An image loading and caching library for flutter focused on speed and memory efficiency.

Supports iOS and Android.

Dalí saves the downloaded image in memory in case the same image is requested in the future.
Only a resized version with the desired size will be loaded in memory instead of loading the full size in order to preserve RAM memory.

Images are saved in the cache directory of the app. This means the OS can delete the files any time.

## Getting Started

Then you can load an image in a container:
```
Container(
  height: 200,
  width: 200,
  child: Dali(imageUrl: 'https://homepages.cae.wisc.edu/~ece533/images/airplane.png'),
)
```
