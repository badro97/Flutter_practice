import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class Todo {
  bool isDone;
  String title;

  Todo(this.title, {this.isDone = false});
}


class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FinalPage(),
    );
  }
}

class FinalPage extends StatefulWidget {
  @override
  _FinalPageState createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  var _index = 0;

  var _pages = [
    TodoListPage(),
    BmiMain(),
    StopWatchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Fianl',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),

      body: _pages[_index],

      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _index = index;
          });
        },
        currentIndex: _index,
        items: <BottomNavigationBarItem> [
          BottomNavigationBarItem(
            title: Text('TODO'),
            icon: Icon(Icons.local_offer),
          ),

          BottomNavigationBarItem(
            title: Text('BMI'),
            icon: Icon(Icons.bubble_chart),
          ),

          BottomNavigationBarItem(
            title: Text('StopWatch'),
            icon: Icon(Icons.timer),
          ),
        ],
      ),
    );
  }
}


class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // 할 일 문자열 조작을 위한 컨트롤러
  var _todoController = TextEditingController();

  @override
  void dispose() { // 컨트롤러 사용 끝나면 해제
    _todoController.dispose();
    super.dispose();
  }


  // 할 일 객체를 ListTile 형태로 변경하는 메서드
  Widget _buildItemWidget(DocumentSnapshot doc) {
    final todo = Todo(doc['title'], isDone: doc['isDone']); // Firestore 객체생성
    return ListTile(
      onTap: () => _toggleTodo(doc), // 클릭 시 완료/취소되도록
      title: Text(
        todo.title, // 할 일
        style: todo.isDone // 완료일 때는 스타일 적용
          ? TextStyle(
                decoration: TextDecoration.lineThrough, // 취소선
                fontStyle: FontStyle.italic,
              )
            : null
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_forever),
        onPressed: () => _deleteTodo(doc), // 쓰레기통 클릭 시 삭제되도록 수정
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'What to do',
                    ),
                    controller: _todoController,
                  ),
                ),
                RaisedButton(
                  child: Text('Add'),
                  onPressed: () => _addTodo(Todo(_todoController.text)),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('todo').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final documents = snapshot.data.documents;
                return Expanded(
                  child: ListView(
                    children: documents
                        .map((doc) => _buildItemWidget(doc)).toList(),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  // 할 일 추가 메서드드
 void _addTodo(Todo todo) {
    Firestore.instance
      .collection('todo')
      .add({'title': todo.title, 'isDone': todo.isDone});
    _todoController.text ='';
  }

  // 할 일 삭제 메서드
  void _deleteTodo(DocumentSnapshot doc) {
    Firestore.instance.collection('todo').document(doc.documentID).delete();
  }

  // 할 일 완료/미완료 메서드
  void _toggleTodo(DocumentSnapshot doc) {
    Firestore.instance.collection('todo').document(doc.documentID).updateData({
      'isDone': !doc['isDone'],
    });
  }
}



// BMI 계산
class BmiMain extends StatefulWidget {
  @override
  _BmiMainState createState() => _BmiMainState();
}


class _BmiMainState extends State<BmiMain> {
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 얻기 위한 키

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: Container(
        padding: const EdgeInsets.all(40.0),

        child: Form(
          key: _formKey,

          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration( // 외곽선 있고 힌트 표시
                  border: OutlineInputBorder(),
                  hintText: 'Height',
                ),

                controller: _heightController,
                keyboardType: TextInputType.number, // 숫자만 입력 가능
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Please Enter your height';
                  }
                  return null;
                },
              ),

              SizedBox(
                height: 40.0,
              ),

              TextFormField(
                decoration: InputDecoration( // 외곽선 있고 힌트 표시
                  border: OutlineInputBorder(),
                  hintText: 'Weight',
                ),

                controller: _weightController,
                keyboardType: TextInputType.number, // 숫자만 입력 가능
                validator: (value) {
                  if (value.trim().isEmpty) {
                    return 'Please Enter your weight';
                  }
                  return null;
                },
              ),

              Container(
                margin: const EdgeInsets.only(top: 16.0),
                alignment: Alignment.centerRight,

                child: RaisedButton(
                  onPressed: () {
                    // 폼에 입력된 값 검증
                    if (_formKey.currentState.validate()) { // 키와 몸무게 값이 검증 되었다면 화면 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BmiResult(
                                double.parse(_heightController.text.trim()),
                                double.parse(_weightController.text.trim()))),
                      );
                    }
                  },
                  child: Text('Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
// BMI 결과
class BmiResult extends StatelessWidget {
  final double height; // 키
  final double weight; // 몸무게

  BmiResult(this.height, this.weight); // 키와 몸무게를 받는 생성자

  @override
  Widget build(BuildContext context) {
    final bmi = (weight / ((height / 100) * (height / 100))) ~/ 1;
    var bmiRes = '$bmi';
    print('bmi : $bmi');
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'BMI Score',
              style: TextStyle(fontSize: 26),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              bmiRes,
              style: TextStyle(fontSize: 40),
            ),
            SizedBox(
              height: 16,
            ),

            _buildIcon(bmi),

            SizedBox(
              height: 16,
            ),
            Text(
              _calcBmi(bmi),
              style: TextStyle(fontSize: 36),
            ),
          ],
        ),
      ),
    );
  }

  String _calcBmi(int bmi) {
    var result = 'Underweight';
    if (bmi >= 40) {
      result = 'Danger';
    } else if (bmi >= 35) {
      result = 'obese class 2';
    } else if (bmi >= 30) {
      result = 'Obese class 1';
    } else if (bmi >= 25) {
      result = 'Overweight';
    } else if (bmi >= 18.5) {
      result = 'Normal';
    }
    return result;
  }

  Widget _buildIcon(int bmi) {
    if (bmi >= 35) {
      return Icon(
        Icons.sentiment_very_dissatisfied,
        color: Colors.red,
        size: 100,
      );
    } else if (bmi >= 30) {
      return Icon(
        Icons.sentiment_dissatisfied,
        color: Colors.orange,
        size: 100,
      );
    } else if (bmi >= 25){
      return Icon(
        Icons.sentiment_neutral,
        color: Colors.yellow,
        size: 100,
      );
    } else if (bmi >= 18.5) {
      return Icon(
        Icons.sentiment_satisfied,
        color: Colors.green,
        size: 100,
      );
    } else {
      return Icon(
        Icons.sentiment_very_dissatisfied,
        color: Colors.red,
        size: 100,
      );
    }
  }
}


