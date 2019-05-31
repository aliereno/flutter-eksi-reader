import 'package:flutter/material.dart';
import 'dart:core';
import 'package:http/http.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom; 
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_view/flutter_html_view.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  List<Topic> topics = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ekşi with Flutter',
      debugShowCheckedModeBanner: false,
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

    var document = parse(response.body);
    var topicset = document.querySelectorAll('ul.topic-list > li > a');
    List<Topic> localListTopics = [];
    
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
        localListTopics.add(topicObject);
      }
    }
    setState((){
      listTopics = localListTopics;
    });
    return "Success";
  }

  Future<Null> refreshList() async {
    setState((){
      listTopics = [];
      print("*********REFRESHED*********");
      getTopics();
    });

    return null;
  } 

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Ekşi with Flutter"),
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: refreshList)
          ],
        ),
        body: new ListView.builder(
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
                      onTap: () {
                        Navigator.push(context, 
                          new MaterialPageRoute(builder: (context) => TopicDetail(listTopics[index]))
                        );
                      },
                    )
                  ],
                )));
              })
          );
  }
}

class TopicDetail extends StatelessWidget {
  Topic topicObject;
  TopicDetail(this.topicObject);
  List topics;
  List posts;
  int pages;
  List<Post> listPosts = [];
  String url; 

  Future getPosts() async {
    url = "https://eksisozluk.com" + topicObject.url;
    var client = Client();
    Response response = await client.get(url);
    var document = parse(response.body);
    var postset = document.querySelectorAll('#entry-item-list > li');
    
    for (var post in postset) { 
      var vContent = post.querySelector('div.content').text;
      var vAuthor = post.attributes['data-author']; 
      var vFavCount = post.attributes['data-favorite-count']; 
      var vDate = post.querySelector('footer > div.info > a.entry-date.permalink').text; 
      Post postObject = new Post();
      postObject.author = vAuthor;
      postObject.content = vContent;
      postObject.date = vDate;
      postObject.favoriteCount = vFavCount;

      listPosts.add(postObject);
    }

    return listPosts;
  }
  @override
  Widget build (BuildContext ctxt) {
    return new Scaffold(
      appBar: new AppBar(
        centerTitle: true,
        title: FittedBox(fit:BoxFit.fitWidth, 
        child: Text(topicObject.title)
        )
      ),
      body: Container(
          child: FutureBuilder(
            future: getPosts(),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text("Loading...")
                  )
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(   
                      title: Text(snapshot.data[index].content.toString()),
                      subtitle: Text(snapshot.data[index].favoriteCount+" fav | "+snapshot.data[index].author +" | " +snapshot.data[index].date, textAlign: TextAlign.right,),
                    );
                  },
                );
              }
            },
          ),
        ),
    );
  }
}

class Post {
    String author;
    String content;
    String favoriteCount;
    String date;
    bool self;
}
class Topic {
    String title;
    String url;
    int comments;
    bool self;
}