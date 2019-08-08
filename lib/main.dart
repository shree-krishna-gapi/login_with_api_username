
import 'package:flutter/material.dart';
import './api_services.dart';
void main() => runApp(App());

class Urls {
//  static const BASE_API_URL = "https://jsonplaceholder.typicode.com";
  static const BASE_API_URL = "https://jsonplaceholder.typicode.com";
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Login()
    );
  }
}


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}
class _LoginState extends State<Login> {
//  var _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _usernameController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log in'),),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
//          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('username is: Bret'),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Username'
                ),
                controller: _usernameController,

              ),
              Container(height: 20,),
              _isLoading ? CircularProgressIndicator() : SizedBox(
                height: 40,
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    'Log in',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {

                    setState(() {
                      _isLoading = true;
                    });
                    final users = await ApiService.getUserList();
                    setState(() {
                      _isLoading = false;
                    });
                    // _usernameController.text is working -> userinput text
                    // userWithUsernameExists is bool -> false
  //                  final userWithUsernameExists == usernameController.text);

                    final userWithUsernameExists = users.any((u) => u == _usernameController.text.toUpperCase() );
                    print(userWithUsernameExists);
                    if (_usernameController.text == '') { // users == null
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Username is Empty'),
                            );
                          }
                      );
                      return;
                    } else {
                      if (userWithUsernameExists) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Username is Match!'),
                              );
                            }
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Posts()
                            )
                        );
                      } else {
                        print('something wrong');
                        print(users.any((u) => u['username']));
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Incorrect username'),
                              );
                            }
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Posts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Posts'),),
      body: FutureBuilder(
        future: ApiService.getPostList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final posts = snapshot.data;
            return ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(height: 2, color: Colors.black,);
              },
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    posts[index]['title'],
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(posts[index]['body']),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Post(posts[index]['id'])
                        )
                    );
                  },
                );
              },
              itemCount: posts.length,
            );
          }
          return Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }
}

class Post extends StatelessWidget {
  final int _id;

  Post(this._id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post'),),
      body: Column(
        children: <Widget>[
          FutureBuilder(
            future: ApiService.getPost(_id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: <Widget>[
                    Text(
                      snapshot.data['title'],
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(snapshot.data['body']),
                  ],
                );
              }
              return Center(child: CircularProgressIndicator(),);
            },
          ),
          Container(height: 20,),
          Divider(color: Colors.black, height: 3,),
          Container(height: 20,),
          FutureBuilder(
            future: ApiService.getCommentsForPost(_id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final comments = snapshot.data;
                return Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) => Divider(height: 2, color: Colors.black,),
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Text(
                            comments[index]['name'],
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(comments[index]['body'])
                      );
                    },
                    itemCount: comments.length,
                  ),
                );
              }
              return Center(child: CircularProgressIndicator(),);
            },
          )
        ],
      ),
    );
  }
}