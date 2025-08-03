import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';


class MyJobsScreen extends StatefulWidget {
  const MyJobsScreen({super.key});

  @override
  State<MyJobsScreen> createState() => _MyJobsScreenState();
}

class _MyJobsScreenState extends State<MyJobsScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = ['Open', 'Completed', 'Canceled'];
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 16, top: 0),
          child: Text(
            'My Jobs',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ToggleButtons(
                  isSelected: List.generate(3, (i) => i == selectedTab),
                  onPressed: (index) => setState(() => selectedTab = index),
                  borderRadius: BorderRadius.circular(12),
                  selectedColor: colorScheme.primary,
                  fillColor: colorScheme.surface,
                  color: colorScheme.onSurface.withOpacity(0.6),
                  borderColor: Colors.transparent,
                  selectedBorderColor: colorScheme.primary,
                  constraints: const BoxConstraints(minHeight: 40, minWidth: 100),
                  children: tabs
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(e, style: const TextStyle(fontWeight: FontWeight.w500)),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: const [
                OpenJobsTab(),
                CompletedJobsTab(),
                CanceledJobsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OpenJobsTab extends StatelessWidget {
  const OpenJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Map<String, dynamic>> jobs = [
      {
        'title': 'Apartment Rewiring',
        'client': 'Bashundhara Group',
        'date': '2023-11-05',
        'progress': 0.75,
      },
      {
        'title': 'Install new AC unit',
        'client': 'Salim Ahmed',
        'date': '2023-11-10',
        'progress': 0.2,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? []
                : [const BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
              Text(job['client'], style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 8),
              Text('Start Date: ${job['date']}', style: TextStyle(color: colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('Progress', style: TextStyle(color: colorScheme.onSurface)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: job['progress'],
                backgroundColor: Colors.grey[300],
                color: colorScheme.primary,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text('${(job['progress'] * 100).toInt()}%', style: TextStyle(color: colorScheme.onSurface)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("View Details"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CompletedJobsTab extends StatelessWidget {
  const CompletedJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Map<String, dynamic>> jobs = [
      {
        'title': 'Electric',
        'employer': 'No(Person)',
        'date': '2025-07-04',
        'earnings': '৳2,500',
        'feedback': '',
        'employerRating': 0,
        'yourRating': 0,
      },
      {
        'title': 'Plumbing for kitchen sink',
        'employer': 'Shahidul Islam',
        'date': '2023-10-20',
        'earnings': '৳1,999',
        'feedback': 'Excellent work, very professional and quick.',
        'employerRating': 5,
        'yourRating': 0,
      },
      {
        'title': 'Electrical wiring for new office',
        'employer': 'Anisul Khan',
        'date': '2023-10-15',
        'earnings': '৳3,900',
        'feedback': 'Highly skilled electrician. Did a great job.',
        'employerRating': 5,
        'yourRating': 4,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? []
                : [const BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
              Text(job['employer'], style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 8),
              Text('Date: ${job['date']}', style: TextStyle(color: colorScheme.onSurface)),
              Text('Earnings: ${job['earnings']}', style: TextStyle(color: colorScheme.onSurface)),
              const SizedBox(height: 6),
              if (job['employerRating'] > 0)
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(Icons.star, size: 16, color: i < job['employerRating'] ? Colors.amber : Colors.grey[300]),
                  ),
                ),
              if (job['feedback'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(job['feedback'], style: TextStyle(color: colorScheme.onSurface)),
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Rate Employer"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CanceledJobsTab extends StatelessWidget {
  const CanceledJobsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Map<String, String>> jobs = [
      {
        'title': 'Garden Landscaping',
        'with': 'Rehana Begum',
        'date': '2023-10-18',
        'reason': 'Employer changed their mind about the project scope.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: Theme.of(context).brightness == Brightness.dark
                ? []
                : [const BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(job['title']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              Text('With ${job['with']}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
              const SizedBox(height: 8),
              Text("Canceled on: ${job['date']}", style: TextStyle(color: colorScheme.onSurface)),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: colorScheme.onSurface),
                  children: [
                    const TextSpan(text: "Reason: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: job['reason']),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
