import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'statistics.dart';

// 这是请求的域名，如果最终部署在服务器需要将这个改成http://lancelotshire.me/... 巴拉巴拉
// 测试时设置为http://127.0.0.1:8000
// ignore: constant_identifier_names
const String URL = 'http://127.0.0.1:8000';

late int Account;
late int UserType;
late String Username;
late int BorrowDays;

bool isNumeric(String str) {
  return double.tryParse(str) != null && double.tryParse(str)! >= 0;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '山东大学图书管理系统',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
          fontFamily: 'CustomFont'),
      home: LoginPage(),
    );
  }
}

void simpleDialog(BuildContext context, String message, String title) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('关闭'))
          ],
        );
      });
}

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final _account = TextEditingController();
  final _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('山东大学图书管理系统'),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Image.asset('assets/image/logo.jpg'),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                  controller: _account,
                  decoration: InputDecoration(
                      hintText: '账号',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0)))),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                  obscureText: true,
                  controller: _password,
                  decoration: InputDecoration(
                      hintText: '密码',
                      prefixIcon: const Icon(Icons.password),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0)))),
            ),
            Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                    onPressed: () async {
                      var password = _password.text;

                      if (_account.text == "" || password == "") {
                        var message = "账号或密码不能为空！";
                        loginDialog(context, message);
                      } else {
                        int account = int.parse(_account.text);

                        var data = {
                          'account': account,
                          'password': password,
                        };

                        var res = await http.post(
                          Uri.parse('$URL/login'),
                          headers: {
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(data),
                        );

                        if (res.statusCode == 200) {
                          var body =
                              json.decode(utf8.decode(res.body.runes.toList()));
                          bool token = body["token"];
                          int userType = body["userType"];
                          String message = body["message"];
                          String userName = body["userName"];

                          Account = account;
                          UserType = userType;
                          Username = userName;

                          if (token) {
                            if (UserType == 2) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyHomePage(
                                      title: '图书管理系统',
                                      account: Account,
                                      userType: UserType,
                                    ),
                                  ));
                              loginDialog(context, message);
                            } else if (UserType == 1) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AdminHomePage(
                                      title: '图书管理系统',
                                      account: Account,
                                      userType: UserType,
                                    ),
                                  ));
                              loginDialog(context, message);
                            } else {
                              simpleDialog(
                                  context,
                                  "由于某些原因,你的账号被管理员封禁,请联系管理员解封,账号: $Account",
                                  "登录信息");
                            }
                          } else {
                            loginDialog(context, message);
                          }
                        } else {
                          var message = "错误！错误代码：${res.statusCode}";
                          loginDialog(context, message);
                        }
                      }
                    },
                    child: const Text('登录')))
          ],
        )));
  }
}

