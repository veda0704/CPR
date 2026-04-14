import urllib.request, urllib.parse, http.cookiejar, re

cj = http.cookiejar.CookieJar()
opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
# fetch homepage to get csrf token and cookies
r = opener.open('http://127.0.0.1:8000/')
html = r.read().decode()
# find csrf token in hidden input
m = re.search(r'name=["\']csrfmiddlewaretoken["\'] value=["\']([^"\']+)["\']', html)
if not m:
    print('NO_CSRF')
    raise SystemExit(1)

token = m.group(1)
# prepare POST to built-in setlang
data = urllib.parse.urlencode({'language': 'te'}).encode()
req = urllib.request.Request('http://127.0.0.1:8000/i18n/setlang/', data=data, headers={'X-CSRFToken': token, 'Referer': 'http://127.0.0.1:8000/'})
resp = opener.open(req)
print('POST_STATUS', resp.getcode())
page = opener.open('http://127.0.0.1:8000/').read().decode()
print(page[:1200])
