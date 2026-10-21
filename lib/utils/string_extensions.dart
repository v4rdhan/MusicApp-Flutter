import 'package:html_unescape/html_unescape.dart';

final _htmlUnescape = HtmlUnescape();

extension CleanHtml on String {
  String cleanHtml() => _htmlUnescape.convert(this);
}