void loginDialog(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('登录信息'),
          content: Text(message),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('关闭'))
          ],
        );
      });
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.account,
    required this.userType,
  });

  final String title;

  final int account;

  final int userType;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class HttpReq {
  Future test() async {
    var url = Uri.parse('$URL/');
    var res = await http.get(url);

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future search(String item) async {
    var res = await http.get(Uri.parse('$URL/search?param=$item'));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future searchPeople(String item) async {
    var res = await http.get(Uri.parse('$URL/searchPeople?param=$item'));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future find(int account) async {
    var res = await http.get(Uri.parse('$URL/find?account=$account'));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future updatePersonalName(int account, String name) async {
    var data = {'name': name};
    var res = await http.put(Uri.parse('$URL/updatePersonalName/{$account}'),
        body: data);
    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getBorrowedBook(int? account) async {
    http.Response res;
    if (account == null) {
      res = await http.get(Uri.parse('$URL/getAllBorrowedBook'));
    } else {
      res = await http.get(Uri.parse('$URL/getBorrowedBook?account=$account'));
    }

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getBorrowDays() async {
    var res = await http.get(Uri.parse('$URL/getBorrowDays'));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getRecentlyReturn(int account) async {
    var res =
        await http.get(Uri.parse('$URL/getRecentlyReturn?account=$account'));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }

  Future getMostPopular() async {
    var res = await http.get(Uri.parse('$URL/getMostPopular'));

    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));
      return body;
    } else {
      return null;
    }
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final _searchBox = TextEditingController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void refresh() {
    setState(() {
      _buildBody(_selectedIndex);
      _buildDrawer();
    });
  }

  String _buildText() {
    String text =
        "欢迎使用山东大学图书管理系统,$Username!\n今天想看点什么?\n\n您当前使用的是一个读者账户,可以自由借/还图书\n\n目前管理员设置的借书最久时间是(单位:天):";
    return text;
  }

  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return SingleChildScrollView(
            child: Center(
                child: Column(children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset("assets/image/logo.png"),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CustomFont'),
              children: [
                TextSpan(text: _buildText()),
              ],
            ),
          ),
          FutureBuilder(
              future: HttpReq().getBorrowDays(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  BorrowDays = snapshot.data;
                  var str = BorrowDays.toString();
                  return Center(
                      child: Text(str,
                          style: const TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold)));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CustomFont'),
              children: [
                TextSpan(text: "您最近要还的三本书(可能不足三本):"),
              ],
            ),
          ),
          FutureBuilder(
              future: HttpReq().getRecentlyReturn(Account),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List data = snapshot.data;
                  String recentlyReturn = "";
                  for (int i = 0; i < min(3, data.length); i++) {
                    recentlyReturn = "$recentlyReturn${data[i][0]} ";
                  }
                  return Center(
                      child: Text(
                    recentlyReturn,
                    style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'CustomFont'),
                  ));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CustomFont'),
              children: [
                TextSpan(text: "大家都在借的三本书(可能不足三本):"),
              ],
            ),
          ),
          FutureBuilder(
              future: HttpReq().getMostPopular(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List data = snapshot.data;
                  String recentlyReturn = "";
                  for (int i = 0; i < min(3, data.length); i++) {
                    recentlyReturn = "$recentlyReturn${data[i][0]} ";
                  }
                  return Center(
                      child: Text(
                    recentlyReturn,
                    style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'CustomFont'),
                  ));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
        ])));
      case 1:
        return Column(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchBox,
                onSubmitted: (value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchPage(
                                searchQuery: value,
                                mode: 1,
                                callback: refresh,
                              )));
                },
                decoration: InputDecoration(
                  hintText: '搜索书籍……',
                  prefixIcon: const Icon(Icons.search),
                  suffix: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage(
                                      searchQuery: _searchBox.text,
                                      mode: 1,
                                      callback: refresh,
                                    )));
                      },
                      child: const Text("模糊搜索")),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                ),
              )),
          Expanded(
              child: FutureBuilder(
                  future: HttpReq().search(""),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                          child: DataTable(
                        columns: const [
                          DataColumn(label: Text('书名')),
                          DataColumn(label: Text('作者')),
                          DataColumn(label: Text('ISBN')),
                          DataColumn(label: Text('类别')),
                          DataColumn(label: Text('数量')),
                          DataColumn(label: Text('操作'))
                        ],
                        rows: getRows(snapshot.data, context, refresh),
                        dividerThickness: 1.0, // 设置分割线厚度
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black), // 设置分割线颜色
                        ),
                      ));
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("错误！请重试！"),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }))
        ]);
      case 2:
        return Center(
            child: SingleChildScrollView(
                child: FutureBuilder(
                    future: HttpReq().getBorrowedBook(Account),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('借阅号')),
                            DataColumn(label: Text('昵称')),
                            DataColumn(label: Text('账号')),
                            DataColumn(label: Text('书名')),
                            DataColumn(label: Text('ISBN')),
                            DataColumn(label: Text('借书时间')),
                            DataColumn(label: Text('还书时间')),
                            DataColumn(label: Text('操作'))
                          ],
                          rows: getRowsOfCurrentBorrowedBook(
                              snapshot.data, context, refresh),
                          dividerThickness: 1.0, // 设置分割线厚度
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // 设置分割线颜色
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("错误！请重试！"),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })));
      default:
        return const Center(child: Text('Unknown Page!'));
    }
  }

  List<DataRow> getRowsOfCurrentBorrowedBook(
      List<dynamic> list, BuildContext context, Function callback) {
    List<DataRow> rows = [];
    for (int i = 0; i < list.length; i++) {
      List<dynamic> elem = list[i];
      List<DataCell> row = [];
      if (elem[6] != null) {
        continue;
      }
      for (int j = 0; j <= 5; j++) {
        row.add(DataCell(Text(elem[j].toString())));
      }
      row.add(const DataCell(Text("尚未归还")));
      row.add(DataCell(ElevatedButton(
        onPressed: () {
          returningButtonOnPressGenerator(elem[0], context, callback);
        },
        child: const Text('归还'),
      )));
      DataRow dataRow = DataRow(cells: row);
      rows.add(dataRow);
    }
    return rows;
  }

  Future<void> returningButtonOnPressGenerator(
      int borrowingId, BuildContext context, Function callback) async {
    var title = "归还信息";
    var message = "确定要归还么?";
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('确认'),
                onPressed: () async {
                  callback();
                  var res = await http.get(
                      Uri.parse('$URL/isNotReturned?borrowingId=$borrowingId'));

                  if (res.statusCode == 200) {
                    var body =
                        json.decode(utf8.decode(res.body.runes.toList()));
                    var result = body['result'];
                    message = body['message'];

                    if (result) {
                      var data = {'borrowingId': borrowingId};

                      res = await http.post(
                        Uri.parse('$URL/returnABook'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(data),
                      );

                      if (res.statusCode == 200) {
                        body =
                            json.decode(utf8.decode(res.body.runes.toList()));
                        result = body['result'];
                        message = body['message'];

                        if (result) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(title),
                                  content: Text(message),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          callback();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('关闭'))
                                  ],
                                );
                              });
                        } else {
                          simpleDialog(context, message, title);
                        }
                      } else {
                        message = "归还失败! 错误代码: ${res.statusCode}";
                        simpleDialog(context, message, title);
                      }
                    } else {
                      simpleDialog(context, message, title);
                    }
                  } else {
                    message = "归还鉴权失败! 错误代码: ${res.statusCode}";
                    simpleDialog(context, message, title);
                  }
                },
              ),
            ],
          );
        });
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.cyanAccent,
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset('assets/image/avatar.png'),
                    ),
                    const SizedBox(height: 5),
                    Text(Username),
                    Text(() {
                      if (widget.userType == 1) {
                        return "管理员账户";
                      } else {
                        return "读者账户";
                      }
                    }())
                  ],
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_2),
            title: const Text('修改个人信息'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PersonalProfilePage(
                          account: Account, callback: refresh)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('借阅记录'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          BorrowHistoryPage(callback: refresh)));
            },
          ),
          ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('退出'),
              onTap: () {
                logoutDialog(context);
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                refresh();
              },
            ),
          ],
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Image.asset('assets/image/avatar.png'),
            );
          })),
      body: _buildBody(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '搜索'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '目前借阅'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      drawer: _buildDrawer(),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({
    super.key,
    required this.title,
    required this.account,
    required this.userType,
  });

  final String title;

  final int account;

  final int userType;

  @override
  State<StatefulWidget> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  FloatingActionButton? _floatButtonBuilder(int index) {
    switch (index) {
      case 2:
        return FloatingActionButton(
          onPressed: addMemberDialog,
          tooltip: '添加新的用户',
          child: const Icon(Icons.add),
        );
      case 1:
        return FloatingActionButton(
          onPressed: addBookDialog,
          tooltip: '添加新的书籍',
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  void addMemberDialog() {
    var controller1 = TextEditingController();
    var controller2 = TextEditingController();
    var controller3 = TextEditingController();
    var controller4 = TextEditingController();
    var controller5 = TextEditingController();
    var controller6 = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              scrollable: true,
              title: const Text('添加新的用户'),
              content: Column(
                children: [
                  TextField(
                    controller: controller1,
                    decoration: const InputDecoration(
                      hintText: '昵称',
                    ),
                  ),
                  TextField(
                    controller: controller2,
                    decoration: const InputDecoration(
                      hintText: '账号',
                    ),
                  ),
                  TextField(
                    controller: controller3,
                    decoration: const InputDecoration(
                      hintText: '账户类型(1为管理员,2为读者)',
                    ),
                  ),
                  TextField(
                    controller: controller4,
                    decoration: const InputDecoration(
                      hintText: '最大可借书数量',
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: controller5,
                    decoration: const InputDecoration(
                      hintText: '输入密码',
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: controller6,
                    decoration: const InputDecoration(
                      hintText: '再输入一次密码',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  onPressed: () {
                    addMember(
                        controller1.text,
                        controller2.text,
                        controller3.text,
                        controller4.text,
                        controller5.text,
                        controller6.text);
                  },
                  child: const Text('确认'),
                ),
              ]);
        });
  }

  Future<void> addMember(String name, String account, String userType,
      String maxBorrowedBook, String password, String repassword) async {
    var title = '添加用户信息';
    if (name == "" ||
        account == "" ||
        userType == "" ||
        maxBorrowedBook == "" ||
        password == "" ||
        repassword == "") {
      var message = "存在字段不合法,重新输入! 各字段不能为空!";
      simpleDialog(context, message, title);
    } else {
      if (userType != '1' && userType != '2') {
        var message = "用户类型错误!";
        simpleDialog(context, message, title);
      } else {
        if (password != repassword) {
          var message = "两次密码不一致!";
          simpleDialog(context, message, title);
        } else {
          var data = {
            'name': name,
            'account': int.parse(account),
            'userType': int.parse(userType),
            'maxBorrowedBook': int.parse(maxBorrowedBook),
            'password': password,
          };
          var res = await http.put(
            Uri.parse('$URL/addMember'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          );

          if (res.statusCode == 200) {
            var body = json.decode(utf8.decode(res.body.runes.toList()));

            String message = body['message'];
            bool result = body['result'];

            if (result) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(title),
                      content: Text(message),
                      actions: [
                        TextButton(
                            onPressed: () {
                              refresh();
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('关闭'))
                      ],
                    );
                  });
            } else {
              simpleDialog(context, message, title);
            }
          } else {
            var message = "添加用户错误！错误代码：${res.statusCode}";
            simpleDialog(context, message, title);
          }
        }
      }
    }
  }

  void addBookDialog() {
    var controller1 = TextEditingController();
    var controller2 = TextEditingController();
    var controller3 = TextEditingController();
    var controller4 = TextEditingController();
    var controller5 = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              scrollable: true,
              title: const Text('添加新的书籍'),
              content: Column(
                children: [
                  TextField(
                    controller: controller1,
                    decoration: const InputDecoration(
                      hintText: '书名',
                    ),
                  ),
                  TextField(
                    controller: controller2,
                    decoration: const InputDecoration(
                      hintText: '作者',
                    ),
                  ),
                  TextField(
                    controller: controller3,
                    decoration: const InputDecoration(
                      hintText: 'ISBN',
                    ),
                  ),
                  TextField(
                    controller: controller4,
                    decoration: const InputDecoration(
                      hintText: '类别',
                    ),
                  ),
                  TextField(
                    controller: controller5,
                    decoration: const InputDecoration(
                      hintText: '数量',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  onPressed: () {
                    addBook(controller1.text, controller2.text,
                        controller3.text, controller4.text, controller5.text);
                  },
                  child: const Text('确认'),
                ),
              ]);
        });
  }

  // ignore: non_constant_identifier_names
  Future<void> addBook(String bookName, String author, String ISBN,
      String categoty, String count) async {
    var title = "添加数据信息";
    if (bookName == "" ||
        author == "" ||
        ISBN == "" ||
        categoty == "" ||
        count == "" ||
        !isNumeric(count)) {
      var message = "存在字段不合法,重新输入! 各字段不能为空! 数量字段必须为数字!";
      simpleDialog(context, message, title);
    } else {
      var data = {
        'bookName': bookName,
        'author': author,
        'ISBN': ISBN,
        'category': categoty,
        'count': int.parse(count)
      };

      var res = await http.put(
        Uri.parse('$URL/addBook'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        var body = json.decode(utf8.decode(res.body.runes.toList()));

        String message = body['message'];
        bool result = body['result'];

        if (result) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(title),
                  content: Text(message),
                  actions: [
                    TextButton(
                        onPressed: () {
                          refresh();
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('关闭'))
                  ],
                );
              });
        } else {
          simpleDialog(context, message, title);
        }
      } else {
        var message = "添加书籍错误！错误代码：${res.statusCode}";
        simpleDialog(context, message, title);
      }
    }
  }

  void refresh() {
    setState(() {
      _buildBody(_selectedIndex);
      _buildDrawer();
    });
  }

  String _buildText() {
    String text =
        "欢迎使用山东大学图书管理系统,$Username!\n\n您当前使用的是一个管理员账户,可以自由的管理书籍和人员\n\n目前您设置的借书最久时间是(单位:天):";
    return text;
  }

  Widget? _buildBody(int index) {
    var searchBox = TextEditingController();
    switch (index) {
      case 0:
        return SingleChildScrollView(
            child: Center(
                child: Column(children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset("assets/image/logo.png"),
          ),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CustomFont'),
              children: [
                TextSpan(text: _buildText()),
              ],
            ),
          ),
          FutureBuilder(
              future: HttpReq().getBorrowDays(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  BorrowDays = snapshot.data;
                  var str = BorrowDays.toString();
                  return Center(
                      child: Text(str,
                          style: const TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold)));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          // RichText(
          //   textAlign: TextAlign.center,
          //   text: const TextSpan(
          //     style: TextStyle(
          //         fontSize: 20.0,
          //         fontWeight: FontWeight.bold,
          //         color: Colors.black,
          //         fontFamily: 'CustomFont'),
          //     children: [
          //       TextSpan(text: "您最近要还的三本书(可能不足三本):"),
          //     ],
          //   ),
          // ),
          // FutureBuilder(
          //     future: HttpReq().getRecentlyReturn(Account),
          //     builder: (context, snapshot) {
          //       if (snapshot.hasData) {
          //         List data = snapshot.data;
          //         String recentlyReturn = "";
          //         for (int i = 0; i < min(3, data.length); i++) {
          //           recentlyReturn = "$recentlyReturn${data[i][0]} ";
          //         }
          //         return Center(
          //             child: Text(
          //           recentlyReturn,
          //           style: const TextStyle(
          //               fontSize: 30.0,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.black,
          //               fontFamily: 'CustomFont'),
          //         ));
          //       } else if (snapshot.hasError) {
          //         return const Center(
          //           child: Text("错误！请重试！"),
          //         );
          //       } else {
          //         return const Center(
          //           child: CircularProgressIndicator(),
          //         );
          //       }
          //     }),
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CustomFont'),
              children: [
                TextSpan(text: "大家都在借的三本书(可能不足三本):"),
              ],
            ),
          ),
          FutureBuilder(
              future: HttpReq().getMostPopular(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List data = snapshot.data;
                  String recentlyReturn = "";
                  for (int i = 0; i < min(3, data.length); i++) {
                    recentlyReturn = "$recentlyReturn${data[i][0]} ";
                  }
                  return Center(
                      child: Text(
                    recentlyReturn,
                    style: const TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'CustomFont'),
                  ));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              })
        ])));
      case 1:
        return Column(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: searchBox,
                onSubmitted: (value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchPage(
                                searchQuery: value,
                                mode: 1,
                                callback: refresh,
                              )));
                },
                decoration: InputDecoration(
                  hintText: '搜索书籍……',
                  prefixIcon: const Icon(Icons.search),
                  suffix: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage(
                                      searchQuery: searchBox.text,
                                      mode: 1,
                                      callback: refresh,
                                    )));
                      },
                      child: const Text("模糊搜索")),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                ),
              )),
          Expanded(
              child: FutureBuilder(
                  future: HttpReq().search(""),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                          child: DataTable(
                        columns: const [
                          DataColumn(label: Text('书名')),
                          DataColumn(label: Text('作者')),
                          DataColumn(label: Text('ISBN')),
                          DataColumn(label: Text('类别')),
                          DataColumn(label: Text('数量')),
                          DataColumn(label: Text('操作'))
                        ],
                        rows: getRows(snapshot.data, context, refresh),
                        dividerThickness: 1.0, // 设置分割线厚度
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black), // 设置分割线颜色
                        ),
                      ));
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("错误！请重试！"),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  }))
        ]);
      case 2:
        return Column(children: [
          Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: searchBox,
                onSubmitted: (value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SearchPage(
                                searchQuery: value,
                                mode: 2,
                                callback: refresh,
                              )));
                },
                decoration: InputDecoration(
                  hintText: '搜索人员……',
                  prefixIcon: const Icon(Icons.search),
                  suffix: TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage(
                                      searchQuery: searchBox.text,
                                      mode: 2,
                                      callback: refresh,
                                    )));
                      },
                      child: const Text("模糊搜索")),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
                ),
              )),
          Flexible(
            child: FutureBuilder(
                future: HttpReq().searchPeople(""),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SingleChildScrollView(
                        child: DataTable(
                      columns: const [
                        DataColumn(label: Text('昵称')),
                        DataColumn(label: Text('账号')),
                        DataColumn(label: Text('用户类型')),
                        DataColumn(label: Text('最大借书数量')),
                        DataColumn(label: Text('已借书数量')),
                        DataColumn(label: Text('操作'))
                      ],
                      rows: getPeopleRows(snapshot.data, context, refresh),
                      dividerThickness: 1.0, // 设置分割线厚度
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // 设置分割线颜色
                      ),
                    ));
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("错误! 请重试!"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          )
        ]);
      case 3:
        return Center(
            child: SingleChildScrollView(
                child: FutureBuilder(
                    future: HttpReq().getBorrowedBook(null),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('借阅号')),
                            DataColumn(label: Text('昵称')),
                            DataColumn(label: Text('账号')),
                            DataColumn(label: Text('书名')),
                            DataColumn(label: Text('ISBN')),
                            DataColumn(label: Text('借书时间')),
                            DataColumn(label: Text('还书时间')),
                          ],
                          rows: getRowsOfBorrowedBook(snapshot.data, context),
                          dividerThickness: 1.0, // 设置分割线厚度
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black), // 设置分割线颜色
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("错误！请重试！"),
                        );
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    })));
      default:
        return const Center(child: Text("Unknown Page!"));
    }
  }

  List<DataRow> getRowsOfBorrowedBook(
      List<dynamic> list, BuildContext context) {
    List<DataRow> rows = [];
    for (int i = 0; i < list.length; i++) {
      List<dynamic> elem = list[i];
      List<DataCell> row = [];
      for (int j = 0; j <= 5; j++) {
        row.add(DataCell(Text(elem[j].toString())));
      }
      if (elem[6] == null) {
        row.add(const DataCell(Text("尚未归还")));
      } else {
        row.add(DataCell(Text(elem[6].toString())));
      }
      DataRow dataRow = DataRow(cells: row);
      rows.add(dataRow);
    }
    return rows;
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.cyanAccent,
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset('assets/image/avatar.png'),
                    ),
                    const SizedBox(height: 5),
                    Text(Username),
                    Text(() {
                      if (widget.userType == 1) {
                        return "管理员账户";
                      } else {
                        return "读者账户";
                      }
                    }())
                  ],
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_2),
            title: const Text('修改个人信息'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PersonalProfilePage(
                            account: Account,
                            callback: refresh,
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置参数'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingPage(
                            callback: refresh,
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.equalizer),
            title: const Text('统计数据'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StatisticsPage()));
            },
          ),
          ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('退出'),
              onTap: () {
                logoutDialog(context);
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                refresh();
              },
            ),
          ],
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Image.asset('assets/image/avatar.png'),
            );
          })),
      body: _buildBody(_selectedIndex),
      floatingActionButton: _floatButtonBuilder(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '书籍管理'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '人员管理'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '借阅记录'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      drawer: _buildDrawer(),
    );
  }
}

void logoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('登出信息'),
        content: const Text('确定要退出登录么?'),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('确认'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

void maxBorrowedBookModifyOnPressGenerator(
    int account, BuildContext context, Function callback) {
  var title = "修改最大借阅数量信息";
  var controller = TextEditingController();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "输入新的最大借阅数量……",
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () async {
                if (isNumeric(controller.text)) {
                  var data = {
                    'account': account,
                    'maxBorrowedBook': controller.text
                  };
                  var res =
                      await http.put(Uri.parse('$URL/updateMaxBorrowedBook'),
                          headers: {
                            'Content-Type': 'application/json',
                          },
                          body: jsonEncode(data));

                  if (res.statusCode == 200) {
                    var body =
                        json.decode(utf8.decode(res.body.runes.toList()));

                    String message = body['message'];

                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(title),
                            content: Text(message),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    callback();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('关闭'))
                            ],
                          );
                        });
                  } else {
                    var message = "更新最大借阅数量错误! 错误代码：${res.statusCode}";
                    simpleDialog(context, message, title);
                  }
                } else {
                  var message = "输入的不是数字,请重新输入!";
                  simpleDialog(context, message, title);
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      });
}

void banOnPressGenerator(int account, int userType, int currentUserType,
    BuildContext context, Function callback) {
  var title = "封禁/解封信息";
  var text;
  if (userType == 0) {
    text = "确认要封禁该账户?";
  } else {
    text = "确认要解封该账户?";
  }

  if (currentUserType == 1) {
    var message = "该账户是管理员账户,不能封禁!";
    simpleDialog(context, message, title);
  } else {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                  onPressed: () async {
                    var data = {'account': account, 'userType': userType};
                    var res = await http.put(Uri.parse('$URL/ban'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(data));

                    if (res.statusCode == 200) {
                      var body =
                          json.decode(utf8.decode(res.body.runes.toList()));

                      String message = body['message'];

                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(title),
                              content: Text(message),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      callback();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('关闭'))
                              ],
                            );
                          });
                    } else {
                      var message = "操作账号错误! 错误代码：${res.statusCode}";
                      simpleDialog(context, message, title);
                    }
                  },
                  child: const Text("确认"))
            ],
          );
        });
  }
}

