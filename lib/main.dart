import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'safety_info_page.dart';
import 'about_page.dart';
import 'package:url_launcher/url_launcher.dart';

bool isAlarmStopped = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.dark);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentTheme, child) {
        return MaterialApp(
          title: 'LPG Detection System',
          debugShowCheckedModeBanner: false,
          themeMode: currentTheme,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
          home: HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  void _callFireStation() async {
    const phoneNumber = 'tel:101'; // Replace with your fire station's number
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late Future<Map<String, double>> _sensorData;
  late Timer _timer;

  static final AudioPlayer player = AudioPlayer();
  static final AssetSource alarmAudioSource = AssetSource("siren.mp3");

  late AnimationController _animationController;
  late Animation<double> _gaugeAnimation;
  double _currentPPM = 0.0;

  bool isPlaying = false;
  bool showAlarmButton = false;

  @override
  void initState() {
    super.initState();
    _sensorData = _fetchSensorData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _gaugeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _startTimer();
  }

  Future<Map<String, double>> _fetchSensorData() async {
    try {
      DatabaseReference ref = _database.ref();
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        var data = snapshot.value as Map<dynamic, dynamic>;
        return {
          'gasLevel': data['gasLevel']?.toDouble() ?? 0.0,
          'temperature': data['temperature']?.toDouble() ?? 0.0,
          'humidity': data['humidity']?.toDouble() ?? 0.0,
        };
      } else {
        return {'gasLevel': 0.0, 'temperature': 0.0, 'humidity': 0.0};
      }
    } catch (e) {
      print('Error fetching data: $e');
      return {'gasLevel': 0.0, 'temperature': 0.0, 'humidity': 0.0};
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      final data = await _fetchSensorData();
      double newPPM = data['gasLevel'] ?? 0.0;

      // Animate gauge value.
      _animateGauge(_currentPPM, newPPM);

      setState(() {
        _sensorData = Future.value(data);
        _checkAndPlayAlarm(newPPM);
        _currentPPM = newPPM; // Update the current PPM after animation.
      });
    });
  }

  void _animateGauge(double from, double to) {
    _gaugeAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward(from: 0.0); // Restart the animation.
  }

  void _checkAndPlayAlarm(double gasLevel) {
    if (gasLevel > 2000 && !isPlaying && !isAlarmStopped) {
      player.play(alarmAudioSource);
      setState(() {
        isPlaying = true;
        showAlarmButton = true;
      });
    } else if ((gasLevel <= 2000 || isAlarmStopped) && isPlaying) {
      player.stop();
      setState(() {
        isPlaying = false;
        showAlarmButton = false;
      });
    }
  }

  void _stopAlarm() {
    player.stop();
    setState(() {
      isPlaying = false;
      showAlarmButton = false;
      isAlarmStopped = true; // Prevent the alarm from starting again.
    });
  }

  // Function to determine gauge color based on PPM level.
  Color _getGaugeColor(double ppm) {
    if (ppm < 1200) {
      return Colors.green;
    } else if (ppm < 2000) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  Widget _buildRadialGauge() {
    return AnimatedBuilder(
      animation: _gaugeAnimation,
      builder: (context, child) {
        return SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 2000,
              showLabels: false,
              showTicks: false,
              axisLineStyle: AxisLineStyle(
                thickness: 30,
                cornerStyle: CornerStyle.bothCurve,
                color: _getGaugeColor(_gaugeAnimation.value),
              ),
              pointers: <GaugePointer>[
                RangePointer(
                  value: _gaugeAnimation.value,
                  width: 30,
                  color: _getGaugeColor(_gaugeAnimation.value),
                )
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PPM',
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      Text(
                        '${_gaugeAnimation.value.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.0,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDataCard(String title, String value) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Gas Data', style: Theme.of(context).textTheme.displayLarge),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: Icon(
              MyApp.themeNotifier.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              MyApp.themeNotifier.value =
                  MyApp.themeNotifier.value == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'LPG Detection and Alert System',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Safety Instructions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SafetyInstructionsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              },
            ),
            Divider(), // Adds a visual separation
            ListTile(
              leading: Icon(Icons.local_fire_department, color: Colors.red),
              title: Text(
                'Call Fire Station',
                style: TextStyle(color: Colors.red),
              ),
              onTap: _callFireStation,
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, double>>(
        future: _sensorData,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRadialGauge(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDataCard('Temp',
                      '${data['temperature']?.toStringAsFixed(1) ?? '0.0'}°C'),
                  _buildDataCard('Humidity',
                      '${data['humidity']?.toStringAsFixed(1) ?? '0.0'}%'),
                ],
              ),
              if (showAlarmButton)
                ElevatedButton(
                  onPressed: _stopAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Stop Alarm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    player.dispose();
    super.dispose();
  }
}
