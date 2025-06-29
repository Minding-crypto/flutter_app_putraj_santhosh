import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Agerec extends StatelessWidget {
  final String results;

  const Agerec({super.key, required this.results});

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
        title: const Text('Recommendations', style: TextStyle(fontSize: 20),),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(19.0),
          color: Colors.black,
          
          child:  Column(
         children: [  
          Container(
  padding: const EdgeInsets.only(right: 16, left: 16, top: 7, bottom: 7), // Adjust the value as needed
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

          const SizedBox(height: 40,),
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
                    headerColor: headerColors[index % headerColors.length], // Set header color
                    textColor: textColors[index % textColors.length], // Set text color
                  ),
                  const SizedBox(height: 20), // Adjust the height as needed
                ],
              );
            }).toList(),
          ),
         ]
        ),
        ),
      ),
    );
  }

  // Function to map result label to a specific set of recommendations
  List<RecommendationItem> mapLabelToRecommendations(String results) {
    // Extract the label

      return [
   RecommendationItem(
  header: 'Daily Skincare Routine',
  recommendation: 'Follow a daily skincare routine that includes cleansing, toning, and moisturizing. Use products suitable for your skin type to keep your skin clean, hydrated, and balanced.',
),
RecommendationItem(
  header: 'Sun Protection',
  recommendation: 'Always use a broad-spectrum sunscreen with at least SPF 30, even on cloudy days. Sun protection helps prevent premature aging and reduces the risk of skin cancer.',
),
RecommendationItem(
  header: 'Hydration',
  recommendation: 'Drink plenty of water throughout the day to keep your skin hydrated from the inside out. Aim for at least 8 glasses of water daily.',
),
RecommendationItem(
  header: 'Healthy Diet',
  recommendation: 'Consume a balanced diet rich in antioxidants, vitamins, and minerals. Foods like fruits, vegetables, nuts, and fish can help improve skin elasticity and overall health.',
),
RecommendationItem(
  header: 'Regular Exercise',
  recommendation: 'Engage in regular physical activity to boost circulation and promote healthy, glowing skin. Exercise also helps reduce stress, which can impact skin health.',
),
RecommendationItem(
  header: 'Adequate Sleep',
  recommendation: 'Ensure you get 7-9 hours of quality sleep each night. Sleep is crucial for skin repair and regeneration, helping you maintain a youthful appearance.',
),
RecommendationItem(
  header: 'Avoid Smoking and Limit Alcohol',
  recommendation: 'Avoid smoking and limit alcohol consumption, as both can accelerate skin aging. Smoking reduces blood flow to the skin, while alcohol can dehydrate and damage skin cells.',
),
RecommendationItem(
  header: 'Facial Exercises',
  recommendation: 'Incorporate facial exercises into your routine to strengthen facial muscles and improve skin firmness. These exercises can help reduce the appearance of wrinkles and sagging.',
),
RecommendationItem(
  header: 'Use Anti-Aging Products',
  recommendation: 'Consider using anti-aging skincare products containing ingredients like retinoids, hyaluronic acid, and peptides. These can help reduce the appearance of fine lines and wrinkles.',
),
RecommendationItem(
  header: 'Avoid Excessive Sugar',
  recommendation: 'Limit your sugar intake, as high sugar levels can lead to glycation, which damages collagen and elastin in the skin, contributing to wrinkles and sagging.',
),
RecommendationItem(
  header: 'Manage Stress',
  recommendation: 'Practice stress management techniques such as meditation, yoga, or deep breathing exercises. Chronic stress can accelerate the aging process, so finding ways to relax is important for maintaining youthful skin.',
),
RecommendationItem(
  header: 'Avoid Repetitive Facial Expressions',
  recommendation: 'Minimize repetitive facial expressions, such as frowning or squinting, which can lead to permanent lines and wrinkles over time.',
),
RecommendationItem(
  header: 'Gentle Skin Care',
  recommendation: 'Avoid harsh scrubbing or using abrasive products on your skin. Treat your skin gently to prevent irritation and damage, which can contribute to aging.',
),

      ];
   
    }
  }