List<DataRow> getPeopleRows(
    List<dynamic> list, BuildContext context, Function callback) {
  List<DataRow> rows = [];
  var text;
  for (int i = 0; i < list.length; i++) {
    List<dynamic> elem = list[i];
    if (elem[3] == 0) {
      text = "解封";
    } else {
      text = "封禁";
    }
    List<DataCell> row = [];
    for (int j = 1; j <= 5; j++) {
      if (j == 4) {
        row.add(DataCell(Row(
          children: [
            Text(elem[j].toString()),
            const SizedBox(
              width: 5,
            ),
            ElevatedButton(
              onPressed: () {
                maxBorrowedBookModifyOnPressGenerator(
                    elem[2], context, callback);
              },
              child: const Text('修改'),
            ),
          ],
        )));
      } else if (j == 3) {
        var str = elem[3].toString();
        switch (elem[3]) {
          case 0:
            str = "$str(封禁账户)";
          case 1:
            str = "$str(管理员账户)";
          case 2:
            str = "$str(读者账户)";
          default:
            str = "error!";
        }
        row.add(DataCell(Text(str)));
      } else {
        row.add(DataCell(Text(elem[j].toString())));
      }
    }
    if (elem[2] != Account) {
      row.add(DataCell(Row(children: [
        ElevatedButton(
          onPressed: () {
            deleteMemberOnPressGenerator(elem[2], context, callback);
          },
          child: const Text('删除'),
        ),
        const SizedBox(
          width: 5,
        ),
        ElevatedButton(
          onPressed: () {
            if (elem[3] == 1 || elem[3] == 2) {
              banOnPressGenerator(elem[2], 0, elem[3], context, callback);
            } else if (elem[3] == 0) {
              banOnPressGenerator(elem[2], 2, elem[3], context, callback);
            }
          },
          child: Text(text),
        )
      ])));
    } else {
      row.add(const DataCell(Text("不能对自己操作")));
    }
    DataRow dataRow = DataRow(cells: row);
    rows.add(dataRow);
  }
  return rows;
}

