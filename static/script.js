// http://snipplr.com/view/5327/elapsed-time-string-from-time-in-seconds/
function elapsedTime (createdAt)
{
  var ageInSeconds = Math.ceil((new Date().getTime() / 1000) - createdAt);
  var s = function(n) { return n == 1 ? '' : 's' };
  if (ageInSeconds < 0) {
    return 'just now';
  }
  if (ageInSeconds < 60) {
    var n = ageInSeconds;
    return n + ' second' + s(n) + ' ago';
  }
  if (ageInSeconds < 60 * 60) {
    var n = Math.floor(ageInSeconds/60);
    return n + ' minute' + s(n) + ' ago';
  }
  if (ageInSeconds < 60 * 60 * 24) {
    var n = Math.floor(ageInSeconds/60/60);
    return n + ' hour' + s(n) + ' ago';
  }
  if (ageInSeconds < 60 * 60 * 24 * 7) {
    var n = Math.floor(ageInSeconds/60/60/24);
    return n + ' day' + s(n) + ' ago';
  }
  if (ageInSeconds < 60 * 60 * 24 * 31) {
    var n = Math.floor(ageInSeconds/60/60/24/7);
    return n + ' week' + s(n) + ' ago';
  }
  if (ageInSeconds < 60 * 60 * 24 * 365) {
    var n = Math.floor(ageInSeconds/60/60/24/31);
    return n + ' month' + s(n) + ' ago';
  }
  var n = Math.floor(ageInSeconds/60/60/24/365);
  return n + ' year' + s(n) + ' ago';
}
