
import 'package:folks_app/constants/placeholderURL.dart';

class Article {
  final String title;
  final String excerpt;
  final String publisherName;
  final String publisherFavicon;
  final String date;
  final String url;
  final String thumbnail;

  Article({
    required this.title,
    required this.excerpt,
    required this.publisherName,
    required this.publisherFavicon,
    required this.date,
    required this.url,
    required this.thumbnail,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] ?? '',
      excerpt: json['excerpt'] ?? '',
      publisherName: json['publisher']['name'] ?? '',
      publisherFavicon: json['publisher']['favicon'] ?? userPlaceholder,
      date: json['date'] ?? '',
      url: json['url'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
    );
  }
}
