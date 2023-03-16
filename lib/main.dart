import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const primaryColor = Color.fromARGB(255, 108, 168, 110);
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: primaryColor),
      home: ArticlesScreen(),
    );
  }
}

class ArticlesScreen extends StatefulWidget {
  @override
  _ArticlesScreenState createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  List<Article> _articles = [];

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  void _fetchArticles() async {
    var response2 = await http.get(Uri.parse(
        'http://api.nytimes.com/svc/mostpopular/v2/viewed/7.json?api-key=M70JkZFulue0QumafZlYE6jMzRFUkE5j'));
    final response = response2;

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      setState(() {
        _articles = (jsonData['results'] as List)
            .map((item) => Article.fromJson(item, title: jsonData))
            .toList();
      });
    } else {
      print('Error fetching articles: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    BuildContext searchValue;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(context: context, delegate: Mydelegete());
              },
              icon: Icon(Icons.search))
        ],
        title: Text("Ny Popular Articles"),
        backgroundColor: primaryColor,
      ),
      body: ListView.builder(
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(),
            leading: Image.network(_articles[index].imageUrl),
            trailing: Icon(color: primaryColor, Icons.arrow_forward_ios),
            title: Text(_articles[index].title),
            subtitle: Text(_articles[index].snippet),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailsScreen(
                    article: _articles[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final fieldText = TextEditingController();
void clearText(String query) {
  fieldText.clear();
}

class Mydelegete extends SearchDelegate {
  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: Icon(Icons.arrow_back),
      );

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            onPressed: () {
              if (query.isEmpty) {
                close(context, null);
              } else
                (query.isNotEmpty);
              {}
            },
            icon: Icon(Icons.clear))
      ];

  @override
  Widget buildResults(BuildContext context) => Container(
        margin: EdgeInsets.only(left: 10),
        padding: EdgeInsets.all(15),
      );
  @override
  Widget buildSuggestions(BuildContext context) => ListView();
}

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  ArticleDetailsScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(article.imageUrl),
            SizedBox(height: 16),
            Text(
              article.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              article.publishDate,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                article.snippet,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Article {
  final String title;
  final String snippet;
  final String imageUrl;
  final String publishDate;
  final String fullText;

  Article({
    required this.title,
    required this.snippet,
    required this.imageUrl,
    required this.publishDate,
    required this.fullText,
  });

  factory Article.fromJson(Map<String, dynamic> json, {required title}) {
    final media = json['media']?.first['media-metadata']?.first;
    final imageUrl = media != null ? media['url'] : '';

    return Article(
      title: json['title'],
      snippet: json['abstract'],
      imageUrl: imageUrl,
      publishDate: json['published_date'],
      fullText: json['url'],
    );
  }
}
