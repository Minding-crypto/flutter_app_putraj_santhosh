import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Eyequalityrec extends StatelessWidget {
  final String results;

  const Eyequalityrec({super.key, required this.results});

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
                     
                      recommendation: recommendation,
                      index: index,
                      headerColor: headerColors[
                          index % headerColors.length], // Set header color
                      textColor: textColors[
                          index % textColors.length], 
                          cardHeight: 250,// Set text color
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

    if (label == 'Red Eyes') {
      return [
        RecommendationItem(
          header: 'Stay Hydrated',
          recommendation:
              'Drinking plenty of water helps maintain overall eye health and reduces redness. Aim for at least 8 glasses of water a day.',
        ),
        RecommendationItem(
          header: 'Get Enough Sleep',
          recommendation:
              'Ensure you get 7-9 hours of sleep each night. Lack of sleep can cause eye strain and redness.',
        ),
        RecommendationItem(
          header: 'Reduce Screen Time',
          recommendation:
              'Take regular breaks from screens (20-20-20 rule: every 20 minutes, look at something 20 feet away for at least 20 seconds) to prevent eye strain.',
        ),
        RecommendationItem(
          header: 'Use Artificial Tears',
          recommendation:
              'If you experience dry eyes, use artificial tears to lubricate your eyes. This can help reduce redness caused by dryness.',
        ),
        RecommendationItem(
          header: 'Avoid Allergens',
          recommendation:
              'Identify and avoid allergens that can cause eye redness, such as pollen, pet dander, and dust. Use air purifiers and keep your living space clean.',
        ),
        RecommendationItem(
          header: 'Limit Alcohol and Caffeine',
          recommendation:
              'Reduce your intake of alcohol and caffeine, as they can dehydrate you and contribute to red eyes.',
        ),
        RecommendationItem(
          header: 'Apply Cold Compresses',
          recommendation:
              'Applying a cold compress to your eyes can reduce redness and soothe irritation. Use a clean, damp cloth and apply it to closed eyes for a few minutes.',
        ),
        RecommendationItem(
          header: 'Practice Good Eye Hygiene',
          recommendation:
              'Ensure you wash your hands before touching your eyes and remove makeup thoroughly before bed to avoid irritation and infection.',
        ),
        RecommendationItem(
          header: 'Wear Sunglasses',
          recommendation:
              'Protect your eyes from UV rays and environmental irritants by wearing sunglasses when you’re outside.',
        ),
        RecommendationItem(
          header: 'Consult a Doctor',
          recommendation:
              'If your red eyes persist, seek medical advice. Persistent redness can be a sign of an underlying condition that may require treatment.',
        ),
// Add more items for additional recommendations
      ];
    } else if (label == 'Eye Bags') {
      return [
        RecommendationItem(
          header: 'Get Adequate Sleep',
          recommendation:
              'Ensure you get 7-9 hours of sleep per night. Proper rest helps reduce the appearance of dark circles and puffiness around the eyes.',
        ),
        RecommendationItem(
          header: 'Stay Hydrated',
          recommendation:
              'Drink plenty of water throughout the day to keep your skin hydrated and reduce puffiness under the eyes.',
        ),
        RecommendationItem(
          header: 'Use a Cold Compress',
          recommendation:
              'Apply a cold compress, such as chilled cucumber slices or a cold spoon, to the eye area for 10-15 minutes to reduce swelling and constrict blood vessels.',
        ),
        RecommendationItem(
          header: 'Elevate Your Head While Sleeping',
          recommendation:
              'Use an extra pillow to elevate your head slightly while you sleep. This helps prevent fluid from pooling under your eyes, reducing puffiness.',
        ),
        RecommendationItem(
          header: 'Apply Eye Creams',
          recommendation:
              'Use eye creams containing ingredients like retinol, hyaluronic acid, or peptides. These can help reduce puffiness, lighten dark circles, and improve skin elasticity.',
        ),
        RecommendationItem(
          header: 'Reduce Salt Intake',
          recommendation:
              'Limit your intake of salty foods, as excess sodium can cause your body to retain water, leading to puffiness under the eyes.',
        ),
        RecommendationItem(
          header: 'Protect Your Eyes from UV Rays',
          recommendation:
              'Wear sunglasses and apply sunscreen around your eyes to protect the delicate skin from harmful UV rays, which can cause premature aging and dark circles.',
        ),
        RecommendationItem(
          header: 'Manage Allergies',
          recommendation:
              'If you suffer from allergies, take appropriate measures such as using antihistamines or eye drops. Allergies can cause inflammation and dark circles under the eyes.',
        ),

        RecommendationItem(
          header: 'Healthy Diet and Lifestyle',
          recommendation:
              'Maintain a balanced diet rich in vitamins and antioxidants, and avoid smoking and excessive alcohol consumption. These habits promote overall skin health and reduce eye bags.',
        ),
// Add more items for additional recommendations
      ];
    } else if (label == 'Dark Circles') {
      return [
        RecommendationItem(
          header: 'Improve Sleep Quality',
          recommendation:
              'Aim for 7-9 hours of quality sleep each night. Proper sleep helps reduce the appearance of dark circles. Establish a regular sleep schedule by going to bed and waking up at the same time every day. Create a restful sleep environment: dark, cool, and quiet. Avoid screens (phones, tablets, computers) at least an hour before bed to improve sleep quality.',
        ),
        RecommendationItem(
          header: 'Adopt a Skincare Routine',
          recommendation:
              'Use a gentle, hydrating eye cream that contains ingredients like hyaluronic acid, vitamin C, and retinol. Apply a cold compress or chilled cucumber slices to your eyes for 10 minutes to reduce puffiness and dark circles. Regularly massage the under-eye area to improve circulation. Always remove makeup before bed to avoid irritation and buildup around the eyes.',
        ),
        RecommendationItem(
          header: 'Improve Your Diet',
          recommendation:
              'Stay hydrated by drinking at least 8 glasses of water daily. Dehydration can make dark circles more noticeable. Eat a balanced diet rich in fruits, vegetables, lean proteins, and whole grains. Incorporate foods high in vitamin C (like oranges and strawberries) and vitamin K (like spinach and broccoli) which help strengthen blood vessel walls. Reduce salt intake to prevent fluid retention and puffiness around the eyes.',
        ),
        RecommendationItem(
          header: 'Protect Your Skin from the Sun',
          recommendation:
              'Always wear sunscreen with at least SPF 30 when going outside, including around your eyes. Wear sunglasses to protect your eyes from UV rays. Consider using a broad-brimmed hat to shield your face from direct sunlight.',
        ),
        RecommendationItem(
          header: 'Reduce Stress',
          recommendation:
              'Practice stress-relieving activities such as yoga, meditation, or deep breathing exercises. Ensure you have regular downtime to relax and unwind.',
        ),
        RecommendationItem(
          header: 'Stay Hydrated',
          recommendation:
              'Drink plenty of water throughout the day to keep your skin hydrated and maintain a healthy complexion. Aim for at least 8 glasses of water daily.',
        ),
        RecommendationItem(
          header: 'Get Regular Exercise',
          recommendation:
              'Engage in regular physical activity to improve blood circulation and reduce the appearance of dark circles. Aim for at least 30 minutes of exercise most days of the week.',
        ),
        RecommendationItem(
          header: 'Avoid Smoking and Limit Alcohol',
          recommendation:
              'Smoking and excessive alcohol consumption can contribute to the appearance of dark circles by affecting blood flow and hydration. Avoid smoking and limit alcohol intake to improve skin health.',
        ),
      ];
    } else if (label == 'Eye Bags') {
      return [
        RecommendationItem(
          header: 'Get Adequate Sleep',
          recommendation:
              'Ensure you get 7-9 hours of sleep per night. Proper rest helps reduce the appearance of dark circles and puffiness around the eyes.',
        ),
        RecommendationItem(
          header: 'Stay Hydrated',
          recommendation:
              'Drink plenty of water throughout the day to keep your skin hydrated and reduce puffiness under the eyes.',
        ),
        RecommendationItem(
          header: 'Use a Cold Compress',
          recommendation:
              'Apply a cold compress, such as chilled cucumber slices or a cold spoon, to the eye area for 10-15 minutes to reduce swelling and constrict blood vessels.',
        ),
        RecommendationItem(
          header: 'Elevate Your Head While Sleeping',
          recommendation:
              'Use an extra pillow to elevate your head slightly while you sleep. This helps prevent fluid from pooling under your eyes, reducing puffiness.',
        ),
        RecommendationItem(
          header: 'Apply Eye Creams',
          recommendation:
              'Use eye creams containing ingredients like retinol, hyaluronic acid, or peptides. These can help reduce puffiness, lighten dark circles, and improve skin elasticity.',
        ),
        RecommendationItem(
          header: 'Reduce Salt Intake',
          recommendation:
              'Limit your intake of salty foods, as excess sodium can cause your body to retain water, leading to puffiness under the eyes.',
        ),
        RecommendationItem(
          header: 'Protect Your Eyes from UV Rays',
          recommendation:
              'Wear sunglasses and apply sunscreen around your eyes to protect the delicate skin from harmful UV rays, which can cause premature aging and dark circles.',
        ),
        RecommendationItem(
          header: 'Manage Allergies',
          recommendation:
              'If you suffer from allergies, take appropriate measures such as using antihistamines or eye drops. Allergies can cause inflammation and dark circles under the eyes.',
        ),

        RecommendationItem(
          header: 'Healthy Diet and Lifestyle',
          recommendation:
              'Maintain a balanced diet rich in vitamins and antioxidants, and avoid smoking and excessive alcohol consumption. These habits promote overall skin health and reduce eye bags.',
        ),
// Add more items for additional recommendations
      ];
    } else if (label == 'Healthy') {
      return [
       RecommendationItem(
  header: 'Hydration',
  recommendation: 'Ensure you are drinking at least 8 glasses of water a day. Proper hydration can help reduce dark circles and puffiness around the eyes.',
),

        RecommendationItem(
  header: 'Sleep',
  recommendation: 'Aim for 7-9 hours of quality sleep each night. Lack of sleep can lead to tired-looking eyes and dark circles.',
),

       RecommendationItem(
  header: 'Sun Protection',
  recommendation: 'Wear sunglasses with UV protection and apply sunscreen around the eyes to prevent sun damage and premature aging.',
),

       RecommendationItem(
  header: 'Eye Cream',
  recommendation: 'Use an eye cream containing ingredients like hyaluronic acid, vitamin C, or retinol to hydrate and rejuvenate the eye area.',
),

      RecommendationItem(
  header: 'Diet',
  recommendation: 'Incorporate foods rich in vitamins A, C, and E, and omega-3 fatty acids into your diet. These nutrients support skin health and can improve the appearance of the eye area.',
),

       RecommendationItem(
  header: 'Reduce Screen Time',
  recommendation: 'Limit your screen time and take regular breaks to reduce eye strain and the formation of dark circles.',
),

      RecommendationItem(
  header: 'Cold Compress',
  recommendation: 'Apply a cold compress to the eyes for a few minutes daily to reduce puffiness and soothe tired eyes.',
),

       RecommendationItem(
  header: 'Avoid Rubbing',
  recommendation: 'Avoid rubbing your eyes as it can cause irritation and damage the delicate skin around the eyes.',
),

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