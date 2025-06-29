import 'package:flutter/material.dart';
import 'package:instaclone/AllScansusingfacemesh/eyes/scancardsforeyes/scanscanthaltiltcards.dart';
import 'package:instaclone/AllScansusingfacemesh/eyes/scancardsforeyes/scanseyelidshapecards.dart';
import 'package:instaclone/AllScansusingfacemesh/eyes/scancardsforeyes/scanseyequalitycards.dart';
import 'package:instaclone/AllScansusingfacemesh/eyes/scancardsforeyes/scanseyeshapecards.dart';


class Maineyescan extends StatelessWidget {
  const Maineyescan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Scan', style: TextStyle(fontSize: 20),),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScanscanthaltiltCards()),
                  );
                },
                child: const Text('Canthal Tilt Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(9), // Adjust the radius as needed
                  ),
                  fixedSize: const Size(320, 100)
                ),
                
              ),
            ),
           
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScanseyequalityCards()),
                  );
                },
                 child: const Text('Eye Quality Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(9), // Adjust the radius as needed
                  ),
                   fixedSize: const Size(320, 100)
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScanseyeshapeCards()),
                  );
                },
                child: const Text('Eye Shape Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(9), // Adjust the radius as needed
                  ),
                   fixedSize: const Size(320, 100)
                ),
              ),
            ),
               ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ScanseyelidshapeCards()),
                  );
                },
                child: const Text('Eye Lid Shape Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(9), // Adjust the radius as needed
                  ),
                   fixedSize: const Size(320, 100)
                ),
              ),
         
          ],
        ),
      ),
    );
  }
}
