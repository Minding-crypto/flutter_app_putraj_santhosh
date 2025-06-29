import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Jawlinerec extends StatelessWidget {
  final String results;

  const Jawlinerec({super.key, required this.results});

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
  header: 'Facial Exercises',
  recommendation: 'Regularly do exercises targeting the jawline, such as chin lifts, jaw clenches, and neck rotations.',
),
RecommendationItem(
  header: 'Healthy Diet',
  recommendation: 'Maintain a balanced diet rich in fruits, vegetables, lean proteins, and whole grains to reduce overall body fat.',
),
RecommendationItem(
  header: 'Sleep Quality',
  recommendation: 'Ensure you get enough quality sleep each night, as inadequate sleep can lead to fluid retention and puffiness in the face.',
),

RecommendationItem(
  header: 'Hydration',
  recommendation: 'Drink plenty of water to keep the skin hydrated and promote overall skin health for a sculpted appearance.',
),
RecommendationItem(
  header: 'Proper Posture',
  recommendation: 'Maintain good posture to prevent sagging skin and promote an elongated neck and jaw area.',
),
RecommendationItem(
  header: 'Facial Massage',
  recommendation: 'Gentle massage techniques focused on the jawline can improve blood circulation and enhance jaw contour.',
),
RecommendationItem(
  header: 'Chewing Gum',
  recommendation: 'Regularly chew sugar-free gum to exercise jaw muscles and promote a defined jawline.',
),
RecommendationItem(
  header: 'Avoid Excess Salt and Sugar',
  recommendation: 'Limit sodium and sugar intake to reduce water retention and bloating for a sharper jawline.',
),
RecommendationItem(
  header: 'Limit Alcohol and Tobacco',
  recommendation: 'Reduce alcohol consumption and avoid smoking to prevent facial bloating and promote skin health.',
),
RecommendationItem(
  header: 'Collagen Supplements',
  recommendation: 'Consider taking collagen supplements or consuming collagen-rich foods to improve skin elasticity.',
),


      ];
   
    }
  }