// StopWatch
class StopWatchPage extends StatefulWidget {
  @override
  _StopWatchPageState createState() => _StopWatchPageState();
}

class _StopWatchPageState extends State<StopWatchPage> {

  Timer _timer; // 타이머

  var _time = 0; // 0.01초마다 1씩 증가시킬 정수형 변수
  var _isRunning = false; // 현재 시작 상태를 나타낼 bool 변수

  List<String> _lapTimes = []; // 랩타임에 표시할 시간을 저장할 리스트

  @override
  void dispose() { // 앱을 종료할 때 반복되는 동작 취소
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('StopWatch'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),

      body: _buildBody(),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: FloatingActionButton(
          onPressed: () => setState((){
            _clickButton();
          }),
          child: _isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  // 내용 부분
  Widget _buildBody() {
    var sec = _time ~/ 100; // 초
    var hundredth = '${_time % 100}'.padLeft(2, '0'); // 1/100 초  / 2자리 표현 왼쪽 빈자리는 0으로 채우기

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row( // 시간 표시하는 영역
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text( // 초
                      '$sec',
                      style: TextStyle(fontSize: 50.0),
                    ),
                    Text('$hundredth'), // 1/100초
                  ],
                ),

                Container( // 랩타임(기록) 표시하는 영역
                  width: 90,
                  height: 400,
                  child: ListView(
                    children: _lapTimes.map((time) => Text(time)).toList(),
                  ),
                )
              ],
            ),

            Positioned(
              left: 10,
              bottom:40,
              child: FloatingActionButton( // 왼쪽 아래 초기화 버튼
                backgroundColor: Colors.deepOrange,
                onPressed: _reset,
                child: Icon(Icons.rotate_left),
              ),
            ),

            Positioned(
                right: 10,
                bottom: 40,
                child: FloatingActionButton( // 오른쪽 아래 랩타임(기록) 버튼
                  backgroundColor: Colors.lightGreen,
                  onPressed: () {
                    setState(() {
                      _recordLapTime('$sec.$hundredth');
                    });
                  },
                  child: Icon(Icons.check),
                ),
            ),
          ],
        ),
      ),
    );
  }
  // 시작 또는 일시정지 버튼
  void _clickButton() {
    _isRunning = !_isRunning;

    if(_isRunning) {
      _start();
    } else {
      _pause();
    }
  }

  // 1/100 초에 한 번씩 time 변수를 1증가
  void _start() {
    _timer = Timer.periodic(Duration(milliseconds: 10), (timer) {
      setState(() {
        ++_time;
      });
    });
  }
  // 타이머 취소
  void _pause() {
    _timer?.cancel();
  }

  // 초기화 버튼
  void _reset() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
      _lapTimes.clear();
      _time = 0;
    });
  }

  // 랩타임 기록
  void _recordLapTime(String time) {
    _lapTimes.insert(_lapTimes.length, '${_lapTimes.length + 1}:  $time');
  }
}
