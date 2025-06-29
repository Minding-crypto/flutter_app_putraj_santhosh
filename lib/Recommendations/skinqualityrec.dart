import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Skinqualityrec extends StatelessWidget {
  final String results;

  const Skinqualityrec({super.key, required this.results});

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
  header: 'Maintain a Consistent Skincare Routine',
  recommendation: 'Cleanse your face twice daily with a gentle cleanser to remove dirt, oil, and impurities. Follow with a toner, moisturizer, and sunscreen in the morning. Consistency is key for maintaining clear skin.',
),
RecommendationItem(
  header: 'Use Salicylic Acid',
  recommendation: 'Incorporate products with salicylic acid into your routine. Salicylic acid helps to exfoliate the skin and unclog pores, reducing the occurrence of pimples and blackheads.',
),
RecommendationItem(
  header: 'Try Benzoyl Peroxide',
  recommendation: 'Use a benzoyl peroxide-based spot treatment for active pimples. Benzoyl peroxide kills bacteria that cause acne and helps to dry out existing pimples.',
),
RecommendationItem(
  header: 'Hydrate and Moisturize',
  recommendation: 'Even if you have oily skin, it’s important to keep your skin hydrated. Use a lightweight, non-comedogenic moisturizer to keep your skin balanced and prevent overproduction of oil.',
),
RecommendationItem(
  header: 'Exfoliate Regularly',
  recommendation: 'Use a chemical exfoliant like glycolic acid or lactic acid 1-2 times a week. Exfoliating helps to remove dead skin cells, preventing clogged pores and promoting cell turnover for clearer skin.',
),
RecommendationItem(
  header: 'Avoid Touching Your Face',
  recommendation: 'Keep your hands away from your face to prevent the transfer of bacteria and oil that can cause breakouts. Also, avoid picking or squeezing pimples to reduce the risk of scarring.',
),
RecommendationItem(
  header: 'Watch Your Diet',
  recommendation: 'Maintain a healthy diet with plenty of fruits, vegetables, and whole grains. Reduce your intake of sugary and greasy foods, which can contribute to acne. Drinking plenty of water helps to keep your skin hydrated and flush out toxins.',
),
RecommendationItem(
  header: 'Manage Stress',
  recommendation: 'Stress can trigger acne breakouts. Practice stress-management techniques such as meditation, exercise, or hobbies to keep stress levels in check and improve overall skin health.',
),
RecommendationItem(
  header: 'Keep Your Hair Clean',
  recommendation: 'Wash your hair regularly and keep it away from your face to prevent the transfer of oils and hair products that can clog pores and cause breakouts.',
),
RecommendationItem(
  header: 'Choose Non-Comedogenic Products',
  recommendation: 'Use skincare and makeup products labeled as non-comedogenic. These products are formulated to not clog pores, reducing the likelihood of acne.',
),
RecommendationItem(
  header: 'Use Retinoids',
  recommendation: 'Consider using retinoids, which are derived from vitamin A. Retinoids help to increase cell turnover and prevent clogged pores, making them effective for treating and preventing acne.',
),
RecommendationItem(
  header: 'Stay Hydrated',
  recommendation: 'Drink plenty of water throughout the day to keep your skin hydrated from the inside out. Hydrated skin is less likely to overproduce oil, which can contribute to acne.',
),
RecommendationItem(
  header: 'Get Enough Sleep',
  recommendation: 'Aim for 7-9 hours of quality sleep each night. Lack of sleep can lead to increased stress and inflammation, which can worsen acne.',
),
RecommendationItem(
  header: 'Use Tea Tree Oil',
  recommendation: 'Apply diluted tea tree oil to acne-prone areas. Tea tree oil has natural antibacterial properties that can help reduce acne-causing bacteria and inflammation.',
),
RecommendationItem(
  header: 'Avoid Excessive Sun Exposure',
  recommendation: 'While some sun exposure can help dry out pimples, too much can cause skin damage and worsen acne. Use a non-comedogenic sunscreen with at least SPF 30 daily.',
),
RecommendationItem(
  header: 'Keep Your Pillowcases and Towels Clean',
  recommendation: 'Change your pillowcases and towels regularly. Dirty fabrics can harbor bacteria and oils that contribute to acne.',
),
RecommendationItem(
  header: 'Use a Clay Mask Weekly',
  recommendation: 'Incorporate a clay mask into your routine once a week. Clay masks help to absorb excess oil and draw out impurities from the pores.',
),
RecommendationItem(
  header: 'Avoid Over-Washing and Over-Exfoliating',
  recommendation: 'Washing your face too often or using harsh exfoliants can strip your skin of natural oils, leading to increased oil production and irritation. Stick to gentle cleansing twice a day.',
),
RecommendationItem(
  header: 'Exercise Regularly',
  recommendation: 'Exercise helps improve blood circulation and reduce stress, both of which can benefit your skin. Make sure to shower and cleanse your skin after sweating to prevent clogged pores.',
),
RecommendationItem(
  header: 'Consider Probiotics',
  recommendation: 'Probiotics can help balance the bacteria in your gut, which may improve your skin. You can find probiotics in yogurt, supplements, and fermented foods.',
),
// Add more items for more recommendations as needed
RecommendationItem(
  header: 'Avoid Harsh Chemicals and Fragrances',
  recommendation: 'Choose skincare products that are free of harsh chemicals and fragrances, as these can irritate the skin and exacerbate acne.',
),
RecommendationItem(
  header: 'Use Oil-Free Products',
  recommendation: 'Opt for oil-free and water-based skincare and makeup products to reduce the risk of clogged pores and breakouts.',
),
RecommendationItem(
  header: 'Wash Face After Sweating',
  recommendation: 'Cleanse your face after intense sweating, such as after workouts, to prevent sweat from clogging pores and causing acne.',
),
RecommendationItem(
  header: 'Consider Zinc Supplements',
  recommendation: 'Zinc has anti-inflammatory properties that can help reduce acne. Consult with a healthcare provider before starting any supplements.',
),
RecommendationItem(
  header: 'Practice Good Hygiene',
  recommendation: 'Keep your phone, glasses, and other items that come into contact with your face clean to prevent the transfer of dirt and bacteria.',
),
RecommendationItem(
  header: 'Limit Dairy Intake',
  recommendation: 'Some studies suggest a link between dairy consumption and acne. Try reducing your intake of dairy products to see if it improves your skin.',
),
RecommendationItem(
  header: 'Apply Aloe Vera',
  recommendation: 'Use aloe vera gel to soothe inflamed skin and promote healing. Aloe vera has natural antibacterial and anti-inflammatory properties.',
),
RecommendationItem(
  header: 'Avoid Smoking',
  recommendation: 'Smoking can worsen acne and slow the healing process. Avoiding smoking can improve your overall skin health.',
),
RecommendationItem(
  header: 'Manage Your Weight',
  recommendation: 'Maintaining a healthy weight can help regulate hormone levels, which can, in turn, help control acne.',
),
RecommendationItem(
  header: 'Be Gentle with Your Skin',
  recommendation: 'Avoid scrubbing your skin too hard when washing or exfoliating. Being gentle helps prevent irritation and damage to the skin barrier.',
),
RecommendationItem(
  header: 'Consider Light Therapy',
  recommendation: 'Light therapy devices, available for home use, can help reduce acne by killing bacteria and reducing inflammation.',
),





      ];
   
    }
  }

