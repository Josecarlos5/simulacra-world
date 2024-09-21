
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart'; // For playing sound
import 'package:http/http.dart' as http; // For fetching real-time data
import 'dart:convert'; // For parsing JSON responses
import 'package:google_fonts/google_fonts.dart'; // For custom fonts

void main() {
  runApp(SimulacraApp());
}

class SimulacraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Simulacra World')),
        body: SimulacraWorld(),
      ),
    );
  }
}

class SimulacraWorld extends StatefulWidget {
  @override
  _SimulacraWorldState createState() => _SimulacraWorldState();
}

class _SimulacraWorldState extends State<SimulacraWorld> {
  List<SimulatedObject> simulatedObjects = [];
  Random random = Random();
  String quote = "";
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch real-time data when the app starts
    playBackgroundMusic(); // Start playing background sounds
  }

  Future<void> fetchData() async {
    try {
      var response = await http.get(Uri.parse('https://api.quotable.io/random')); // Fetch random quote as an example
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          quote = data['content'];
        });
      }
    } catch (e) {
      setState(() {
        quote = "Error fetching real-time data";
      });
    }
  }

  void playBackgroundMusic() async {
    await audioPlayer.play(AssetSource('assets/sounds/hyperreal_bg.mp3'), volume: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        setState(() {
          simulatedObjects.add(createSimulatedObject(details.localPosition));
          fetchData(); // Update quote on each tap
        });
      },
      child: Stack(
        children: [
          CustomPaint(
            painter: SimulacraPainter(simulatedObjects),
            child: Container(),
          ),
          // Overlay with quotes and hyperreal commentary
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16),
              color: Colors.black.withOpacity(0.5),
              child: Text(
                quote.isNotEmpty ? '"$quote"' : 'Loading quote...',
                style: GoogleFonts.robotoMono(
                  textStyle: TextStyle(color: Colors.white, fontSize: 16),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SimulatedObject createSimulatedObject(Offset position) {
    return SimulatedObject(
      position: position,
      size: 30.0 + random.nextDouble() * 50.0,
      color: Colors.primaries[random.nextInt(Colors.primaries.length)],
      distortFactor: random.nextDouble() * 3.0,
    );
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}

class SimulatedObject {
  Offset position;
  double size;
  Color color;
  double distortFactor;

  SimulatedObject({
    required this.position,
    required this.size,
    required this.color,
    required this.distortFactor,
  });

  void distort() {
    size += distortFactor; // Increase size or change shape
  }
}

class SimulacraPainter extends CustomPainter {
  final List<SimulatedObject> simulatedObjects;

  SimulacraPainter(this.simulatedObjects);

  @override
  void paint(Canvas canvas, Size size) {
    for (var obj in simulatedObjects) {
      Paint paint = Paint()..color = obj.color;
      canvas.drawCircle(obj.position, obj.size, paint);
      obj.distort();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
