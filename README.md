# Dalí

An image loading and caching library for flutter. Supports iOS and Android.
Dali is focused on speed and memory efficiency. It saves different versions of the original image in the local storage and cache.
Once the image is downloaded, Dalí also makes copies of the image in different sizes in order to minimize the amount of memory used.


## Getting Started

Initialize Dali the app using this code:
```
void main() {
  DaliImageCache.ensureInitialized()
    ..attachRootWidget(MyApp())
    ..scheduleWarmUpFrame();
}
```


Then you can load an image in a container:
```
Container(
  height: 200,
  width: 200,
  child: Dali(imageUrl: images[index]),
)
```
