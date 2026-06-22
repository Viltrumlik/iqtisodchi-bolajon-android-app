/// Formats an integer amount as Uzbek so'm: e.g. 37000 → "37 000 so'm".
String formatMoney(int amount) {
  if (amount == 0) return "0 so'm";
  final s = amount.toString();
  final buf = StringBuffer();
  int cnt = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (cnt > 0 && cnt % 3 == 0) buf.write(' '); // non-breaking space
    buf.write(s[i]);
    cnt++;
  }
  return "${buf.toString().split('').reversed.join()} so'm";
}
