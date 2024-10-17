import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String greeting;
  final List<FeatureCardData> featureCards;

  const HomePage({
    super.key,
    required this.greeting,
    required this.featureCards,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'What would you like to do today?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: featureCards.length,
              itemBuilder: (context, index) {
                return _buildFeatureCard(featureCards[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(FeatureCardData data) {
    return GestureDetector(
      onTap: data.onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFFF3B8B5), Color(0xFFFFE0B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                data.icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              // Using FittedBox to prevent text overflow
              FittedBox(
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCardData {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  FeatureCardData({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
