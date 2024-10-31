import 'dart:math';

import 'package:folks_app/models/article.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


Future<List<Article>> fetchArticles() async {
  final response = await http.get(
    Uri.parse('https://news-api14.p.rapidapi.com/v2/search/articles?language=en&query=UN SDG'),
    headers: {
      'x-rapidapi-key': '4f4db97a3bmsh97af06e218c97eap1b238ajsn7a5f20cd8acf',
    },
    )
  
  ;
  
  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body)['data'];
    List<Article> articles = data.map((json) => Article.fromJson(json)).toList();


    return articles;
  } else {
    throw Exception('Error $e');
  }
}
