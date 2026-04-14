// Service Worker for PWA functionality
// Bump this value on CSS/static updates to force clients to refresh cached assets
const CACHE_NAME = 'iacls-cache-v2';
const urlsToCache = [
  // Root entry (when SW is installed at root scope)
  '/',
  // Support Django-served static paths
  '/static/manifest.json',
  '/static/styles.css',
  '/static/script.js',
  '/static/acls.js',
  // Support packaged / relative paths (when web assets are bundled into app webDir)
  'manifest.json',
  'styles.css',
  'script.js',
  'acls.js',
  // Add other static files as needed
];

// Install event - cache resources
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Opened cache');
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch event - serve network-first for styles.css to avoid stale CSS during development
self.addEventListener('fetch', (event) => {
  const requestURL = new URL(event.request.url);

  // If request is for the main stylesheet, try network first then fall back to cache
  if (requestURL.pathname.endsWith('/static/styles.css') || requestURL.pathname.endsWith('/styles.css')) {
    event.respondWith(
      fetch(event.request)
        .then((networkResponse) => {
          // Update cache with fresh copy
          caches.open(CACHE_NAME).then((cache) => {
            try { cache.put(event.request, networkResponse.clone()); } catch (e) { /* ignore */ }
          });
          return networkResponse.clone();
        })
        .catch(() => caches.match(event.request))
    );
    return;
  }

  // Default behavior: try cache first, then network
  event.respondWith(
    caches.match(event.request)
      .then((response) => response || fetch(event.request))
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
