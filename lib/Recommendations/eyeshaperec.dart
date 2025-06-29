import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Eyeshaperec extends StatelessWidget {
  final String results;

  const Eyeshaperec({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    List<RecommendationItem> recommendations =
        mapLabelToRecommendations(results);

    List<Color> textColors = [
      const Color.fromARGB(255, 191, 191, 191),
      const Color.fromARGB(255, 191, 191, 191),
      const Color.fromARGB(255, 191, 191, 191),
      const Color.fromARGB(255, 191, 191, 191),
      const Color.fromARGB(255, 191, 191, 191),
      const Color.fromARGB(255, 191, 191, 191),
    ];

    List<Color> headerColors = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recommendations',
          style: TextStyle(fontSize: 20),
        ),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      backgroundColor:  const Color.fromARGB(255, 0, 0, 0),
      body: SingleChildScrollView(
        child: Container(
          
          padding: const EdgeInsets.all(19.0),
          color: Colors.black,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.only(
                  right: 16,
                  left: 16,
                  top: 7,
                  bottom: 7), // Adjust the value as needed
              child: const Text(
                'Improve Yourself',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 85, 0, 255),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendations.asMap().entries.map((entry) {
                int index = entry.key;
                RecommendationItem recommendation = entry.value;
                return Column(
                  children: [
                    RecommendationCard(
                      cardHeight: 250,
                      recommendation: recommendation,
                      index: index,
                      headerColor: headerColors[
                          index % headerColors.length], // Set header color
                      textColor: textColors[
                          index % textColors.length], // Set text color
                    ),
                    const SizedBox(height: 20), // Adjust the height as needed
                  ],
                );
              }).toList(),
            ),
          ]),
        ),
      ),
    );
  }

  // Function to map result label to a specific set of recommendations
  List<RecommendationItem> mapLabelToRecommendations(String results) {
    // Extract the label
   List<String> resultsList = results.split(', ');
String labels = resultsList[0];
    if (labels == 'Left Eye Shape: Deep-set Eyes' ) {
      return [
        RecommendationItem(
          header: 'Hairstyles',
          recommendation:
              'Soft, side-swept bangs or hairstyles with volume at the crown can complement deep-set eyes. Avoid heavy, straight-across bangs that may overshadow the eyes.',
        ),
        RecommendationItem(
          header: 'Eyebrow Shape',
          recommendation:
              'Well-defined and slightly arched eyebrows can help frame deep-set eyes. Avoid overly thin or heavily arched brows.',
        ),
        RecommendationItem(
          header: 'Glasses',
          recommendation:
              'Look for frames that add width and balance to the face, such as oversized or bold styles. Rimless or semi-rimless frames can also work well without overwhelming the eyes.',
        ),
      ];
    } else if (labels == 'Left Eye Shape: Almond Eyes' ) {
      return [
        RecommendationItem(
          header: 'Hairstyles',
          recommendation:
              'Side-swept bangs, soft waves, and layered cuts can frame almond eyes beautifully. Avoid heavy bangs that cover your eyes.',
        ),
        RecommendationItem(
          header: 'Eyebrow Shape',
          recommendation:
              'Softly arched brows enhance the natural shape of almond eyes. Keep them well-groomed and defined.',
        ),
        RecommendationItem(
          header: 'Glasses',
          recommendation:
              'Almond eyes can pull off various styles. Try cat-eye frames, rectangular frames, or aviators to highlight the eye shape.',
        ),
      ];
    } else if (labels == 'Left Eye Shape: Round Eyes' ) {
      return [
        RecommendationItem(
          header: 'Hairstyles',
          recommendation:
              'Long, straight styles or shoulder-length cuts with layers help elongate the face. Avoid hairstyles that add too much volume around the cheeks.',
        ),
        RecommendationItem(
          header: 'Eyebrow Shape',
          recommendation:
              'A higher arch in the eyebrows can give the appearance of more length to round eyes.',
        ),
        RecommendationItem(
          header: 'Glasses',
          recommendation:
              'Rectangular or angular frames can balance the roundness of your eyes. Avoid round frames as they can emphasize the round shape.',
        ),
      ];
    }  else {
      return [
        RecommendationItem(
          header: 'No specific recommendations available.',
          recommendation: '',
        ),
      ]; // Default value for unexpected labels
    }
  }
}


/*RecommendationItem(
          header: '',
          recommendation:
              '',
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation: "",
           
        ),
        //add more items for more recommednations


You
i am creating ann app to scan face, and there is a specific scan for red eyes, and every scan has a recommendation page which tells us teh user how to imporve according to the result of their scan, waht should my recommendations page be for the red eyes, on how to imporve the eye area and imrpove the red eyes*/