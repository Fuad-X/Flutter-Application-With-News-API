import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The news app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Welcome to the news app',
                style:TextStyle(fontSize: 46, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center
            ),
            Padding(padding: const EdgeInsets.only(bottom: 350.0)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Let\'s start', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final String correctUsername = 'user';
  final String correctPassword = 'pass';

  void _login() {
    if (_usernameController.text == correctUsername && _passwordController.text == correctPassword) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NewsScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Incorrect username or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('The news app',
                  style: TextStyle(fontSize: 46, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center
              ),
              Padding(padding: const EdgeInsets.only(bottom: 300.0)),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              Padding(padding: const EdgeInsets.only(bottom: 100.0)),
              ElevatedButton(
                onPressed: _login,
                child:Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 90.0,),
                  child:  Text('Login', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Don\'t have a account? Create one',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final String apiKey = '8d61c6dd93dd4f4aa33501657eb347ea'; // Replace with your actual NewsAPI key
  String apiUrl = 'https://newsapi.org/v2/top-headlines?country=us&apiKey=';
  List articles = [];
  int currentArticleIndex = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(Uri.parse('$apiUrl$apiKey'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        articles = data['articles'] ?? [];
        isLoading = false;
        print(articles);
      });
    } else {
      print('Failed to load news: ${response.statusCode}');
      print('Response body: ${response.body}');
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load news');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'News Reader',
          style: TextStyle(
            color: Colors.white,
            ),
        ),
        backgroundColor: Colors.blue[900],
      ),
      backgroundColor: Colors.lightBlue[200],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
          ? Center(child: Text('No news available'))
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            margin: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 4.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Stack(
                children: [
                  Container(
                    color: Colors.lightBlue[100],
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Text(
                        articles[currentArticleIndex]['title'] ?? 'No title',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        articles[currentArticleIndex]["publishedAt"] ?? 'No date',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,-
                MaterialPageRoute(
                  builder: (context) => ArticleDetailScreen(url: articles[currentArticleIndex]['url']),
                ),
              );
            },
            child: Text('Read Full Article', style: TextStyle(color: Colors.blue, fontSize: 24,),),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentArticleIndex =
                    (currentArticleIndex + 1) % articles.length;
              });
            },
            child: Text('Next', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleDetailScreen extends StatelessWidget {
  final String url;

  ArticleDetailScreen({required this.url}){
    print('URL: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Article',
          style: TextStyle(color: Colors.white,),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