void deleteBookOnPressGenerator(
    String ISBN, BuildContext context, Function callback) {
  var title = "删除书籍信息";

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: const Text('删除该书籍时会将其借阅记录一并删除,确认删除么?'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () async {
                var res = await http
                    .put(Uri.parse('$URL/deleteBook?ISBN=$ISBN'), headers: {
                  'Content-Type': 'application/json',
                });

                if (res.statusCode == 200) {
                  var body = json.decode(utf8.decode(res.body.runes.toList()));

                  String message = body['message'];

                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(title),
                          content: Text(message),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  callback();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('关闭'))
                          ],
                        );
                      });
                } else {
                  var message = "删除书籍错误! 错误代码: ${res.statusCode}";
                  simpleDialog(context, message, title);
                }
              },
            ),
          ],
        );
      });
}

void deleteMemberOnPressGenerator(
    int account, BuildContext context, Function callback) {
  var title = "删除人员信息";

  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: const Text('删除该人员时会将其借阅记录一并删除,确认删除么?'),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () async {
                var res = await http.put(
                    Uri.parse('$URL/deleteMember?account=$account'),
                    headers: {
                      'Content-Type': 'application/json',
                    });

                if (res.statusCode == 200) {
                  var body = json.decode(utf8.decode(res.body.runes.toList()));

                  String message = body['message'];

                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(title),
                          content: Text(message),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  callback();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('关闭'))
                          ],
                        );
                      });
                } else {
                  var message = "删除人员错误! 错误代码: ${res.statusCode}";
                  simpleDialog(context, message, title);
                }
              },
            ),
          ],
        );
      });
}

