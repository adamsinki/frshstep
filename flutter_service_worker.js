'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {".git/COMMIT_EDITMSG": "7c7d0e3591adfb6fb7840b7831203e4a",
".git/config": "07fabfb74f1386fdb2387ac639ae8cea",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/fsmonitor-watchman.sample": "a0b2633a2c8e97501610bd3f73da66fc",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-commit.sample": "5029bfab85b1c39281aa9697379ea444",
".git/hooks/pre-merge-commit.sample": "39cb268e2a85d436b9eb6f47614c3cbc",
".git/hooks/pre-push.sample": "2c642152299a94e05ea26eae11993b13",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/push-to-checkout.sample": "c7ab00c7784efeadad3ae9b228d4b4db",
".git/hooks/sendemail-validate.sample": "4d67df3a8d5c98cb8565c07e42be0b04",
".git/hooks/update.sample": "647ae13c682f7827c22f5fc08a03674e",
".git/index": "3e9acfc4303eee2b4f2fffffdc9de684",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "deecfc8872f22e04bc79e8da24d12ea7",
".git/logs/refs/heads/master": "deecfc8872f22e04bc79e8da24d12ea7",
".git/logs/refs/remotes/origin/main": "52d892d7ff569aa68f7241a49fc9c120",
".git/objects/05/bc7ac370d40de4270a07227cbfc5f55f627c43": "39db6837b1e9c519cf83238a5be77510",
".git/objects/08/27c17254fd3959af211aaf91a82d3b9a804c2f": "360dc8df65dabbf4e7f858711c46cc09",
".git/objects/12/84b926b65feb63ae97fea62762cb59221e417a": "35a40306be6f1d86d920e2439b41faf3",
".git/objects/1b/f59fcc88f39d99bd9415dca70871017c767772": "d3bf017e6e1eee3411eb6d8b15e01b79",
".git/objects/1e/75f0e0541ace9e3a94df5fa012122798f4c635": "440ab6f1998f7f5f79212e37bf306311",
".git/objects/27/935f25810379b0a612eaccf0e02803f4575d5f": "e40b7e7dfc2de1e4e1cc8a949e39f81e",
".git/objects/35/8592aa5250077a3a5984a5f208345c22aa44e9": "15e0a2e0421ea1aaf849185d17a9c64c",
".git/objects/3a/8cda5335b4b2a108123194b84df133bac91b23": "1636ee51263ed072c69e4e3b8d14f339",
".git/objects/3e/dd5b29f67c0c38587bd4a7c8e76ab74a304065": "81cb4034b66002cd0fce8ac23e052c3e",
".git/objects/42/a684e15e31ad3aa55bc3446c56f900a294cf72": "eea95dc8c831df99036d03fcec59d604",
".git/objects/46/4ab5882a2234c39b1a4dbad5feba0954478155": "2e52a767dc04391de7b4d0beb32e7fc4",
".git/objects/4a/ec5613282013a3c68666038d274b8b52dd661b": "4d44f9b8d635baa67f395c540b8c9778",
".git/objects/4b/7938dc23c257971724f2f64cffd30902551122": "e0474a11989abd34e33202c83a7d43bc",
".git/objects/51/03e757c71f2abfd2269054a790f775ec61ffa4": "d437b77e41df8fcc0c0e99f143adc093",
".git/objects/51/48b4d845c5465db3864900eed1bb3138668df8": "7d5b604eacc03237093f83f86ceb564e",
".git/objects/5a/308b15ee6a47fdb4af5a13c7f1ea8527e92523": "e272faab47dd40de0672da9710ad03e1",
".git/objects/68/43fddc6aef172d5576ecce56160b1c73bc0f85": "2a91c358adf65703ab820ee54e7aff37",
".git/objects/6b/9862a1351012dc0f337c9ee5067ed3dbfbb439": "85896cd5fba127825eb58df13dfac82b",
".git/objects/6f/7661bc79baa113f478e9a717e0c4959a3f3d27": "985be3a6935e9d31febd5205a9e04c4e",
".git/objects/7c/3463b788d022128d17b29072564326f1fd8819": "37fee507a59e935fc85169a822943ba2",
".git/objects/85/63aed2175379d2e75ec05ec0373a302730b6ad": "997f96db42b2dde7c208b10d023a5a8e",
".git/objects/88/4325a2e2dacb01ed0aab20aa41d5a4d9c3fe8d": "e74f61cd55bfb1875a6fc8751d4e1489",
".git/objects/8e/21753cdb204192a414b235db41da6a8446c8b4": "1e467e19cabb5d3d38b8fe200c37479e",
".git/objects/93/b363f37b4951e6c5b9e1932ed169c9928b1e90": "c8d74fb3083c0dc39be8cff78a1d4dd5",
".git/objects/9e/b537077d545cae62c74ec1238f15f87059b8c9": "84308c445ec0b389984fab8c87a68e8f",
".git/objects/a7/3f4b23dde68ce5a05ce4c658ccd690c7f707ec": "ee275830276a88bac752feff80ed6470",
".git/objects/ad/ced61befd6b9d30829511317b07b72e66918a1": "37e7fcca73f0b6930673b256fac467ae",
".git/objects/b9/3e39bd49dfaf9e225bb598cd9644f833badd9a": "666b0d595ebbcc37f0c7b61220c18864",
".git/objects/c5/b78860d5d24e1db7feb0f9f111a4c8d565993c": "fbb97e46e4eed73a18a347e5c714e7bb",
".git/objects/c8/3af99da428c63c1f82efdcd11c8d5297bddb04": "144ef6d9a8ff9a753d6e3b9573d5242f",
".git/objects/cc/e086bb13e63c7c5007bc58ece58b9207c274d4": "2457408987aa242c6277d3bc28689126",
".git/objects/ce/87054cd3df296c7a6a49ff742adeb075bd8824": "000e84aa1c35e2fef0ac701c054e057e",
".git/objects/d2/d8eb7e7996455a9afd1352736481d6b2540a5f": "2b70121427f4e29c7e3653239d4376dc",
".git/objects/d3/58c926cdc0b034aea2c85982fca3ce181c7930": "2a746026043da2b5348e919ecfa67fd6",
".git/objects/d4/3532a2348cc9c26053ddb5802f0e5d4b8abc05": "3dad9b209346b1723bb2cc68e7e42a44",
".git/objects/d7/7cfefdbe249b8bf90ce8244ed8fc1732fe8f73": "9c0876641083076714600718b0dab097",
".git/objects/d9/5b1d3499b3b3d3989fa2a461151ba2abd92a07": "a072a09ac2efe43c8d49b7356317e52e",
".git/objects/dd/a4468b167f2e1cf00261321944e5dc249ab2df": "5a53a4620ce1572ae6d39954318d3a2f",
".git/objects/e0/0b31db35e1b02d94e6e8ac75bc3a51720390a4": "146b801753eddb03f3d35a10a06d929b",
".git/objects/e9/94225c71c957162e2dcc06abe8295e482f93a2": "2eed33506ed70a5848a0b06f5b754f2c",
".git/objects/eb/5148a2a52f6b5b1f01cfdf74914ec88c82a14d": "527392c00b8a6cbe3fe1240f56f7c0bd",
".git/objects/f3/3e0726c3581f96c51f862cf61120af36599a32": "afcaefd94c5f13d3da610e0defa27e50",
".git/objects/f5/72b90ef57ee79b82dd846c6871359a7cb10404": "e68f5265f0bb82d792ff536dcb99d803",
".git/objects/f6/674c7aabd0a322b408fcd72fd9a8dce9991f0a": "872c8f41e0f95810f545a3b0ea1d6036",
".git/objects/f6/e6c75d6f1151eeb165a90f04b4d99effa41e83": "95ea83d65d44e4c524c6d51286406ac8",
".git/objects/f7/5445f017413cd51b973928329a47af1812e6fd": "1bfd9dca7ab0cee53743e63024b7a9ff",
".git/objects/f7/e796d954e9022fa4e9ae85ba43d564bc6904c1": "a3ec6e8bd5c46547231b500bbffc53c8",
".git/objects/fc/0fe0fcddc8f9a448169b40b0847285e9c21d31": "a3a9cf52c3d490ebc13feb4b552f61b7",
".git/objects/fd/05cfbc927a4fedcbe4d6d4b62e2c1ed8918f26": "5675c69555d005a1a244cc8ba90a402c",
".git/refs/heads/master": "5f859f76bb99552792efb8df2cbd85d2",
".git/refs/remotes/origin/main": "5f859f76bb99552792efb8df2cbd85d2",
"assets/AssetManifest.bin": "8a65bc23bc1c05853571950d063d2569",
"assets/AssetManifest.bin.json": "88b43c1ef3fdddb9c8b0e4cdb331baee",
"assets/assets/5823666691068595585.jpg": "ae2d94ba3e76c990c295c8e1ba184c45",
"assets/assets/product%2520pics/5823666691068595617.jpg": "df3b92a25181ce88d1666210d1b5aae2",
"assets/assets/product%2520pics/5823666691068595618.jpg": "f1412947fe24a0fad91ec5dde9d11b46",
"assets/assets/product%2520pics/5823666691068595619.jpg": "139cd0d5f9d847cbb8e86e392909d242",
"assets/assets/product%2520pics/5823666691068595620.jpg": "59aa4734d5dff772f635c8d2edf4e058",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "9e41838e272eb5d98d30e58375388c32",
"assets/NOTICES": "bbd7abf38df7e4ddb993adcf558e5490",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "e532a87be1394d9d52c2c2494c59d8b4",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "8c73c897ece39a413baca17cd38c0dcd",
"icons/Icon-192.png": "eafeca1f9a996710e33ac101eb4ce0a3",
"icons/Icon-512.png": "1c54f5ce89fc2bbea7b9e9de8d258556",
"icons/Icon-maskable-192.png": "eafeca1f9a996710e33ac101eb4ce0a3",
"icons/Icon-maskable-512.png": "1c54f5ce89fc2bbea7b9e9de8d258556",
"index.html": "bd3003957bb0629205691840b1ed756c",
"/": "bd3003957bb0629205691840b1ed756c",
"main.dart.js": "836b77b7987d56eb6c0c6d98953a4876",
"manifest.json": "73fdbb85c9d685649c03c03d5cb13bbd",
"version.json": "074b096ac140eb088028f0d0b888e810"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
