import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Lipsrec extends StatelessWidget {
  final String results;

  const Lipsrec({super.key, required this.results});

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
  header: 'Hydrate Regularly',
  recommendation: 'Drink plenty of water throughout the day to keep your lips and body hydrated. Dehydration can make your lips dry and chapped.',
),
RecommendationItem(
  header: 'Use Lip Balm',
  recommendation: 'Apply a moisturizing lip balm with SPF to protect your lips from the sun and keep them hydrated. Look for ingredients like shea butter, coconut oil, and beeswax.',
),
RecommendationItem(
  header: 'Exfoliate Weekly',
  recommendation: 'Gently exfoliate your lips once a week to remove dead skin cells. You can use a lip scrub or make your own using sugar and honey. This will keep your lips smooth and soft.',
),
RecommendationItem(
  header: 'Avoid Licking Your Lips',
  recommendation: 'Licking your lips can make them dry out faster. Saliva evaporates quickly, leaving your lips drier than before. Instead, use lip balm for moisture.',
),
RecommendationItem(
  header: 'Stay Away from Irritants',
  recommendation: 'Avoid using products with harsh chemicals, fragrances, or allergens that can irritate your lips. Opt for hypoallergenic and natural products.',
),
RecommendationItem(
  header: 'Healthy Diet',
  recommendation: 'Maintain a balanced diet rich in vitamins and minerals. Vitamins like B, C, and E are particularly good for skin health, including your lips.',
),
RecommendationItem(
  header: 'Avoid Smoking',
  recommendation: 'Smoking can cause your lips to darken and dry out. Quitting smoking can improve the overall health and appearance of your lips.',
),
RecommendationItem(
  header: 'Use a Humidifier',
  recommendation: 'If you live in a dry climate or use heating and air conditioning frequently, consider using a humidifier to add moisture to the air and prevent your lips from drying out.',
),
RecommendationItem(
  header: 'Remove Lipstick Before Bed',
  recommendation: 'Always remove any lipstick or lip products before going to bed. Use a gentle makeup remover or a natural oil like coconut oil to clean your lips.',
),
RecommendationItem(
  header: 'Overnight Treatment',
  recommendation: 'Apply a thick layer of lip balm or a dedicated overnight lip treatment before bed to let it work its magic while you sleep.',
),
RecommendationItem(
  header: 'Massage Your Lips',
  recommendation: 'Gently massage your lips with your fingertips to increase blood circulation. This can help your lips look fuller and healthier.',
),
RecommendationItem(
  header: 'Use Natural Remedies',
  recommendation: 'Consider using natural remedies like applying aloe vera gel, honey, or cucumber slices on your lips for added moisture and healing properties.',
),
RecommendationItem(
  header: 'Protect from Extreme Weather',
  recommendation: 'In harsh weather conditions like extreme cold or wind, make sure to protect your lips with a scarf or a protective lip balm to prevent chapping and dryness.',
),



      ];
   
    }
  }