List<DataRow> getRows(
    List<dynamic> list, BuildContext context, Function callback) {
  List<DataRow> rows = [];
  for (int i = 0; i < list.length; i++) {
    List<dynamic> elem = list[i];
    List<DataCell> row = [];
    for (int j = 1; j <= 5; j++) {
      row.add(DataCell(Text(elem[j].toString())));
    }
    if (UserType == 2) {
      row.add(DataCell(ElevatedButton(
        onPressed: () {
          borrowingButtonOnPressGenerator(elem[3], Account, context, callback);
        },
        child: const Text('借阅'),
      )));
    } else {
      row.add(DataCell(Row(children: [
        ElevatedButton(
          onPressed: () {
            countModifyOnPressGenerator(elem[3], context, callback);
          },
          child: const Text('修改数量'),
        ),
        const SizedBox(
          width: 5,
        ),
        ElevatedButton(
          onPressed: () {
            deleteBookOnPressGenerator(elem[3], context, callback);
          },
          child: const Text('删除'),
        )
      ])));
    }
    DataRow dataRow = DataRow(cells: row);
    rows.add(dataRow);
  }
  return rows;
}

void countModifyOnPressGenerator(
    String ISBN, BuildContext context, Function callback) {
  var title = "修改数量信息";
  var controller = TextEditingController();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "输入这本书新的数量……",
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () async {
                if (isNumeric(controller.text)) {
                  var data = {'ISBN': ISBN, 'count': controller.text};
                  var res = await http.put(Uri.parse('$URL/updateCount'),
                      headers: {
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(data));

                  if (res.statusCode == 200) {
                    var body =
                        json.decode(utf8.decode(res.body.runes.toList()));

                    String message = body['message'];

                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(title),
                            content: Text(message),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    callback();
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('关闭'))
                            ],
                          );
                        });
                  } else {
                    var message = "更新数量错误! 错误代码：${res.statusCode}";
                    simpleDialog(context, message, title);
                  }
                } else {
                  var message = "输入的不是数字,请重新输入!";
                  simpleDialog(context, message, title);
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      });
}

Future<void> borrowingButtonOnPressGenerator(
    String ISBN, int account, BuildContext context, Function callback) async {
  var title = "借阅信息";
  var message = "确定要借阅么?";
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('确认'),
            onPressed: () async {
              callback();
              var res = await http.get(
                  Uri.parse('$URL/isAccountAllowedToBorrow/?account=$account'));

              if (res.statusCode == 200) {
                var body = json.decode(utf8.decode(res.body.runes.toList()));
                var result = body['result'];
                var message = body['message'];

                if (result) {
                  res = await http
                      .get(Uri.parse('$URL/isBookBorrowable?ISBN=$ISBN'));

                  if (res.statusCode == 200) {
                    body = json.decode(utf8.decode(res.body.runes.toList()));
                    result = body['result'];
                    message = body['message'];

                    if (result) {
                      var data = {
                        'account': account,
                        'ISBN': ISBN,
                      };

                      res = await http.post(
                        Uri.parse('$URL/borrow'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(data),
                      );

                      if (res.statusCode == 200) {
                        body =
                            json.decode(utf8.decode(res.body.runes.toList()));
                        result = body['result'];
                        message = body['message'];

                        if (result) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(title),
                                  content: Text(message),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          callback();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('关闭'))
                                  ],
                                );
                              });
                        } else {
                          simpleDialog(context, message, title);
                        }
                      } else {
                        message = "借阅失败! 错误代码: ${res.statusCode}";
                        simpleDialog(context, message, title);
                      }
                    } else {
                      simpleDialog(context, message, title);
                    }
                  } else {
                    message = "查询图书状态失败! 错误代码: ${res.statusCode}";
                    simpleDialog(context, message, title);
                  }
                } else {
                  simpleDialog(context, message, title);
                }
              } else {
                message = "借阅鉴权失败! 错误代码: ${res.statusCode}";
                simpleDialog(context, message, title);
              }
            },
          ),
        ],
      );
    },
  );
}

