import 'package:flutter/material.dart';

class ProfileDetails extends StatelessWidget {
  final String name;
  final String city;
  final String cost;
  final double rating;
  final List<String> tags;
  final String profileImage;
  final String bio;
  final String experience;
  final bool isExpanded;
  final VoidCallback onTap;

  const ProfileDetails({
    Key? key,
    required this.name,
    required this.city,
    required this.cost,
    required this.rating,
    required this.tags,
    required this.profileImage,
    this.bio = '',
    this.experience = '',
    required this.isExpanded,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double textSize = screenWidth * 0.035;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        height: isExpanded ? 380 : 120,
        child: SingleChildScrollView(
          physics: isExpanded
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: screenWidth * 0.06,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: AssetImage(profileImage),
                      onBackgroundImageError: (_, __) => const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: textSize * 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Cost: $cost',
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 20, 164, 95),
                                    fontSize: textSize * 0.9,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  city,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: textSize * 0.9,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Rating: ${rating.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: Colors.orangeAccent,
                                    fontSize: textSize * 0.9,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTags(screenWidth, textSize), // Using the extracted method
                if (isExpanded) ...[
                  const SizedBox(height: 12),
                  if (bio.isNotEmpty) ...[
                    Text(
                      'About',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bio,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: textSize * 0.9,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (experience.isNotEmpty) ...[
                    Text(
                      'Experience',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      experience,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: textSize * 0.9,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTags(double screenWidth, double textSize) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: tags
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenWidth * 0.01,
              ),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: textSize * 0.8,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
