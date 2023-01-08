import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  int page = 1;
  bool isLoading = false;
  List posts = [];
  final client = http.Client();
  ScrollController _scrollController = ScrollController();
  double _scrollPosition = 0.0;
  double _scrollTop = 0.0;
  var postFuture;

  @override
  void initState(){
    postFuture = getData();
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() async{
   
    _scrollPosition = _scrollController.position.pixels;
    _scrollTop = _scrollController.position.maxScrollExtent;
    


    if(_scrollPosition >= _scrollTop - 300 && isLoading == false){
      
      page = page + 1;
      
      setState(() {
        postFuture = getData();
      });
      
    }
    
  }

  Future<List> getData() async{

    isLoading = true;

    String url = "https://jsonplaceholder.typicode.com/posts?_limit=20&_page=${page}";
    
    final response = await client.get(Uri.parse(url));
    
    List data = json.decode(response.body);

    data.forEach((element) { 
      posts.add(element);
    });

    isLoading = false;
    
    return posts;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("FutureBuilder"),
      ),
      body: FutureBuilder(
      future: postFuture,
      builder:(context, AsyncSnapshot snapshot) {
        
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              
              return Container(
                margin: EdgeInsets.only(top: 5, bottom: 5),
                padding: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 3)
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(snapshot.data[index]["title"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Text(snapshot.data[index]["body"]),
                  ],
                ),
              );

            }
          );
        }
        
      }
    )
      
    );
  }
}
