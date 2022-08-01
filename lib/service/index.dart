String stationUrl(url, [bool? isProxy]) {
  if (isProxy == null || isProxy == false) {
    return 'http://' + url;
  } else {
    return url;
  }
}
