import 'package:flutter/material.dart';
import 'package:instaclone/AllScansusingfacemesh/facestructures/scancardsforfacestructure/scanscheekbonescards.dart';
import 'package:instaclone/AllScansusingfacemesh/facestructures/scancardsforfacestructure/scansfaceshapesscards.dart';
import 'package:instaclone/AllScansusingfacemesh/facestructures/scancardsforfacestructure/scansfacesymmetrycards.dart';


class Mainfacestructure extends StatelessWidget {
  const Mainfacestructure({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('Face Scan', style: TextStyle(fontSize: 20),),
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
                        builder: (context) => const Scansfaceshapesscards()),
                  );
                },
                child: const Text('Face Shape Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
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
                        builder: (context) => const Scanscheekbonescards()),
                  );
                },
                 child: const Text('Cheekbones Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
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
                        builder: (context) => const Scansfacesymmetrycards()),
                  );
                },
                child: const Text('Face Symmetry Scan ➤', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20), ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(9), // Adjust the radius as needed
                  ),
                   fixedSize: const Size(320, 100)
                ),
              ),
            ),
               
         
          ],
        ),
      ),
    );
  }
}
