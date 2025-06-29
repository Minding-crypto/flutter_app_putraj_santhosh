import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Hairrec extends StatelessWidget {
  final String results;

  const Hairrec({super.key, required this.results});

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
  header: 'Maintain a Healthy Diet',
  recommendation:
      'Ensure your diet is rich in vitamins and minerals, particularly iron, vitamin D, and proteins. Foods like spinach, eggs, and fish can promote hair health.',
),
RecommendationItem(
  header: 'Avoid Harsh Treatments',
  recommendation:
      'Limit the use of chemical treatments like dyes, perms, and relaxers. Avoid excessive heat styling with blow dryers, curling irons, and straighteners.',
),
RecommendationItem(
  header: 'Use Gentle Hair Care Products',
  recommendation:
      'Choose shampoos and conditioners that are free from sulfates and parabens. Look for products with ingredients like biotin, keratin, and natural oils.',
),
RecommendationItem(
  header: 'Practice Good Hair Hygiene',
  recommendation:
      'Wash your hair regularly to remove dirt and excess oil. Use lukewarm water instead of hot water to prevent drying out your scalp and hair.',
),
RecommendationItem(
  header: 'Avoid Tight Hairstyles',
  recommendation:
      'Styles that pull on your hair, such as ponytails, braids, and buns, can cause hair breakage. Opt for loose hairstyles to reduce stress on your hair.',
),
RecommendationItem(
  header: 'Manage Stress',
  recommendation:
      'High stress levels can lead to hair loss. Practice stress-reducing activities like yoga, meditation, and regular exercise to improve overall health and hair condition.',
),
RecommendationItem(
  header: 'Consult a Professional',
  recommendation:
      'If hair loss persists, consult a dermatologist or a trichologist. They can offer medical treatments like minoxidil, finasteride, or low-level laser therapy tailored to your specific condition.',
),
RecommendationItem(
  header: 'Consider Supplements',
  recommendation:
      'Supplements like biotin, omega-3 fatty acids, and zinc can support hair growth. Always consult with a healthcare provider before starting any new supplement regimen.',
),
RecommendationItem(
  header: 'Use Hair Oils',
  recommendation:
      'Natural oils like coconut, argan, castor, and rosemary oil can nourish the scalp and strengthen hair. Apply the oil to your scalp and hair, and massage gently.',
),
RecommendationItem(
  header: 'Explore Medical Treatments',
  recommendation:
      'Medical treatments such as minoxidil (Rogaine) and finasteride (Propecia) are FDA-approved for hair loss. Consult with a healthcare provider to determine the best treatment for your situation.',
),
RecommendationItem(
  header: 'Stay Hydrated',
  recommendation:
      'Drinking plenty of water is essential for overall health and helps to keep your scalp and hair hydrated.',
),
RecommendationItem(
  header: 'Regular Scalp Massage',
  recommendation:
      'Massaging your scalp can improve blood circulation and stimulate hair follicles. Use natural oils like coconut or argan oil for added benefits.',
),
RecommendationItem(
  header: 'Get Regular Trims',
  recommendation:
      'Regular trims help remove split ends and prevent hair breakage, promoting healthier and stronger hair growth.',
),
RecommendationItem(
  header: 'Use Silk or Satin Pillowcases',
  recommendation:
      'Switching to silk or satin pillowcases can reduce hair friction and breakage compared to cotton pillowcases.',
),
RecommendationItem(
  header: 'Avoid Excessive Brushing',
  recommendation:
      'Brushing your hair too often or too harshly can cause hair breakage. Use a wide-tooth comb and be gentle when detangling.',
),
//add more items for more recommendations

      ];
   
    }
  }

