String stationUrl(String url, String path) {
  bool isDomain = url.contains(':');
  return (!isDomain) ? 'http://seojun.ddns.net' + path + '/?id=' + url : 'http://' + url + path;
}
