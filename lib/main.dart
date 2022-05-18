import 'package:flutter/material.dart';
import 'package:mise/data/api.dart';
import 'package:mise/data/mise.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Color> colors = const [
    Color(0xFF0077C2),
    Color(0xFF009BA9),
    Color(0xFFFe6300),
    Color(0xFFD80019)
  ];

  List<String> icon = [
    "assets/img/happy.png",
    "assets/img/sad.png",
    "assets/img/bad.png",
    "assets/img/angry.png"
  ];

  List<String> status = ["좋음", "보통", "나쁨", "매우나쁨"];
  String stationName = "성산읍";
  List<Mise> data = [];

  int getStatus(Mise mise) {
    if (mise.pm10 > 150) {
      return 3;
    } else if (mise.pm10 > 80) {
      return 2;
    } else if (mise.pm10 > 30) {
      return 1;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    getMiseData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String l = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => LocationPage()));

          if (l != null) {
            stationName = l;
            getMiseData();
          }
        },
        child: const Icon(Icons.location_on),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget getPage() {
    if (data.isEmpty) {
      return Container();
    }

    int _status = getStatus(data.first);

    return Container(
        color: colors[_status],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 60,
            ),
            const Text("현재위치",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            Container(
              height: 12,
            ),
            Text(
              "[$stationName]",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Container(
              height: 60,
            ),
            Container(
              width: 200,
              height: 200,
              child: Image.asset(
                icon[_status],
                fit: BoxFit.contain,
              ),
            ),
            Container(
              height: 60,
            ),
            Text(status[_status],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
            Container(
              height: 20,
            ),
            Text("통합 환경 대기 지수 : ${data.first.khai}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white)),
            Container(height: 20),
            Expanded(
              child: Container(
                // color: Colors.redAccent,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(data.length, (idx) {
                    Mise mise = data[idx];
                    int _status = getStatus(mise);

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            mise.dataTime.replaceAll(" ", "\n"),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            child: Image.asset(
                              icon[_status],
                              fit: BoxFit.contain,
                            ),
                            height: 50,
                            width: 50,
                          ),
                          Text(
                            "${mise.pm10}ug/m2",
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            Container(
              height: 80,
            ),
          ],
        ));
  }

  void getMiseData() async {
    MiseApi api = MiseApi();
    data = await api.getMiseData(stationName);
    data.removeWhere((m) => m.pm10 == 0);

    setState(() {});
  }
}

class LocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LocationPageState();
  }
}

class _LocationPageState extends State<LocationPage> {
  List<String> locations = [
    "구로구",
    "동작구",
    "마포구",
    "강남구",
    "강동구",
    "성북구",
    "종로구",
    "동대문구",
    "표선면",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ListView(
          children: List.generate(locations.length, (idx) {
            return ListTile(
                title: Text(locations[idx]),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.of(context).pop(locations[idx]);
                });
          }),
        ));
  }
}
