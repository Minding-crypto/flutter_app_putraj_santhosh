import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Sidenoseshaperec extends StatelessWidget {
  final String results;

  const Sidenoseshaperec({super.key, required this.results});

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
/*roman
snub
straight */
  // Function to map result label to a specific set of recommendations
  List<RecommendationItem> mapLabelToRecommendations(String results) {
    // Extract the label
    String label = results;

    if (label == 'Roman') {
      return [
      RecommendationItem(
  header: 'Hairstyles',
  recommendation:
    'People with a Roman nose can benefit from hairstyles that add volume to balance the prominent feature. Consider styles like textured or layered cuts, side-swept bangs, or waves and curls to create a harmonious look.',
),
RecommendationItem(
  header: 'Glasses',
  recommendation:
    'Choose glasses with rounded or oval frames to soften the angularity of a Roman nose. Avoid overly large or small frames, and consider glasses with detailed or bold designs to draw attention away from the nose.',
),
RecommendationItem(
  header: 'Beard Styles',
  recommendation:
    'Beard styles that are fuller on the chin can help balance a Roman nose. Goatees, full beards, and styles that add length to the chin area are effective. Avoid styles that draw attention to the mid-face, such as mustaches alone.',
),
RecommendationItem(
  header: 'Eyebrow Shape',
  recommendation:
    'Soft, well-groomed eyebrows with a natural arch can complement a Roman nose. Avoid overly thin or highly arched brows, as they can exaggerate the nose. Opt for a shape that follows your natural brow line with a slight curve.',
),
// Add more items for additional recommendations
      ];
    } if (label == 'Snub') {
  return [
   RecommendationItem(
  header: 'Hairstyles',
  recommendation:
    'People with a snub nose can opt for hairstyles that add length and volume to the top of the head to balance the smaller nose. Consider high buns, ponytails, voluminous curls, or sleek, straight hair to create a harmonious look.',
),
RecommendationItem(
  header: 'Glasses',
  recommendation:
    'Choose glasses with small to medium frames to avoid overwhelming a snub nose. Rectangular or angular frames can add definition, while avoiding overly large or bold frames that can make the nose appear even smaller.',
),
RecommendationItem(
  header: 'Beard Styles',
  recommendation:
    'For men, maintaining a clean-shaven look or light stubble can complement a snub nose. Avoid heavy, full beards that might overwhelm the face and draw too much attention to the lower part of the face.',
),
RecommendationItem(
  header: 'Eyebrow Shape',
  recommendation:
    'Defined and slightly arched eyebrows can help balance a snub nose. Avoid overly thick or straight brows that can overshadow the nose. A well-groomed, natural arch can add definition to the face.',
),
    // Add more items for additional recommendations
  ];
}

    else if (label == 'Straight') {
      return [
     RecommendationItem(
  header: 'Hairstyles',
  recommendation:
    'People with a straight nose can opt for a variety of hairstyles, as this nose shape is quite versatile. Consider styles that frame the face, such as soft waves, side-swept bangs, or layered cuts. Avoid overly severe styles that might make the face look too angular.',
),
RecommendationItem(
  header: 'Glasses',
  recommendation:
    'Choose glasses that complement the balanced appearance of a straight nose. Oval, round, or cat-eye frames can add softness and contrast. Avoid frames that are too angular or oversized, as they can disrupt the facial harmony.',
),
RecommendationItem(
  header: 'Beard Styles',
  recommendation:
    'For men, a well-groomed beard or stubble can add definition and character to a straight nose. Full beards, goatees, or clean-shaven looks all work well. The key is to keep the beard neat and balanced with the rest of the face.',
),
RecommendationItem(
  header: 'Eyebrow Shape',
  recommendation:
    'Natural, well-defined eyebrows with a slight arch can complement a straight nose. Avoid overly thin or highly dramatic brows. A gentle arch that follows the natural brow line enhances the facial symmetry.',
),
//add more items for more recommendations

// Add more items for additional recommendations
      ];
    } 
    
    else {
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