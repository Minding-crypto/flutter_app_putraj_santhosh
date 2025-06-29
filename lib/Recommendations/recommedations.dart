import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class RecommendationsPage extends StatelessWidget {
  final String results;

  const RecommendationsPage({super.key, required this.results});

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
        title: const Text('Recommendations'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 30),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.black,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recommendations.asMap().entries.map((entry) {
              int index = entry.key;
              RecommendationItem recommendation = entry.value;
              return Column(
                children: [
                  RecommendationCard(cardHeight: 250,
                    recommendation: recommendation,
                    index: index,
                    headerColor: headerColors[index % headerColors.length], // Set header color
                    textColor: textColors[index % textColors.length], // Set text color
                  ),
                  const SizedBox(height: 20), // Adjust the height as needed
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Function to map result label to a specific set of recommendations
  List<RecommendationItem> mapLabelToRecommendations(String results) {
    // Extract the label
    String label = results;

    // Map the label to a specific set of recommendations
    if (label == 'You have a average jawline') {
      return [
        RecommendationItem(
          header: 'Recommendations for average jawline',
          recommendation:
              'Regularly doing facial exercises like chin lifts, jaw juts, jaw stretches, mewing, fish face exercises, and tongue presses can help tone the muscles around your jaw and chin area, making your jawline appear more defined. Chin lifts target the muscles in your neck and chin, while jaw juts stretch the muscles at the front of your neck. Jaw stretches open your mouth wide, working the muscles of your jaw and neck. Mewing involves maintaining proper tongue posture against the roof of your mouth, which can help improve jawline definition over time. Fish face exercises and tongue presses target the muscles in your cheeks, jawline, and neck. Aim to perform each exercise 10-15 times for best results.',
        ),
        RecommendationItem(
          header: 'Hydration',
          recommendation:
              "Proper hydration is essential for achieving a sharper jawline. When you're dehydrated, your body retains water, leading to bloating and obscuring your jawline. Drinking plenty of water helps reduce water retention, improves skin elasticity, and supports muscle definition. Aim for at least 8 glasses (about 2 liters) of water per day to stay hydrated and enhance your jawline definition.",
        ),
        RecommendationItem(
          header: 'Healthy Diet',
          recommendation:
              "Maintaining a healthy diet is crucial for reducing overall body fat and achieving a sharper jawline. Focus on eating lean proteins, such as chicken, turkey, fish, tofu, and legumes, as well as plenty of fruits, vegetables, and whole grains. Avoid processed foods, sugary snacks, and excessive sodium intake, as they can lead to bloating and water retention, which may obscure your jawline. By prioritizing whole, nutrient-dense foods and limiting processed foods, you can support your efforts to reduce body fat and define your jawline.",
        ),
        RecommendationItem(
          header: 'Quality Sleep',
          recommendation:
              "Getting enough quality sleep is crucial for achieving a sharper jawline. Aim for 7-9 hours of sleep each night to allow your body to rest and recover. Poor sleep can lead to increased stress hormone levels, which can contribute to water retention and puffiness in the face. During sleep, your body also repairs and rejuvenates itself, including your skin and facial muscles. By prioritizing quality sleep, you can help reduce water retention and puffiness, allowing your jawline to appear more defined.",
        ),
        RecommendationItem(
          header: 'Avoid Alcohol and Tobacco',
          recommendation:
              "Avoiding excessive alcohol consumption and tobacco is essential for achieving a sharper jawline. Both alcohol and smoking can contribute to bloating and water retention, which may obscure your jawline. Alcohol is dehydrating and can lead to water retention, causing puffiness in the face. Similarly, smoking can lead to inflammation and reduced blood flow to the skin, which can also contribute to puffiness and a less defined jawline. By minimizing alcohol consumption and avoiding tobacco products, you can reduce bloating and water retention, allowing your jawline to appear sharper and more defined.",
        ),
        RecommendationItem(
          header: 'Cardiovascular Exercise',
          recommendation:
              "Engaging in regular cardiovascular exercise such as running, swimming, or cycling is important for achieving a sharper jawline. Cardiovascular exercise helps to burn overall body fat, including fat around the face and neck area. By incorporating activities like running, swimming, or cycling into your routine, you can increase your heart rate and calorie expenditure, leading to fat loss throughout your body, including your jawline. Aim for at least 150 minutes of moderate-intensity or 75 minutes of vigorous-intensity cardiovascular exercise each week to support your efforts in reducing body fat and defining your jawline.",
        ),
      ];
    } else if (label == 'You have a strong jawline') {
      return [
        RecommendationItem(
          header: 'Facial Exercises',
          recommendation:
              'Regularly doing facial exercises can help tone the muscles around your jaw and chin area, making your jawline appear more defined. Some effective exercises include chin lifts, jaw juts, and jaw stretches.',
        ),
        RecommendationItem(
          header: 'Recommendations for strong jawline',
          recommendation: 'Recommendation 2 for strong jawline',
        ),
      ];
    } else {
      return [
        RecommendationItem(
          header: 'No specific recommendations available.',
          recommendation: '',
        ),
      ]; // Default value for unexpected labels
    }
  }
}
