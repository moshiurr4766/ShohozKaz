import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shohozkaz/core/constants.dart';

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';
  bool searched = false;

  final List<Map<String, dynamic>> allJobs = [
    {
      'title': 'Electric',
      'company': 'No(Person)',
      'location': 'Dhaka, Bangladesh',
      'salary': '1000/Day',
      'type': 'Part-time',
      'date': DateTime(2025, 7, 4),
    },
    {
      'title': 'Expert Plumber',
      'company': 'Dhaka Plumbing Services',
      'location': 'Gulshan, Dhaka',
      'salary': '15,000 - 20,000 /month',
      'type': 'Full-time',
      'date': DateTime(2023, 11, 15),
    },
    {
      'title': 'Electrician for Commercial Buildings',
      'company': 'Chittagong Electric Co.',
      'location': 'Agrabad, Chittagong',
      'salary': '18,000 - 55,000 /month',
      'type': 'Full-time',
      'date': DateTime(2023, 11, 12),
    },
    {
      'title': 'Driver',
      'company': 'City Transports',
      'location': 'Uttara, Dhaka',
      'salary': '12,000 /month',
      'type': 'Full-time',
      'date': DateTime(2024, 1, 7),
    },
    {
      'title': 'Domestic Helper Helper  Helper',
      'company': 'Home Services',
      'location': 'Banani, Dhaka',
      'salary': '8,000 /month',
      'type': 'Part-time',
      'date': DateTime(2024, 2, 18),
    },
    // Duplicate for demo purposes
    {
      'title': 'Electric',
      'company': 'No(Person)',
      'location': 'Dhaka, Bangladesh',
      'salary': '1000/Day',
      'type': 'Part-time',
      'date': DateTime(2025, 7, 4),
    },
    {
      'title': 'Expert Plumber',
      'company': 'Dhaka Plumbing Services',
      'location': 'Gulshan, Dhaka',
      'salary': '15,000 - 20,000 /month',
      'type': 'Full-time',
      'date': DateTime(2023, 11, 15),
    },
    {
      'title': 'Electrician for Commercial Buildings',
      'company': 'Chittagong Electric Co.',
      'location': 'Agrabad, Chittagong',
      'salary': '18,000 - 55,000 /month',
      'type': 'Full-time',
      'date': DateTime(2023, 11, 12),
    },
    {
      'title': 'Driver',
      'company': 'City Transports',
      'location': 'Uttara, Dhaka',
      'salary': '12,000 /month',
      'type': 'Full-time',
      'date': DateTime(2024, 1, 7),
    },
    {
      'title': 'Domestic Helper Helper  Helper',
      'company': 'Home Services',
      'location': 'Banani, Dhaka',
      'salary': '8,000 /month',
      'type': 'Part-time',
      'date': DateTime(2024, 2, 18),
    },
    {
      'title': 'Driver',
      'company': 'City Transports',
      'location': 'Uttara, Dhaka',
      'salary': '12,000 /month',
      'type': 'Full-time',
      'date': DateTime(2024, 1, 7),
    },
  ];

  List<Map<String, dynamic>> get filteredJobs {
    if (!searched || query.isEmpty) return allJobs;
    final q = query.toLowerCase();
    return allJobs.where((job) {
      return job.values.any(
        (value) => value.toString().toLowerCase().contains(q),
      );
    }).toList();
  }

  void _onSearch() {
    setState(() {
      query = _searchController.text.trim();
      searched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double spacing = 14;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16, top:0),
          child: Text(
            'Find Local Jobs',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        toolbarHeight: 60,
        //centerTitle: true,
        actions: [
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Iconsax.notification),
                ),
              ),
            ],

      ),
      body: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by skill,location or company',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFFFF6B00)
                            : const Color(0xFFFF6B00),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_outlined,
                        color: AppColors.button,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF6F2FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF6B00), // Orange text
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _onSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    child: const Text('Find Jobs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: spacing),
            Expanded(
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: spacing,
                crossAxisSpacing: spacing,
                itemCount: filteredJobs.length,
                itemBuilder: (context, index) =>
                    _buildJobCard(filteredJobs[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: job['type'] == 'Full-time'
                          ? Colors.purple
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job['type'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['title'],
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    job['company'],
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          job['location'],
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: ' ৳',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 74, 72, 72),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const WidgetSpan(child: SizedBox(width: 4)),
                          TextSpan(
                            text: job['salary'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.button,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Posted ${DateFormat('MM/dd/yyyy').format(job['date'])}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(1, 1),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.button,
                        ),
                        child: const Text(
                          'View',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
