import 'package:flutter/material.dart';
import 'package:instaclone/results/jawlineresults.dart';

class Faceshaperec extends StatelessWidget {
  final String results;

  const Faceshaperec({super.key, required this.results});

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
      backgroundColor:  const Color.fromARGB(255, 0, 0, 0),
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
   List<String> resultsList = results.split(', ');
String labels = resultsList[0];
   if (labels == 'Face Shape: Diamond' ) {
  return [
    RecommendationItem(
      header: 'Hairstyles',
      recommendation:
          'Shorter styles that add width at the chin and forehead. Side-swept bangs (e.g., pixie cut with side-swept bangs). Chin-length bobs (e.g., chin-length bob) or shoulder-length cuts with layers (e.g., shoulder-length layered cut).',
    ),
    RecommendationItem(
      header: 'Eyebrow Shape',
      recommendation:
          'Curved brows to soften the angles (e.g., softly curved brows). Keep the brows neat and not overly thick.',
    ),
    RecommendationItem(
      header: 'Glasses',
      recommendation:
          'Oval or rimless frames (e.g., oval-shaped glasses). Glasses that have more width than depth (e.g., rimless glasses).',
    ),
    RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'Shorter beards to avoid elongating the face (e.g., short boxed beard). Chin straps or goatees can work well (e.g., goatee). Avoid long, pointy beards.',
    ),
  ];
} else if (labels == 'Face Shape: Round'  ) {
  return [
    RecommendationItem(
      header: 'Hairstyles',
      recommendation:
          'Long layers to add length to the face (e.g., long layered cut). High updos and top knots (e.g., high bun). Asymmetrical cuts and side parts (e.g., asymmetrical bob).',
    ),
    RecommendationItem(
      header: 'Eyebrow Shape',
      recommendation:
          'High-arched brows to create vertical lines (e.g., high-arched brows). Avoid rounded shapes to counterbalance the face\'s natural roundness.',
    ),
    RecommendationItem(
      header: 'Glasses',
      recommendation:
          'Angular frames such as square or rectangular (e.g., square glasses). Glasses with a wider top frame (e.g., cat-eye glasses).',
    ),
    RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'Beards with defined lines and angles (e.g., boxed beard). Goatees and short boxed beards (e.g., goatee). Avoid full, bushy beards that add more roundness.',
    ),
  ];
} else if (labels == 'Face Shape: Oblong'  ) {
  return [
    RecommendationItem(
      header: 'Hairstyles',
      recommendation:
          'Soft, rounded layers (e.g., soft layered cut). Bangs to shorten the length of the face (e.g., straight-across bangs). Medium length cuts with waves or curls (e.g., shoulder-length wavy cut).',
    ),
    RecommendationItem(
      header: 'Eyebrow Shape',
      recommendation:
          'Flat brows to shorten the face’s length (e.g., flat eyebrows). Keep the brows straight rather than arched.',
    ),
    RecommendationItem(
      header: 'Glasses',
      recommendation:
          'Tall frames that add width (e.g., tall rectangular glasses). Decorative or contrasting temples to add width to the face (e.g., glasses with decorative temples).',
    ),
    RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'Fuller beards to add width to the face (e.g., full beard). Mutton chops or sideburns can also work well (e.g., mutton chops). Avoid long, pointy beards that elongate the face.',
    ),
  ];
} else if (labels == 'Face Shape: Square'  ) {
 return [
    RecommendationItem(
      header: 'Hairstyles',
      recommendation:
          'Soft, wispy bangs or side-swept bangs (e.g., wispy bangs). Styles with curls or waves to soften jawline (e.g., wavy lob). Medium to long layers with texture (e.g., layered long cut).',
    ),
    RecommendationItem(
      header: 'Eyebrow Shape',
      recommendation:
          'Slightly curved or softly angled brows (e.g., softly angled brows). Avoid overly sharp or flat shapes.',
    ),
    RecommendationItem(
      header: 'Glasses',
      recommendation:
          'Oval or round frames to soften the angles (e.g., round glasses). Glasses with more width than height (e.g., oval glasses).',
    ),
    RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'Shorter beards with a rounded shape (e.g., short rounded beard). Goatees and circle beards (e.g., circle beard). Avoid square-shaped beards that emphasize the jawline.',
    ),
  ];
} else if (labels == 'Face Shape: Heart'  ) {
  return [
    RecommendationItem(
      header: 'Hairstyles',
      recommendation:
          'Chin-length or longer styles to balance the width of the forehead (e.g., chin-length bob). Side-swept bangs or long layers (e.g., side-swept bangs). Soft curls or waves around the chin (e.g., long wavy cut).',
    ),
    RecommendationItem(
      header: 'Eyebrow Shape',
      recommendation:
          'Rounded brows to soften the forehead (e.g., rounded brows). Keep the brows more natural and not too thick.',
    ),
    RecommendationItem(
      header: 'Glasses',
      recommendation:
          'Bottom-heavy frames to add width to the lower face (e.g., aviator glasses). Round or oval frames (e.g., oval glasses).',
    ),
    RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'Beards that add fullness to the lower face (e.g., full beard). Balbo or full beards (e.g., balbo beard). Avoid styles that emphasize the chin.',
    ),
  ];
} else if (labels == 'Face Shape: Oval'  ) {
 return [
    RecommendationItem(
      header: 'Hairstyles',
      recommendation:
          'Almost any style works well (e.g., long layered cut). Long layers, bobs, or shoulder-length cuts (e.g., shoulder-length bob). Experiment with various bangs and partings (e.g., curtain bangs).',
    ),
    RecommendationItem(
      header: 'Eyebrow Shape',
      recommendation:
          'Softly arched brows (e.g., softly arched brows). Maintain the natural shape without over-plucking.',
    ),
    RecommendationItem(
      header: 'Glasses',
      recommendation:
          'Any style works, but oversized frames can complement the balanced proportions (e.g., oversized round glasses). Experiment with different shapes to highlight features.',
    ),
    RecommendationItem(
      header: 'Beard Shapes',
      recommendation:
          'Almost any beard style works well (e.g., stubble beard). Stubble, full beards, and goatees (e.g., goatee). Experiment with different styles to find what highlights your features best.',
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