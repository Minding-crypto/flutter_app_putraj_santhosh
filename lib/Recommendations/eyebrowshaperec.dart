import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Eyebrowshaperec extends StatelessWidget {
  final String results;

  const Eyebrowshaperec({super.key, required this.results});

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
  header: 'Shape and Groom',
  recommendation: 'Once you have identified your natural eyebrow shape, use tweezers to remove stray hairs while preserving the natural arch. Be careful not to over-pluck, as this can lead to thinning.',
),


RecommendationItem(
  header: 'Fill in Sparse Areas',
  recommendation: 'Use an eyebrow pencil, powder, or pomade that matches your natural hair color to fill in sparse areas. Apply in short, hair-like strokes for a natural look. Blend with a spoolie brush.',
),


RecommendationItem(
  header: 'Nourish Your Brows',
  recommendation: 'Use eyebrow serums or natural oils, such as castor oil, to nourish your eyebrows and promote growth. Apply regularly to see improvements in thickness and strength.',
),
// Add more items for more recommendations


RecommendationItem(
  header: 'Maintain a Healthy Diet',
  recommendation: 'Ensure a healthy diet rich in vitamins and minerals like Vitamin E, B vitamins, and Omega-3 fatty acids, which can promote hair growth and improve the overall health of your eyebrows.',
),
RecommendationItem(
  header: 'Avoid Over-Plucking',
  recommendation: 'Avoid plucking your eyebrows too frequently or too much at once. Give your brows time to grow back and follow their natural shape for the best results.',
),
RecommendationItem(
  header: 'Clean Up the Unibrow',
  recommendation: 'Use tweezers to remove hairs between your brows. Aim for a natural look by keeping the space proportional to your facial features, usually the width of your nose bridge.',
),

RecommendationItem(
  header: 'Consider Tinting',
  recommendation: 'If your eyebrows are very light or graying, consider eyebrow tinting. A professional tint can add subtle color and make your brows look fuller and more defined.',
),
RecommendationItem(
  header: 'Trim Regularly',
  recommendation: 'Use small, sharp scissors to trim long eyebrow hairs. Brush your eyebrows upwards with a spoolie brush and carefully trim any hairs that extend beyond your natural shape.',
),


      ];
   
    }
  }