class SearchPage extends StatefulWidget {
  const SearchPage(
      {super.key,
      required this.searchQuery,
      required this.mode,
      required this.callback});

  final String searchQuery;

  final int mode;

  final Function callback;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  void refresh() {
    setState(() {
      _buildBody();
      widget.callback();
    });
  }

  Widget? _buildBody() {
    if (widget.mode == 1) {
      return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        SingleChildScrollView(
          child: FutureBuilder(
              future: HttpReq().search(widget.searchQuery),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('书名')),
                      DataColumn(label: Text('作者')),
                      DataColumn(label: Text('ISBN')),
                      DataColumn(label: Text('类别')),
                      DataColumn(label: Text('数量')),
                      DataColumn(label: Text('操作'))
                    ],
                    rows: getRows(snapshot.data, context, refresh),
                    dividerThickness: 1.0, // 设置分割线厚度
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black), // 设置分割线颜色
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误! 请重试!"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
        )
      ]);
    } else if (widget.mode == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SingleChildScrollView(
            child: FutureBuilder(
                future: HttpReq().searchPeople(widget.searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('昵称')),
                        DataColumn(label: Text('账号')),
                        DataColumn(label: Text('用户类型')),
                        DataColumn(label: Text('最大借书数量')),
                        DataColumn(label: Text('已借书数量')),
                        DataColumn(label: Text('操作'))
                      ],
                      rows: getPeopleRows(snapshot.data, context, refresh),
                      dividerThickness: 1.0, // 设置分割线厚度
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // 设置分割线颜色
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("错误! 请重试!"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
          )
        ],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('查询结果'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: _buildBody());
  }
}

class PersonalProfilePage extends StatefulWidget {
  const PersonalProfilePage(
      {super.key, required this.account, required this.callback});

  final int account;

  final Function callback;

  @override
  State<PersonalProfilePage> createState() => _PersonalProfilePageState();
}

class _PersonalProfilePageState extends State<PersonalProfilePage> {
  void refresh() {
    setState(() {
      _buildBody(Account);
    });
  }

  FutureBuilder _buildBody(int account) {
    var futureBuilder = FutureBuilder(
        future: HttpReq().find(account),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> personalInfo;
            personalInfo = [
              {
                'icon': Image.asset('assets/image/avatar.png'),
                'label': '头像',
                'value': ''
              },
              {
                'icon': const Icon(Icons.person),
                'label': '账号',
                'value': account.toString(),
              },
              {
                'icon': const Icon(Icons.type_specimen),
                'label': '用户类型',
                'value': snapshot.data["userType"] == 1 ? "管理员账号" : "读者账号",
              },
              {
                'icon': const Icon(Icons.text_fields),
                'label': '昵称',
                'value': snapshot.data['name']
              },
              {
                'icon': const Icon(Icons.book),
                'label': '已借数量',
                'value': snapshot.data['borrowedBook'].toString()
              },
              {
                'icon': const Icon(Icons.bookmark),
                'label': '最大借书数量',
                'value': snapshot.data['maxBorrowedBook'].toString()
              }
            ];

            return ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  if (index == 3) {
                    return ListTile(
                      leading: CircleAvatar(
                        child: personalInfo[index]['icon'],
                      ),
                      title: Text(personalInfo[index]['label']), // 标签
                      subtitle: Text(personalInfo[index]['value']),
                      trailing: IconButton(
                          onPressed: () {
                            nameModifyDialog(context, Account);
                          },
                          icon: const Icon(Icons.edit)),
                    );
                  } else {
                    return ListTile(
                      leading: CircleAvatar(
                        child: personalInfo[index]['icon'],
                      ),
                      title: Text(personalInfo[index]['label']), // 标签
                      subtitle: Text(personalInfo[index]['value']),
                    );
                  }
                });
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("错误！请重试！"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
    return futureBuilder;
  }

