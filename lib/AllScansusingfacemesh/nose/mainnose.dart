import 'package:flutter/material.dart';

import 'package:instaclone/AllScansusingfacemesh/nose/scancardsfornose/scansnosehapetflitecards.dart';
import 'package:instaclone/AllScansusingfacemesh/nose/scancardsfornose/scansnosesshapecards.dart';


class Mainnose extends StatelessWidget {
  const Mainnose({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nose Scan', style: TextStyle(fontSize: 20),),
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
                        builder: (context) => const Scansnosesshapecards()),
                  );
                },
                child: const Text('Front Profile Nose Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
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
                        builder: (context) => const Scansnosehapetflitecards()),
                  );
                },
                 child: const Text('Side Profile Nose Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
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
