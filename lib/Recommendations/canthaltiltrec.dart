import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Canthaltiltrec extends StatelessWidget {
  final String results;

  const Canthaltiltrec({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    List<RecommendationItem> recommendations = mapLabelToRecommendations(results);

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
          padding: const EdgeInsets.only(left: 19.0, right: 19.0, top: 30, bottom: 30),
          color: Colors.black,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 16, left: 16, top: 7, bottom: 7),
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
                children: recommendations.asMap().entries.map((entry) {
                  int index = entry.key;
                  RecommendationItem recommendation = entry.value;
                  return Column(
                    children: [
                      RecommendationCard(
                        recommendation: recommendation,
                        index: index,
                        headerColor: headerColors[index % headerColors.length],
                        textColor: textColors[index % textColors.length], cardHeight: 250,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to map result label to a specific set of recommendations
  List<RecommendationItem> mapLabelToRecommendations(String results) {

    return [
      RecommendationItem(
        header: 'Eyebrow Shaping',
        recommendation: 'Keep your eyebrows well-groomed with a natural yet defined shape. Trim any stray hairs and slightly arch the brows to give a more lifted appearance. Avoid over-plucking to maintain a masculine look.',
      ),
      RecommendationItem(
        header: 'Beard and Facial Hair',
        recommendation: 'Maintain a well-groomed beard or facial hair with clean lines near the cheekbones to draw attention upwards and enhance the overall facial appearance.',
      ),
      RecommendationItem(
        header: 'Short, Layered Haircuts',
        recommendation: 'Opt for short, layered haircuts that add volume to the top of your head. This helps balance your face and draws attention upwards, making the eye area appear more lifted.',
      ),
      RecommendationItem(
        header: 'Side Part Hairstyle',
        recommendation: 'Consider a side part hairstyle to create a more structured and lifted look. The asymmetry can help divert attention from the eye area and balance your facial features.',
      ),
      RecommendationItem(
        header: 'Upward-Sweeping Frames',
        recommendation: 'Choose eyeglasses with frames that have an upward sweep, like subtle cat-eye or upswept designs, to give the illusion of a more positive canthal tilt.',
      ),
      RecommendationItem(
        header: 'Eye Lifting Exercises',
        recommendation: 'Perform eye exercises to strengthen the muscles around the eyes. Gently lift your eyebrows with your fingers and hold for a few seconds, repeating several times daily to help create a more lifted appearance.',
      ),
      RecommendationItem(
        header: 'Adequate Sleep',
        recommendation: 'Ensure you get enough sleep to avoid puffiness and droopy eyes. Aim for 7-9 hours of quality sleep per night to maintain a refreshed and lifted eye appearance.',
      ),
      RecommendationItem(
        header: 'Hydration and Nutrition',
        recommendation: 'Stay hydrated and maintain a diet rich in antioxidants and vitamins. Foods rich in vitamin C and E can help improve skin firmness and the appearance of the eye area.',
      ),
      RecommendationItem(
        header: 'Skincare Routine',
        recommendation: 'Adopt a regular skincare routine that includes cleansing, moisturizing, and using eye creams with ingredients like hyaluronic acid or retinol to keep the skin around your eyes firm and youthful.',
      ),
      RecommendationItem(
        header: 'Good Posture',
        recommendation: 'Maintain good posture by keeping your back straight and shoulders back. Good posture can help improve overall facial symmetry and make your eyes appear more lifted and alert.',
      ),
    ];
  }
}