  void nameModifyDialog(BuildContext context, int account) {
    var controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('昵称修改'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '输入你的新昵称……',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                nameModify(account, controller);
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  void nameModify(int account, TextEditingController controller) async {
    var data = {'account': account, 'name': controller.text};
    var res = await http.put(Uri.parse('$URL/updatePersonalName'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data));
    if (res.statusCode == 200) {
      var body = json.decode(utf8.decode(res.body.runes.toList()));

      String message = body['message'];
      bool result = body['result'];

      if (result) {
        Username = controller.text;
      }

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("更新昵称信息"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      refresh();
                      widget.callback();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('关闭'))
              ],
            );
          });
    } else {
      var message = "更新昵称错误！错误代码：${res.statusCode}";
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("更新昵称信息"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('关闭'))
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("个人信息"),
        ),
        body: _buildBody(Account),
        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: () {
                    passwordModifyDialog(context, Account);
                  },
                  tooltip: "修改密码",
                  child: const Icon(Icons.edit)),
            ]));
  }

  void passwordModifyDialog(BuildContext context, int account) {
    var controller1 = TextEditingController();
    var controller2 = TextEditingController();
    var controller3 = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              scrollable: true,
              title: const Text('密码修改'),
              content: Column(
                children: [
                  TextField(
                    obscureText: true,
                    controller: controller1,
                    decoration: const InputDecoration(
                      hintText: '请输入原密码……',
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: controller2,
                    decoration: const InputDecoration(
                      hintText: '请输入新密码……',
                    ),
                  ),
                  TextField(
                    obscureText: true,
                    controller: controller3,
                    decoration: const InputDecoration(
                      hintText: '请再次输入新密码……',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      passwordModify(
                          account, controller1, controller2, controller3);
                    });
                  },
                  child: const Text('确认'),
                ),
              ]);
        });
  }

  void passwordModify(
      int account,
      TextEditingController controller1,
      TextEditingController controller2,
      TextEditingController controller3) async {
    var text1 = controller1.text;
    var text2 = controller2.text;
    var text3 = controller3.text;
    String title = "密码修改信息";

    if (text1 == "" || text2 == "" || text3 == "") {
      var message = "三个文本框均不可为空!";
      simpleDialog(context, message, title);
    } else {
      var data = {
        'account': account,
        'password': text1,
      };

      var res = await http.post(
        Uri.parse('$URL/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (res.statusCode == 200) {
        var body = json.decode(utf8.decode(res.body.runes.toList()));
        if (body['token']) {
          if (text3 == text2) {
            data = {
              'account': account,
              'newPassword': text2,
            };
            res = await http.put(
              Uri.parse('$URL/updatePersonalPassword'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: jsonEncode(data),
            );
            if (res.statusCode == 200) {
              var body = json.decode(utf8.decode(res.body.runes.toList()));

              String message = body['message'];

              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(title),
                      content: Text(message),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('关闭'))
                      ],
                    );
                  });
            } else {
              var message = "更新密码错误！错误代码：${res.statusCode}";
              simpleDialog(context, message, title);
            }
          } else {
            var message = "两次输入的新密码不一致！";
            simpleDialog(context, message, title);
          }
        } else {
          var message = "原密码错误！";
          simpleDialog(context, message, title);
        }
      } else {
        var message = "原密码验证错误！错误代码：${res.statusCode}";
        simpleDialog(context, message, title);
      }
    }
  }
}

class BorrowHistoryPage extends StatelessWidget {
  const BorrowHistoryPage({super.key, required this.callback});

  final Function callback;

  List<DataRow> getRowsOfBorrowedBook(
      List<dynamic> list, BuildContext context) {
    List<DataRow> rows = [];
    for (int i = 0; i < list.length; i++) {
      List<dynamic> elem = list[i];
      List<DataCell> row = [];
      for (int j = 0; j <= 5; j++) {
        row.add(DataCell(Text(elem[j].toString())));
      }
      if (elem[6] == null) {
        row.add(const DataCell(Text("尚未归还")));
      } else {
        row.add(DataCell(Text(elem[6].toString())));
      }
      DataRow dataRow = DataRow(cells: row);
      rows.add(dataRow);
    }
    return rows;
  }

  Widget _buildBody() {
    return Center(
        child: SingleChildScrollView(
            child: FutureBuilder(
                future: HttpReq().getBorrowedBook(Account),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return DataTable(
                      columns: const [
                        DataColumn(label: Text('借阅号')),
                        DataColumn(label: Text('昵称')),
                        DataColumn(label: Text('账号')),
                        DataColumn(label: Text('书名')),
                        DataColumn(label: Text('ISBN')),
                        DataColumn(label: Text('借书时间')),
                        DataColumn(label: Text('还书时间')),
                      ],
                      rows: getRowsOfBorrowedBook(snapshot.data, context),
                      dividerThickness: 1.0, // 设置分割线厚度
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black), // 设置分割线颜色
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text("错误！请重试！"),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("全部借阅记录"),
      ),
      body: _buildBody(),
    );
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, required this.callback});

  final Function callback;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  void refresh() {
    setState(() {
      _buildBody();
    });
  }

  FutureBuilder _buildBody() {
    return FutureBuilder(
        future: HttpReq().getBorrowDays(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, dynamic>> parameter;
            parameter = [
              {
                'icon': const Icon(Icons.date_range),
                'label': '最久借书时间',
                'value': snapshot.data.toString()
              }
            ];
            return ListView.builder(
              itemCount: 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: parameter[index]['icon'],
                    ),
                    title: Text(parameter[index]['label']), // 标签
                    subtitle: Text(parameter[index]['value']),
                    trailing: IconButton(
                        onPressed: () {
                          borrowDaysModifyDialog(context);
                        },
                        icon: const Icon(Icons.edit)),
                  );
                }
                return null;
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("错误！请重试！"),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("参数设置"),
      ),
      body: _buildBody(),
    );
  }

  void borrowDaysModifyDialog(BuildContext context) {
    var controller = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('更新最久借书日期信息'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '输入新的最久借书日期……',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: () {
                borrowDaysModify(controller);
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  void borrowDaysModify(TextEditingController controller) async {
    var title = "更新最久借书时间信息";
    var data = {'borrowDays': controller.text};
    if (isNumeric(controller.text)) {
      var res = await http.post(Uri.parse('$URL/updateBorrowDays'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(data));

      if (res.statusCode == 200) {
        var body = json.decode(utf8.decode(res.body.runes.toList()));

        String message = body['message'];
        bool result = body['result'];

        if (result) {
          BorrowDays = int.parse(controller.text);
        }

        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(title),
                content: Text(message),
                actions: [
                  TextButton(
                      onPressed: () {
                        refresh();
                        widget.callback();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('关闭'))
                ],
              );
            });
      } else {
        var message = "更新最久借书时间错误! 错误代码：${res.statusCode}";
        simpleDialog(context, message, title);
      }
    } else {
      var message = '输入的不是数字! 重新输入!';
      simpleDialog(context, message, title);
    }
  }
}
