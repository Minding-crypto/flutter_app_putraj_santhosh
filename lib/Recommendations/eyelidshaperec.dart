import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Eyelidshaperec extends StatelessWidget {
  final String results;

  const Eyelidshaperec({super.key, required this.results});

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
                        text: 'Hooded Eyes',
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
const SizedBox(height: 10,),
                  ...recommendations.sublist(0, 3).asMap().entries.map((entry) {
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
                        text: 'Monolid Eyes',
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

                  const SizedBox(height: 10,),
                  ...recommendations.sublist(3, 6).asMap().entries.map((entry) {
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
      // Advice for Hooded Eyes
      RecommendationItem(
        header: 'Hairstyles',
        recommendation:
            'Styles with volume at the crown, side parts, or layered cuts can help draw attention upwards. Avoid heavy bangs.',
      ),
      RecommendationItem(
        header: 'Eyebrow Shape',
        recommendation:
            'A slightly higher arch can make the eyes appear larger and more open.',
      ),
      RecommendationItem(
        header: 'Glasses',
        recommendation:
            'Look for glasses with an uplift at the outer corners, such as cat-eye or rectangular frames. Avoid thick frames that can overshadow the eyes.',
      ),
      // Advice for Monolid Eyes
      RecommendationItem(
        header: 'Hairstyles',
        recommendation:
            'Soft waves, side-swept bangs, and layered cuts add dimension and draw attention to your eyes. Avoid heavy, straight-across bangs.',
      ),
      RecommendationItem(
        header: 'Eyebrow Shape',
        recommendation:
            'A straight brow shape complements the monolid eye shape well.',
      ),
      RecommendationItem(
        header: 'Glasses',
        recommendation:
            'Look for wider frames that can add definition, such as rectangular or oval frames. Avoid overly decorative frames that can overpower the face.',
      ),
    ];
  }
}
