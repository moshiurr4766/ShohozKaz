import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/canceled_jobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/completed/completed_jobs.dart';
import 'package:shohozkaz/features/screen/pages/jobs/applyjobs/openjobs/open_jobs_tab.dart';

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
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8, top: 0),
          child: Text(
            'Jobs Status',
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
                  constraints: const BoxConstraints(minHeight: 40, minWidth: 120),
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
                OpenJobsTab(isUser: true,),
                CompletedJobsTab(isUser: true,),
                CanceledJobsTab(isUser: true,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
