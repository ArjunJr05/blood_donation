// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:blood/utils/request_util.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  List<ProfileData> _getProfiles() {
    return [
      ProfileData(
        name: "Vijay Kumar",
        city: "Puducherry, India",
        cost: "₹500/day",
        rating: 4.8,
        tags: [
          "Plumbing",
          "Pipe Fitting",
          "Water Heater",
          "Bathroom Repair",
          "Emergency Service"
        ],
        profileImage: "assets/images/profile2.jpeg",
        bio:
            "Expert plumber with 12 years of experience in residential and commercial plumbing. Specialized in leak detection, pipe installation, and emergency repairs. Available 24/7 for urgent plumbing issues.",
        experience:
            "• Lead Plumber at City Services (2018-present)\n• Independent Contractor (2012-2018)\n• Certified in Advanced Plumbing Technologies",
      ),
      ProfileData(
        name: "Shiva Prasad",
        city: "Puducherry, India",
        cost: "₹600/day",
        rating: 4.6,
        tags: [
          "Carpentry",
          "Furniture Making",
          "Wood Work",
          "Cabinet Installation",
          "Custom Design"
        ],
        profileImage: "assets/images/profile5.jpeg",
        bio:
            "Skilled carpenter specializing in custom furniture making and wooden installations. Expert in both traditional and modern carpentry techniques. Known for attention to detail and quality craftsmanship.",
        experience:
            "• Master Carpenter at Fine Woodworks (2015-present)\n• Furniture Designer at HomeStyle (2010-2015)\n• Certified in Advanced Woodworking",
      ),
      ProfileData(
        name: "Sarathy M",
        city: "Puducherry, India",
        cost: "₹450/day",
        rating: 4.3,
        tags: [
          "Electrical",
          "Wiring",
          "Fan Installation",
          "LED Lighting",
          "Circuit Repair"
        ],
        profileImage: "assets/images/profile4.jpeg",
        bio:
            "Licensed electrician with expertise in residential and small commercial electrical systems. Specialized in modern lighting solutions and smart home electrical setups.",
        experience:
            "• Senior Electrician at PowerTech (2016-present)\n• Residential Electrician (2013-2016)\n• Licensed Electrical Contractor",
      ),
      ProfileData(
        name: "Bala Krishnan",
        city: "Puducherry, India",
        cost: "₹400/day",
        rating: 4.5,
        tags: [
          "Painting",
          "Wall Finishing",
          "Waterproofing",
          "Interior",
          "Exterior"
        ],
        profileImage: "assets/images/profile1.jpeg",
        bio:
            "Professional painter with extensive experience in both interior and exterior painting. Expert in various finishing techniques and waterproofing solutions. Uses premium quality materials for lasting results.",
        experience:
            "• Lead Painter at ColorPro Services (2017-present)\n• Interior Specialist at HomePaint (2014-2017)\n• Certified in Advanced Paint Applications",
      ),
      ProfileData(
        name: "Arjun Raja",
        city: "Puducherry, India",
        cost: "₹550/day",
        rating: 4.7,
        tags: [
          "HVAC",
          "AC Repair",
          "Installation",
          "Maintenance",
          "Cooling Solutions"
        ],
        profileImage: "assets/images/profile2.jpeg",
        bio:
            "Certified HVAC technician specializing in air conditioning systems. Expert in installation, maintenance, and repair of all major AC brands. Provides energy-efficient cooling solutions.",
        experience:
            "• Senior AC Technician at CoolAir (2019-present)\n• Service Specialist at AC Solutions (2015-2019)\n• Certified in Modern HVAC Systems",
      ),
      ProfileData(
        name: "Ramesh Kumar",
        city: "Puducherry, India",
        cost: "₹475/day",
        rating: 4.4,
        tags: [
          "Masonry",
          "Tiling",
          "Bathroom Work",
          "Floor Installation",
          "Stone Work"
        ],
        profileImage: "assets/images/profile3.jpeg",
        bio:
            "Experienced mason specialized in tile work and stone installations. Expert in both traditional and modern tiling patterns. Known for precise work and beautiful finishing.",
        experience:
            "• Master Mason at BuildRight (2016-present)\n• Tile Specialist at FloorKing (2012-2016)\n• Certified in Advanced Tiling Techniques",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 212, 211, 211),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ProfileManager(profiles: _getProfiles()),
      ),
    );
  }
}

class ProfileManager extends StatefulWidget {
  final List<ProfileData> profiles;

  const ProfileManager({
    Key? key,
    required this.profiles,
  }) : super(key: key);

  @override
  _ProfileManagerState createState() => _ProfileManagerState();
}

class _ProfileManagerState extends State<ProfileManager> {
  int? expandedIndex;

  void toggleProfile(int index) {
    setState(() {
      expandedIndex = expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.profiles.length,
        (index) => ProfileDetails(
          name: widget.profiles[index].name,
          city: widget.profiles[index].city,
          cost: widget.profiles[index].cost,
          rating: widget.profiles[index].rating,
          tags: widget.profiles[index].tags,
          profileImage: widget.profiles[index].profileImage,
          bio: widget.profiles[index].bio,
          experience: widget.profiles[index].experience,
          isExpanded: expandedIndex == index,
          onTap: () => toggleProfile(index),
        ),
      ),
    );
  }
}

// Data class to hold profile information
class ProfileData {
  final String name;
  final String city;
  final String cost;
  final double rating;
  final List<String> tags;
  final String profileImage;
  final String bio;
  final String experience;

  ProfileData({
    required this.name,
    required this.city,
    required this.cost,
    required this.rating,
    required this.tags,
    required this.profileImage,
    this.bio = '',
    this.experience = '',
  });
}
