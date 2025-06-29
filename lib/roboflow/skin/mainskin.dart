import 'package:flutter/material.dart';
import 'package:instaclone/roboflow/skin/scansskintypecards.dart';
import 'package:instaclone/scancards/scansfacequalitycards.dart';

class Mainskin extends StatelessWidget {
  const Mainskin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('Skin Scan', style: TextStyle(fontSize: 20),),
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
                        builder: (context) => const ScansskintypeCards()),
                  );
                },
                child: const Text('Skin Type Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
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
                        builder: (context) => const ScansfacequalityCards()),
                  );
                },
                 child: const Text('Skin Quality Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
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
