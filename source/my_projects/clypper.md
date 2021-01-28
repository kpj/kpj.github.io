# clypper: Rapidly create supercuts from various video sources

Who doesn't know this scenario? You are a couple of hours deep into a Youtube marathon and have already found a trove of hilarious clips which just wait to be combined into a new transformative, derivative work. Say, a remix.
Unfortunately, just thinking of firing up Adobe Premiere Pro or Final Cut Pro makes you discard your ideas right away. If only there was a way of creating these compilations more easily...

But wait, there's [clypper](https://github.com/kpj/clypper)! It allows you to create super-cuts right where you feel at home -- in the commandline!
Just put a list of video sources (be it local files, youtube urls, ...) and timestamps into a text file, execute a single command, and you are done.

Take this innocent looking text file, for example:

```
https://www.youtube.com/watch?v=-tvA3Ezqjl8 12:32 12:34.7
https://www.youtube.com/watch?v=dQw4w9WgXcQ 00:42 00:43.1
```

By executing `clypper -i innocent.txt -o ohno.mp4`, you can create this monstrosity:

![example-gif](clypper_resources/example.gif)

Be thankful you don't have to hear the sound and watch it with full quality.
