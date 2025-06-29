import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instaclone/AllScansusingfacemesh/eyebrow/scancardsforeyebrow/scaneyebrowcards.dart';
import 'package:instaclone/AllScansusingfacemesh/eyes/maineyescan.dart';
import 'package:instaclone/AllScansusingfacemesh/facestructures/mainfacestructure.dart';
import 'package:instaclone/AllScansusingfacemesh/jawline/scanscardsforjawline/scansjawlinecards.dart';
import 'package:instaclone/AllScansusingfacemesh/lips/scanslipshapecards/scanslipshapecards.dart';
import 'package:instaclone/AllScansusingfacemesh/nose/mainnose.dart';
import 'package:instaclone/AllScansusingfacemesh/testscan/scancardsfortest/scanstestcards.dart';
import 'package:instaclone/roboflow/skin/mainskin.dart';
import 'package:instaclone/scancards/scansagecards.dart';
import 'package:instaclone/scancards/scanshaircards.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class Scans extends StatefulWidget {
  const Scans({super.key});

  @override
  ScansState createState() => ScansState();
}

class ScansState extends State<Scans>
    with TickerProviderStateMixin, RouteAware {
  final List<Map<String, dynamic>> cards = [
    {
      'color': const Color.fromARGB(255, 202, 178, 255),
      'content': 'Try Out Our Free Scan',
      'button': {
        'label': 'Test',
        'action': () {
          // This will be filled in later
        },
      },
    },
    {
      'color': const Color.fromARGB(255, 203, 231, 255),
      'content': "Know What Lies in Your Eyes",
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 180, 211, 181),
      'content': 'Max Your Face Stats',
      'button': {'label': 'Begin EYE SCAN', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 255, 251, 217),
      'content': 'Skin Smooth Like Butter',
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 185, 255, 250),
      'content': "Shape Them Brows",
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 163, 165, 255),
      'content': 'Know Your Shapes',
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 255, 193, 242),
      'content': "Lips Don't Lie",
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 167, 245, 255),
      'content': "Define Your Jawline",
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 177, 151, 255),
      'content': "Grade Your Hairloss",
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(255, 255, 193, 242),
      'content': 'What Age Do You Look Like?',
      'button': {'label': 'Second Page', 'action': () {}}
    },
    {
      'color': const Color.fromARGB(65, 255, 0, 0),
      'content': "More Scans On The Way",
      'button': {'label': 'Second Page', 'action': () {}}
    },
  ];

  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _offsetAnimations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    for (var controller in _controllers) {
      controller.forward(from: 0);
    }
  }

  @override
  void didPop() {
    for (var controller in _controllers) {
      controller.reverse();
    }
    super.didPop();
  }

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(cards.length, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 1300),
        vsync: this,
      )..forward();
    });

    _offsetAnimations = List.generate(cards.length, (index) {
      return Tween<Offset>(
        begin: index % 2 == 0 ? const Offset(-1.0, 0.0) : const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controllers[index],
        curve: Curves.decelerate,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Explore Scans")),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 50),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            return SlideTransition(
              position: _offsetAnimations[index],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: SizedBox(
                    height: 300,
                    width: 300,
                    child: buildCard(
                      color: cards[index]['color'],
                      content: cards[index]['content'],
                      button: cards[index]['button'],
                      index: index,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Card buildCard(
      {required Color color,
      required String content,
      required Map<String, dynamic> button,
      required int index}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            content,
            style: GoogleFonts.italiana(
              textStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: content == "More Scans On The Way"
                    ? Colors.white
                    : const Color.fromARGB(150, 0, 0, 0),
                letterSpacing: 0.0,
              ),
            ),
          ),
          if (index == 1) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Eyes', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Maineyescan(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 4) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Eyebrow', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Scaneyebrowcards(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 2) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Face', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Mainfacestructure(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 3) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Skin', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Mainskin(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 9) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Age', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ScansageCards(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 8) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Hair', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ScanshairCards(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 6) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Lips', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Scanslipshapecards(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 5) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Scan Your Nose', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Mainnose(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
          if (index == 0) // Only show the button for the second card
            ElevatedButton(
              child: const Text(
                'Test Scan', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Scanstestcards(), // Navigate to the second page
                    ),
                  );
                });
              },
            ),
        if (index == 10) // Only show the button for the specific card
  Container(
    padding: const EdgeInsets.only(top: 13, bottom: 13, right: 19, left: 19),
    child: const Text(
      'Look Out 👀', // Change the label for the button
      style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
    ),
   decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(14)),
   // Disable the button
  ),


          if (index ==
              7) // Only show the "Test" button for cards other than the second one
            ElevatedButton(
              child: const Text(
                'Scan Your Jawline', // Change the label for the second button
                style: TextStyle(color: Color.fromARGB(255, 17, 0, 0)),
              ),
              onPressed: () {
                Future.delayed(const Duration(milliseconds: 1), () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 900),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const Scansjawlinemeshcards(),
                    ),
                  );
                });
              },
            ),
        ],
      ),
    );
  }
}
