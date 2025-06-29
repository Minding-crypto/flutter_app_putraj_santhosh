import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Skintyperec extends StatelessWidget {
  final String results;

  const Skintyperec({super.key, required this.results});

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
        title: const Text(
          'Recommendations',
          style: TextStyle(fontSize: 20),
        ),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(19.0),
          color: Colors.black,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.only(
                  right: 16,
                  left: 16,
                  top: 7,
                  bottom: 7), // Adjust the value as needed
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
            const SizedBox(
              height: 40,
            ),
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
                      headerColor: headerColors[
                          index % headerColors.length], // Set header color
                      textColor: textColors[
                          index % textColors.length], // Set text color
                    ),
                    const SizedBox(height: 20), // Adjust the height as needed
                  ],
                );
              }).toList(),
            ),
          ]),
        ),
      ),
    );
  }

  // Function to map result label to a specific set of recommendations
  List<RecommendationItem> mapLabelToRecommendations(String results) {
    // Extract the label
    String label = results;

    if (label == 'Dry') {
      return [
      RecommendationItem(
  header: 'Hydration',
  recommendation:
      'Drink plenty of water throughout the day to keep your skin hydrated from within.',
),
RecommendationItem(
  header: 'Moisturize Regularly',
  recommendation:
      'Use a rich, oil-based moisturizer at least twice daily to lock in moisture. Look for ingredients like hyaluronic acid, glycerin, and ceramides.',
),
RecommendationItem(
  header: 'Avoid Over-Washing',
  recommendation:
      'Limit your face washing to twice a day and after sweating heavily. Over-washing can strip your skin of natural oils.',
),
RecommendationItem(
  header: 'Use a Humidifier:',
  recommendation:
      'If you live in a dry climate or spend time in air-conditioned/heated environments, consider using a humidifier. It adds moisture to the air and helps prevent skin dryness.',
),
RecommendationItem(
  header: 'Pat Dry, Don’t Rub',
  recommendation:
      'After washing your face or taking a shower, gently pat your skin dry with a soft towel instead of rubbing it to avoid irritation.',
),
RecommendationItem(
  header: 'Avoid Long, Hot Showers',
  recommendation:
      'Keep your showers short and use lukewarm water instead of hot, as hot water can strip your skin of natural oils.',
),
RecommendationItem(
  header: 'Sleep on a Silk Pillowcase',
  recommendation:
      'Use a silk pillowcase to reduce friction on your skin while you sleep, which can help retain moisture and prevent irritation.',
),
RecommendationItem(
  header: 'Avoid Tobacco and Alcohol',
  recommendation:
      'Limit alcohol consumption and avoid smoking, as both can dehydrate your skin and accelerate aging.',
),
RecommendationItem(
  header: 'Gentle Cleansing',
  recommendation:
      'Opt for a mild, fragrance-free cleanser to avoid stripping your skin of its natural oils. Avoid hot water; use lukewarm water instead.',
),
RecommendationItem(
  header: 'Exfoliate Gently',
  recommendation:
      'Exfoliate once or twice a week with a gentle scrub or an exfoliant containing alpha-hydroxy acids (AHAs) to remove dead skin cells and promote skin renewal.',
),
RecommendationItem(
  header: 'Humidify Your Environment',
  recommendation:
      'Use a humidifier in your home, especially during the winter months, to add moisture to the air and prevent your skin from drying out.',
),
RecommendationItem(
  header: 'Sun Protection',
  recommendation: 
      'Always apply a broad-spectrum sunscreen with at least SPF 30 before going outside, even on cloudy days, to protect your skin from UV damage.',
),
RecommendationItem(
  header: 'Healthy Diet',
  recommendation:
      'Consume a balanced diet rich in omega-3 fatty acids, vitamins, and antioxidants to nourish your skin. Include foods like fish, nuts, seeds, fruits, and vegetables.',
),
RecommendationItem(
  header: 'Avoid Irritants',
  recommendation:
      'Stay away from harsh skincare products, alcohol-based toners, and scented lotions that can irritate and dry out your skin.',
),
RecommendationItem(
  header: 'Use a Face Mask',
  recommendation:
      'Incorporate hydrating face masks into your skincare routine once or twice a week for an extra moisture boost.',
),
RecommendationItem(
  header: 'Night Care Routine',
  recommendation:
      'Apply a thicker night cream or sleeping mask before bed to help your skin repair and retain moisture overnight.',
),
RecommendationItem(
  header: 'Collagen-Boosting Foods',
  recommendation: 'Incorporate collagen-boosting foods such as bone broth, chicken, fish, and citrus fruits to support skin elasticity and hydration.',
),
RecommendationItem(
  header: 'Protein-Rich Foods',
  recommendation: 'Ensure an adequate intake of lean proteins like chicken, turkey, tofu, and legumes to support skin repair and regeneration.',
),
// Add more items for additional recommendations
      ];
    } if (label == 'Combination') {
  return [
    RecommendationItem(
      header: 'Balanced Cleansing',
      recommendation:
          'Use a gentle cleanser that balances oil production without stripping the skin. Consider a foaming or gel-based cleanser.',
    ),
    RecommendationItem(
      header: 'Toning',
      recommendation:
          'Apply a gentle, alcohol-free toner to help rebalance the skin’s pH levels and tighten pores without drying out the skin.',
    ),
    RecommendationItem(
      header: 'Moisturize Strategically',
      recommendation:
          'Use a lightweight, oil-free moisturizer on areas that tend to be oily, and a richer moisturizer on dry patches. Consider a gel moisturizer for overall hydration without greasiness.',
    ),
    RecommendationItem(
      header: 'Spot Treat',
      recommendation:
          'Use targeted treatments like salicylic acid or benzoyl peroxide on oily areas to control breakouts, and hydrating serums on dry areas to nourish and soothe.',
    ),
    RecommendationItem(
      header: 'Sun Protection',
      recommendation:
          'Apply a non-comedogenic, oil-free sunscreen with at least SPF 30 daily to protect all areas of your skin from UV damage.',
    ),
    RecommendationItem(
      header: 'Exfoliate Regularly',
      recommendation:
          'Exfoliate 1-2 times a week with a gentle exfoliant to remove dead skin cells and promote a smoother, more even skin tone. Avoid harsh scrubs that can irritate the skin.',
    ),
    RecommendationItem(
      header: 'Hydrating Masks',
      recommendation:
          'Incorporate hydrating masks into your routine to provide extra moisture to dry areas without adding excess oil to oily areas. Use 1-2 times a week as needed.',
    ),
    RecommendationItem(
      header: 'Control Oil Production',
      recommendation:
          'Use oil-absorbing sheets or mattifying primers in the T-zone to control shine throughout the day without clogging pores or over-drying the skin.',
    ),
    RecommendationItem(
      header: 'Avoid Heavy Products',
      recommendation:
          'Steer clear of heavy, occlusive products that can clog pores and exacerbate oiliness. Opt for lightweight, non-comedogenic formulas.',
    ),
    RecommendationItem(
      header: 'Diet and Hydration',
      recommendation:
          'Maintain a balanced diet rich in fruits, vegetables, and lean proteins. Drink plenty of water to keep your skin hydrated from within.',
    ),
    // Add more items for additional recommendations
  ];
}

    else if (label == 'Oily') {
      return [
       RecommendationItem(
  header: 'Cleansing',
  recommendation: 'Use a gentle, foaming cleanser to remove excess oil without stripping your skin. Cleanse your face twice a day, morning and night.',
),
RecommendationItem(
  header: 'Exfoliation',
  recommendation: 'Exfoliate 1-2 times a week using a chemical exfoliant like salicylic acid. This helps to remove dead skin cells and prevent clogged pores.',
),
RecommendationItem(
  header: 'Moisturizing',
  recommendation: 'Choose an oil-free, non-comedogenic moisturizer to keep your skin hydrated without adding excess oil.',
),
RecommendationItem(
  header: 'Sun Protection',
  recommendation: 'Always use a broad-spectrum sunscreen with at least SPF 30. Look for formulas that are oil-free and non-comedogenic.',
),
RecommendationItem(
  header: 'Diet and Hydration',
  recommendation: 'Maintain a balanced diet rich in fruits, vegetables, and lean proteins. Drink plenty of water to keep your skin hydrated from within.',
),
RecommendationItem(
  header: 'Avoid Over-Washing',
  recommendation: 'Avoid washing your face too frequently as it can strip your skin of natural oils, prompting your skin to produce even more oil.',
),
RecommendationItem(
  header: 'Blotting Papers',
  recommendation: 'Carry blotting papers with you to quickly absorb excess oil without disturbing your makeup throughout the day.',
),
RecommendationItem(
  header: 'Hydrating Serums',
  recommendation: 'Incorporate hydrating serums with hyaluronic acid to keep your skin moisturized without adding oil.',
),
RecommendationItem(
  header: 'Silk Pillowcases',
  recommendation: 'Consider using silk pillowcases, as they reduce friction on your skin, minimize irritation, and are less likely to absorb moisture and oils.',
),
RecommendationItem(
  header: 'Eat Antioxidant-Rich Foods',
  recommendation: 'Incorporate foods rich in antioxidants, like berries, leafy greens, and nuts, to help protect your skin from damage and reduce inflammation.',
),
RecommendationItem(
  header: 'Omega-3 Fatty Acids',
  recommendation: 'Include sources of omega-3 fatty acids, such as salmon, flaxseeds, and walnuts, which can help regulate oil production and maintain skin health.',
),
RecommendationItem(
  header: 'Limit Sugary Foods',
  recommendation: 'Reduce your intake of sugary foods and drinks, as high sugar levels can lead to increased oil production and breakouts.',
),
RecommendationItem(
  header: 'Avoid Greasy Foods',
  recommendation: 'Avoid consuming too many greasy or fried foods, which can exacerbate oily skin and contribute to clogged pores.',
),
//add more items for more recommendations

// Add more items for additional recommendations
      ];
    } else if (label == 'Normal') {
      return [
        RecommendationItem(
  header: 'Daily Cleansing:',
  recommendation:
      'Use a gentle cleanser twice a day to remove dirt, oil, and impurities without stripping your skin of its natural oils. Look for a pH-balanced cleanser suitable for normal skin.',
),
RecommendationItem(
  header: 'Hydration is Key:',
  recommendation:
      'Keep your skin well-hydrated by using a lightweight, non-comedogenic moisturizer. Look for ingredients like hyaluronic acid or glycerin that lock in moisture without clogging pores.',
),
RecommendationItem(
  header: 'Sun Protection:',
  recommendation:
      'Apply a broad-spectrum sunscreen with SPF 30 or higher every day, even on cloudy days. Sun protection helps prevent premature aging and protects against skin cancer.',
),
RecommendationItem(
  header: 'Exfoliation:',
  recommendation:
      'Incorporate gentle exfoliation 1-2 times a week to remove dead skin cells and promote cell turnover. Choose a chemical exfoliant like alpha hydroxy acids (AHAs) or beta hydroxy acids (BHAs) for a mild yet effective exfoliation.',
),
RecommendationItem(
  header: 'Healthy Diet:',
  recommendation:
      'Eat a balanced diet rich in fruits, vegetables, lean proteins, and healthy fats. Nutrient-rich foods can promote healthy skin from the inside out.',
),
RecommendationItem(
  header: 'Stay Hydrated:',
  recommendation:
      'Drink plenty of water throughout the day to keep your skin hydrated and maintain its elasticity. Hydration also helps flush out toxins from your body.',
),
RecommendationItem(
  header: 'Manage Stress:',
  recommendation:
      "Practice stress-relieving activities such as yoga, meditation, or deep breathing exercises. Chronic stress can affect your skin's appearance, so managing stress is crucial for overall skin health.",
),
RecommendationItem(
  header: 'Get Enough Sleep:',
  recommendation:
      'Prioritize quality sleep for at least 7-8 hours each night. Sleep allows your skin to repair and regenerate, leading to a healthier complexion.',
),
RecommendationItem(
  header: 'Exercise Regularly:',
  recommendation:
      "Engage in regular physical activity to boost blood circulation and promote healthy skin. Exercise also helps reduce stress levels, which can improve your skin's appearance.",
),
RecommendationItem(
  header: 'Limit Hot Showers:',
  recommendation:
      'While hot showers can be relaxing, they can also strip your skin of moisture. Opt for lukewarm water and limit shower time to prevent dryness.',
),
RecommendationItem(
  header: 'Use a Humidifier:',
  recommendation:
      'If you live in a dry climate or spend time in air-conditioned/heated environments, consider using a humidifier. It adds moisture to the air and helps prevent skin dryness.',
),
RecommendationItem(
  header: 'Choose Silk or Satin Pillowcases:',
  recommendation:
      'Opt for silk or satin pillowcases instead of cotton. Silk and satin are smoother and cause less friction, reducing the likelihood of wrinkles and creases on your skin.',
),
RecommendationItem(
  header: 'Change Pillowcases Regularly:',
  recommendation:
      'Change your pillowcases at least once a week to prevent the buildup of dirt, oil, and bacteria. Clean pillowcases help maintain a clean sleeping environment for your skin.',
)

      ];
    } 
    
    else {
      return [
        RecommendationItem(
          header: 'No specific recommendations available.',
          recommendation: '',
        ),
      ]; // Default value for unexpected labels
    }
  }
}


/*RecommendationItem(
          header: '',
          recommendation:
              '',
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation:
              "",
        ),
        RecommendationItem(
          header: '',
          recommendation: "",
           
        ),
        //add more items for more recommednations


You
i am creating ann app to scan face, and there is a specific scan for red eyes, and every scan has a recommendation page which tells us teh user how to imporve according to the result of their scan, waht should my recommendations page be for the red eyes, on how to imporve the eye area and imrpove the red eyes*/