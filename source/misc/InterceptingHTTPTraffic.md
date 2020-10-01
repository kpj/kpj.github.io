# Intercepting HTTP(S) Traffic of Android Applications

In this post we will learn how to intercept HTTPS traffic of arbitrary Android applications.

This is, of course, purely for research purposes and testing your own apps.


## Before you start

Make sure that the [Android SDK](https://developer.android.com/studio) is installed properly. Furthermore, install [mitmproxy](https://github.com/mitmproxy/mitmproxy).


## Setting up the Emulator

While it is possible to apply this technique to apps running on an actual phone, using an emulator makes it less likely to permanently mess up something important.

Run `avdmanager` to open the device manager and create a new virtual device. The device definition (e.g. Pixel 2 vs Pixel 3) does not matter much.
However, when selecting the system image, make sure to switch to the `x86 Images` tab and select a `Google APIs` target (and *not* `Google Play`). This is necessary to install SSL certificates to the system partition. Make sure to choose Android 9.0, i.e. APIs version 28.

After finishing this process, your newly created virtual device should appear:
```bash
$ emulator -list-avds
Pixel_3_XL_API_28
```


## Install SSL certificates

In order to be able to intercept HTTPS traffic of apps, we need to install `mitmproxy`'s required SSL certificates as system certificates. This is due to how trusted certificates are handled since [Android Nougat](https://android-developers.googleblog.com/2016/07/changes-to-trusted-certificate.html).

First, start the emulator with a writable system partition:
```bash
$ emulator -writable-system -avd Pixel_3_XL_API_28
```

Then restart `adb` with root permissions and mount `/system` as writable:
```bash
$ adb root
$ adb remount
```

Finally install `mitmproxy`'s certificate:
```bash
$ ca="$HOME/.mitmproxy/mitmproxy-ca-cert.pem"
$ hash=$(openssl x509 -noout -subject_hash_old -in "$ca")
$ adb push "$ca" "/system/etc/security/cacerts/$hash.0"
```

Revoke root permissions afterwards:
```bash
$ adb unroot
```


## Test if everything worked

Next, boot the emulator with an enabled HTTP proxy:
```bash
$ emulator -writable-system -http-proxy http://0.0.0.0:8080 -avd Pixel_3_XL_API_28
```

Try accessing the internet (open a webpage in the mobile browser, or use the google searchbar widget). It should not work.

Now, start `mitmproxy` on your computer. Retry accessing the internet. It should work without issues.
In addition, your requests (both HTTP and HTTPS) should appear in the `mitmproxy` view.


## Install the app which you are interested in

After compiling your open-source Android app of interest and generating an APK, install it as follows:
```bash
$ adb install App.apk
```


## Explore the hidden API

Now we get to the fun part! While running `mitmproxy`, browse the app and investigate which kinds of network requests are being generated. Pay special attention to login mechanisms, and how access tokens and user ids are handled.


### How to use mitmproxy

The process of understanding how the API works can be sped up considerably by using the `mitmproxy` interface efficiently.

Here is an overview of the most important controls:

* Show help page: `[?]`
* Save captured traffic to file: `[w]`, type `<path>`
* Load saved traffic: `mitmproxy -r <path>`
* [Filter traffic](https://docs.mitmproxy.org/stable/concepts-filters/): `[f]`, type `<filter expression>`
    * match domain: `~d <domain>`
    * match URL: `~u <term>`


## Replicate API calls

To swiftly confirm your understanding of the API, store the payload (in JSON format) in `data.json`:
```json
{
    "param1": "value1",
    "param2": "value2"
}
```

Then execute `curl` with appropriate parameters:
```bash
$ curl \
    <url> \
    -X POST \
    -H "Content-Type: application/json; charset=utf-8" \
    -d @data.json
```

Once you have gained a good understanding, it is time to automate things using Python:
```python
import requests


resp = requests.post(
    '<url>',
    headers={
        'Content-Type': 'application/json; charset=utf-8'
    },
    json={
        'param1': 'value1',
        'param2': 'value2'
    }
)

print(resp.json())
```
