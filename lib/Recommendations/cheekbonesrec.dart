import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Cheekbonesrec extends StatelessWidget {
  final String results;

  const Cheekbonesrec({super.key, required this.results});

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
        title: const Text('Recommendations', style: TextStyle(fontSize: 20)),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(19.0),
          color: Colors.black,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    right: 16, left: 16, top: 7, bottom: 7), // Adjust the value as needed
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
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Center(
                    child: RichText(
                      text: const TextSpan(
                        text: 'Advice For High Cheekbones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Color.fromARGB(255, 255, 255, 255), // Change underline color
                        ),
                      ),
                    ),
                  ),
const SizedBox(height: 14,),
                  ...recommendations.sublist(0, 4).asMap().entries.map((entry) {
                    int index = entry.key;
                    RecommendationItem recommendation = entry.value;
                    return Column(
                      children: [
                        RecommendationCard(
                          cardHeight: 250,
                          recommendation: recommendation,
                          index: index,
                          headerColor: headerColors[index % headerColors.length],
                          textColor: textColors[index % textColors.length],
                        ),
                        const SizedBox(height: 20), // Adjust the height as needed
                      ],
                    );
                  }).toList(),
                  const SizedBox(height: 40),
                Center(
                    child: RichText(
                      text: const TextSpan(
                        text: 'Advice For Low Cheekbones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Color.fromARGB(255, 255, 255, 255), // Change underline color
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14,),
                  ...recommendations.sublist(4, 8).asMap().entries.map((entry) {
                    int index = entry.key;
                    RecommendationItem recommendation = entry.value;
                    return Column(
                      children: [
                        RecommendationCard(
                          cardHeight: 250,
                          recommendation: recommendation,
                          index: index,
                          headerColor: headerColors[index % headerColors.length],
                          textColor: textColors[index % textColors.length],
                        ),
                        const SizedBox(height: 20), // Adjust the height as needed
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to map result label to a specific set of recommendations
  List<RecommendationItem> mapLabelToRecommendations(String results) {
    // Extract the label

    return [
      // Advice for Faces with High Cheekbones
      RecommendationItem(
        header: 'Hairstyles',
        recommendation:
            'Opt for hairstyles that add volume to the top of the head to balance the prominence of high cheekbones. Soft waves, layers, and side-swept bangs can help soften the angularity.',
      ),
      RecommendationItem(
        header: 'Eyebrow Shape',
        recommendation:
            'Go for a softly curved or slightly arched eyebrow shape to complement the natural structure of high cheekbones. Avoid overly dramatic or thin eyebrows.',
      ),
      RecommendationItem(
        header: 'Glasses',
        recommendation:
            'Choose glasses with rounded or oval frames to soften the angularity of the face. Frames that sit higher on the nose bridge can also complement high cheekbones well.',
      ),
      RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'A beard that is fuller on the sides and shorter on the chin can help balance high cheekbones. Avoid styles that are too angular or sharp, as they can emphasize the cheekbones even more.',
    ),
  

      // Advic
      //e for Monolid Eyes
       RecommendationItem(
        header: 'Hairstyles',
        recommendation:
            'Opt for hairstyles that add volume around the cheek area to create the illusion of higher cheekbones. Styles like chin-length bobs, layers, and curls can be very flattering.',
      ),
      RecommendationItem(
        header: 'Eyebrow Shape',
        recommendation:
            'Consider a slightly higher arch in the eyebrows to draw attention upwards and create a lifting effect, which can enhance the appearance of cheekbones.',
      ),
      RecommendationItem(
        header: 'Glasses',
        recommendation:
            'Choose glasses with wider frames or cat-eye shapes to draw attention to the cheek area and create the illusion of higher cheekbones. Avoid overly narrow or small frames.',
      ),
      RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'A beard style that is fuller on the chin and jawline can help add definition and structure to the lower face, which can enhance the appearance of the cheekbones. Styles like a well-groomed goatee or a short boxed beard can be effective.',
    ),
  ];
  }
}
