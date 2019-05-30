import 'package:flutter/material.dart';
import 'dart:core';
import 'package:http/http.dart'; // Contains a client for making API calls
import 'package:html/parser.dart'; // Contains HTML parsers to generate a Document object
import 'package:html/dom.dart' as dom; // Contains DOM related classes for extracting data from elements


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  String BASE_URL = "https://www.reddit.com";
  String COMMENTS_BASE_URL = "https://eksisozluk.com";

  String currentTopic = "";
  List<Topic> topics = [];
  List<Post> posts = [];
  bool loading = true;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekşi with Flutter',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: new HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage>{

  final String url="https://eksisozluk.com";
  List topics;
  List posts;
  List<Topic> listTopics = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState(){
    super.initState();
    this.getTopics();
  }
  Future getTopics() async {

    var client = Client();
    Response response = await client.get(url);

    // Use html parser and query selector
    var document = parse(response.body);
    var topicset = document.querySelectorAll('ul.topic-list > li > a');
    
    for (var topic in topicset) {
      if(topic.text.isNotEmpty){
        List<String> tempA = topic.text.replaceAll("\n", "").split(' ');
        String lastElement = tempA.removeLast();
        String tempTitle = tempA.join(' ');
        int tempComments = int.parse(lastElement);
        Topic topicObject = new Topic();
        topicObject.title = tempTitle;
        topicObject.comments = tempComments;
        topicObject.url = topic.attributes['href'];
        listTopics.add(topicObject);
      }
    }
    topics = listTopics;
    
    setState(() {
      topics = listTopics;
    });
    return "Success";
  }
  Future getPosts(Topic topic) async {
    var newUrl = url + topic.url; 
    var client = Client();
    Response response = await client.get(newUrl);

    // Use html parser and query selector
    var document = parse(response.body);
    topics = document.querySelectorAll('ul.entry-item-list > li');
    
    List<Topic> listTopics = [];
    for (var topic in topics) {
      if(topic.text.isNotEmpty){
        List<String> tempA = topic.text.replaceAll("\n", "").split(' ');
        String lastElement = tempA.removeLast();
        String tempTitle = tempA.join(' ');
        int tempComments = int.parse(lastElement);
        Topic topicObject = new Topic();
        topicObject.title = tempTitle;
        topicObject.comments = tempComments;
        topicObject.url = topic.attributes['href'];
        listTopics.add(topicObject);
      }
    }
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show(atTop: false);
    await Future.delayed(Duration(seconds: 2));

    setState((){
      listTopics = [];
      print("*********REFRESHED*********");
      getTopics();
    });

    return null;
  } 

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Ekşi with Flutter"),
        ),
        body: RefreshIndicator(
        key: refreshKey,        
        child: new ListView.builder(
            itemCount: listTopics == null ? 0 : listTopics.length,
            itemBuilder: (BuildContext context, int index) {
              return new Container(
                  child: new Center(
                      child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    new ListTile(
                      title: new Text(listTopics[index].title),
                      trailing: new Text(listTopics[index].comments.toString()),
                    )
                  ],
                )));
              }),
              onRefresh: refreshList,
              ));
  }
}

class Post {
    String author;
    String content;
    String favoriteCount;
    bool self;
}
class Topic {
    String title;
    String url;
    int comments;
    bool self;
}