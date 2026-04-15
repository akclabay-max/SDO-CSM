import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/firestore_service.dart';
import '../../utils/responsive.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  String _filterType = 'all'; // all, service, customerType, office
  String? _selectedFilter;
  Map<String, dynamic> _statistics = {};
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await _firestoreService.getStatistics();
      setState(() {
        _statistics = stats;
        _loadingStats = false;
      });
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() => _loadingStats = false);
    }
  }

  Stream<QuerySnapshot> _getFilteredSubmissions() {
    switch (_filterType) {
      case 'service':
        if (_selectedFilter != null) {
          return _firestoreService.getSubmissionsByService(_selectedFilter!);
        }
        break;
      case 'customerType':
        if (_selectedFilter != null) {
          return _firestoreService.getSubmissionsByCustomerType(
            _selectedFilter!,
          );
        }
        break;
      case 'office':
        if (_selectedFilter != null) {
          return _firestoreService.getSubmissionsByOffice(_selectedFilter!);
        }
        break;
    }
    return _firestoreService.getFormSubmissionsStream();
  }

  Widget _buildMetricCard(String label, dynamic value, IconData icon, BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 480 ? 10.0 : 12.0;
    final labelFontSize = screenWidth < 480 ? 9.0 : 11.0;
    final valueFontSize = screenWidth < 480 ? 16.0 : 20.0;
    final iconSize = screenWidth < 480 ? 20.0 : 24.0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color.fromARGB(255, 90, 156, 243), size: iconSize),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 90, 156, 243),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopListCard(String title, List<dynamic> items) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              const Text('No data available', style: TextStyle(fontSize: 14))
            else
              Column(
                children: items.map<Widget>((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['label'] ?? 'Unknown',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        Text(
                          item['count']?.toString() ?? '0',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideLayout = screenWidth >= 900;
    final cards = [
      _buildMetricCard(
        'Total Submissions',
        _statistics['totalSubmissions'] ?? 0,
        Icons.assignment,
        context,
      ),
      _buildMetricCard(
        'Overall Rating',
        (_statistics['averageOverallRating'] ?? 0.0).toStringAsFixed(2),
        Icons.star,
        context,
      ),
      _buildTopListCard(
        'Top 3 Services',
        _statistics['topServices'] as List<dynamic>? ?? [],
      ),
      _buildTopListCard(
        'Top 3 Offices',
        _statistics['topOffices'] as List<dynamic>? ?? [],
      ),
    ];

    if (isWideLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards
            .map(
              (card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: card,
                ),
              ),
            )
            .toList(),
      );
    }

    // Mobile and tablet layout
    if (screenWidth < 480) {
      // Single column on mobile
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(cards.length, (index) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: cards[index],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderPieChart(BuildContext context) {
    final male = _statistics['genderDistribution']?['Male'] ?? 0;
    final female = _statistics['genderDistribution']?['Female'] ?? 0;
    final total = male + female;
    final chartHeight = Responsive.chartHeight(context);

    if (total == 0) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available'),
        ),
      );
    }

    return SizedBox(
      height: chartHeight,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: [
                      PieChartSectionData(
                        color: const Color.fromARGB(255, 90, 156, 243),
                        value: male.toDouble(),
                        title: '${((male / total) * 100).toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        color: const Color.fromARGB(255, 255, 192, 203),
                        value: female.toDouble(),
                        title:
                            '${((female / total) * 100).toStringAsFixed(1)}%',
                        radius: 60,
                        titleStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: const Color.fromARGB(255, 90, 156, 243),
                      ),
                      const SizedBox(width: 8),
                      Text('Male: $male'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: const Color.fromARGB(255, 255, 192, 203),
                      ),
                      const SizedBox(width: 8),
                      Text('Female: $female'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total: $total',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerTypePieChart(BuildContext context) {
    final customerTypeData =
        _statistics['customerTypeDistribution'] as Map<String, dynamic>? ?? {};
    final chartHeight = Responsive.chartHeight(context);
    final screenWidth = MediaQuery.of(context).size.width;

    if (customerTypeData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available'),
        ),
      );
    }

    final total = customerTypeData.values.fold<int>(
      0,
      (acc, val) => acc + (val as int),
    );

    final List<Color> colors = [
      const Color.fromARGB(255, 90, 156, 243),
      const Color.fromARGB(255, 255, 152, 0),
      const Color.fromARGB(255, 76, 175, 80),
      const Color.fromARGB(255, 244, 67, 54),
      const Color.fromARGB(255, 156, 39, 176),
    ];

    final radiusSize = screenWidth < 480 ? 40.0 : 60.0;
    final titleFontSize = screenWidth < 480 ? 12.0 : 14.0;

    final sections = customerTypeData.entries.toList().asMap().entries.map((e) {
      final index = e.key;
      final entry = e.value;
      final value = (entry.value as int).toDouble();
      final percentage = ((value / total) * 100).toStringAsFixed(1);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: value,
        title: '$percentage%',
        radius: radiusSize,
        titleStyle: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return SizedBox(
      height: chartHeight,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: PieChart(PieChartData(sections: sections))),
              const SizedBox(width: 20),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: customerTypeData.length,
                  itemBuilder: (context, index) {
                    final entry = customerTypeData.entries.toList()[index];
                    final color = colors[index % colors.length];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(width: 12, height: 12, color: color),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveChartSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideLayout = screenWidth > 900;
    final titleFontSize = screenWidth < 480 ? 12.0 : 14.0;

    final genderChart = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender Distribution',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildGenderPieChart(context),
      ],
    );

    final customerTypeChart = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Type Distribution',
          style: TextStyle(fontSize: titleFontSize, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _buildCustomerTypePieChart(context),
      ],
    );

    if (isWideLayout) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: genderChart),
          const SizedBox(width: 16),
          Expanded(child: customerTypeChart),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [genderChart, const SizedBox(height: 20), customerTypeChart],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard - Form Results'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width < 480 ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Section
              if (!_loadingStats)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width < 480 ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildOverviewCards(context),
                    const SizedBox(height: 24),
                    _buildResponsiveChartSection(context),
                    const SizedBox(height: 24),
                  ],
                ),

              // Filter Section
              Text(
                'View Results',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 480 ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 480;
                  
                  if (isMobile) {
                    // Stack layout on mobile
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButton<String>(
                          value: _filterType,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _filterType = value ?? 'all';
                              _selectedFilter = null;
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(
                              value: 'service',
                              child: Text('By Service'),
                            ),
                            DropdownMenuItem(
                              value: 'customerType',
                              child: Text('By Customer Type'),
                            ),
                            DropdownMenuItem(
                              value: 'office',
                              child: Text('By Office'),
                            ),
                          ],
                        ),
                        if (_filterType != 'all') ...[
                          const SizedBox(height: 12),
                          _buildSecondaryFilterDropdown(),
                        ]
                      ],
                    );
                  }
                  
                  // Side-by-side layout on larger screens
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: DropdownButton<String>(
                          value: _filterType,
                          isExpanded: true,
                          onChanged: (value) {
                            setState(() {
                              _filterType = value ?? 'all';
                              _selectedFilter = null;
                            });
                          },
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(
                              value: 'service',
                              child: Text('By Service'),
                            ),
                            DropdownMenuItem(
                              value: 'customerType',
                              child: Text('By Customer Type'),
                            ),
                            DropdownMenuItem(
                              value: 'office',
                              child: Text('By Office'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_filterType != 'all')
                        Expanded(flex: 1, child: _buildSecondaryFilterDropdown()),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Form Submissions List
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 480;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Submissions',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _downloadCurrentSummaries,
                              icon: const Icon(Icons.picture_as_pdf),
                              label: const Text('Download PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 90, 156, 243),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _downloadCurrentSummaries,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('Download PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 90, 156, 243),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ]
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: _getFilteredSubmissions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No submissions found'),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.toList();
                  docs.sort((a, b) {
                    final aTs = (a.data() as Map<String, dynamic>)['timestamp'];
                    final bTs = (b.data() as Map<String, dynamic>)['timestamp'];
                    if (aTs is Timestamp && bTs is Timestamp) {
                      return bTs.compareTo(aTs);
                    }
                    return 0;
                  });

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Service: ${data['selectedService'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Customer Type: ${data['customerType'] ?? 'N/A'} | Age: ${data['age'] ?? 'N/A'} | Sex: ${data['sex'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (data['timestamp'] != null)
                                Text(
                                  _formatDate(data['timestamp']),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _buildSubmissionDetails(data),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _getFilteredSubmissionsOnce() async {
    final snapshot = await _firestoreService.getFormSubmissionsOnce();
    final docs = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      switch (_filterType) {
        case 'service':
          return _selectedFilter == null ||
              data['selectedService'] == _selectedFilter;
        case 'customerType':
          return _selectedFilter == null ||
              data['customerType'] == _selectedFilter;
        case 'office':
          return _selectedFilter == null ||
              data['selectedOffice'] == _selectedFilter;
        default:
          return true;
      }
    }).toList();

    docs.sort((a, b) {
      final aTs = (a.data() as Map<String, dynamic>)['timestamp'];
      final bTs = (b.data() as Map<String, dynamic>)['timestamp'];
      if (aTs is Timestamp && bTs is Timestamp) {
        return bTs.compareTo(aTs);
      }
      return 0;
    });

    return docs;
  }

  Future<Map<String, dynamic>> _calculateFilteredStatistics() async {
    final docs = await _getFilteredSubmissionsOnce();

    if (docs.isEmpty) {
      return {
        'totalSubmissions': 0,
        'genderDistribution': {'Male': 0, 'Female': 0},
        'averageOverallRating': 0.0,
        'ratingsByQuestion': {},
        'topOffices': <Map<String, dynamic>>[],
        'topServices': <Map<String, dynamic>>[],
      };
    }

    int totalSubmissions = docs.length;
    int maleCount = 0;
    int femaleCount = 0;
    List<double> allRatings = [];
    Map<String, List<int>> ratingsByQuestion = {};
    Map<String, int> officeCount = {};
    Map<String, int> serviceCount = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Gender
      if (data['sex'] == 'Male') maleCount++;
      if (data['sex'] == 'Female') femaleCount++;

      // Office counts
      final office = (data['selectedOffice'] as String?)?.trim();
      if (office != null && office.isNotEmpty) {
        officeCount[office] = (officeCount[office] ?? 0) + 1;
      }

      // Service counts
      final service = (data['selectedService'] as String?)?.trim();
      if (service != null && service.isNotEmpty) {
        serviceCount[service] = (serviceCount[service] ?? 0) + 1;
      }

      // Ratings
      final ratings = data['satisfactionRatings'] as List<dynamic>?;
      if (ratings != null) {
        for (var rating in ratings) {
          final value = rating['rating_value'];
          final code = rating['question_code']?.toString() ?? 'Unknown';

          if (value != null && value != 0) {
            allRatings.add(value.toDouble());
            ratingsByQuestion.putIfAbsent(code, () => []);
            ratingsByQuestion[code]!.add(value as int);
          }
        }
      }
    }

    double avgOverallRating = allRatings.isNotEmpty
        ? allRatings.reduce((a, b) => a + b) / allRatings.length
        : 0.0;

    // Calculate average for each question
    Map<String, double> questionAverages = {};
    ratingsByQuestion.forEach((question, ratings) {
      if (ratings.isNotEmpty) {
        questionAverages[question] =
            ratings.reduce((a, b) => a + b) / ratings.length;
      }
    });

    final topOfficesEntries = officeCount.entries.toList();
    topOfficesEntries.sort((a, b) => b.value.compareTo(a.value));
    final topOffices = topOfficesEntries
        .take(3)
        .map((entry) => {'label': entry.key, 'count': entry.value})
        .toList();

    final topServicesEntries = serviceCount.entries.toList();
    topServicesEntries.sort((a, b) => b.value.compareTo(a.value));
    final topServices = topServicesEntries
        .take(3)
        .map((entry) => {'label': entry.key, 'count': entry.value})
        .toList();

    return {
      'totalSubmissions': totalSubmissions,
      'genderDistribution': {'Male': maleCount, 'Female': femaleCount},
      'averageOverallRating': avgOverallRating,
      'ratingsByQuestion': questionAverages,
      'topOffices': topOffices,
      'topServices': topServices,
    };
  }

  Future<void> _downloadCurrentSummaries() async {
    try {
      final docs = await _getFilteredSubmissionsOnce();
      if (!mounted) return;
      if (docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No submissions available for the selected filter.'),
          ),
        );
        return;
      }

      final stats = await _calculateFilteredStatistics();
      if (!mounted) return;
      final filterLabel = _getCurrentFilterLabel();
      final generatedAt = DateTime.now();
      final formattedGeneratedAt =
          '${generatedAt.month}/${generatedAt.day}/${generatedAt.year} ${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}';

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Header(level: 0, text: 'Form Summaries Report'),
            pw.Paragraph(
              text: 'Generated: $formattedGeneratedAt',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.Paragraph(
              text: 'Filter: $filterLabel',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),

            // Total Submissions
            pw.Text(
              'Overview',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Value'],
              data: [
                ['Total Submissions', stats['totalSubmissions'].toString()],
                [
                  'Overall Rating',
                  (stats['averageOverallRating'] as double).toStringAsFixed(2),
                ],
              ],
            ),
            pw.SizedBox(height: 20),

            // Top 3 Services and Offices
            pw.Text(
              'Top 3 Services',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            if ((stats['topServices'] as List).isNotEmpty)
              pw.Table.fromTextArray(
                headers: ['Service', 'Count'],
                data: (stats['topServices'] as List<dynamic>)
                    .map((item) => [item['label'], item['count'].toString()])
                    .toList(),
              )
            else
              pw.Text('No service data available'),
            pw.SizedBox(height: 20),
            pw.Text(
              'Top 3 Offices',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            if ((stats['topOffices'] as List).isNotEmpty)
              pw.Table.fromTextArray(
                headers: ['Office', 'Count'],
                data: (stats['topOffices'] as List<dynamic>)
                    .map((item) => [item['label'], item['count'].toString()])
                    .toList(),
              )
            else
              pw.Text('No office data available'),
            pw.SizedBox(height: 20),

            // Gender Distribution
            pw.Text(
              'Gender Distribution',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Table.fromTextArray(
              headers: ['Gender', 'Count', 'Percentage'],
              data: [
                [
                  'Male',
                  stats['genderDistribution']['Male'].toString(),
                  (stats['totalSubmissions'] > 0
                              ? ((stats['genderDistribution']['Male'] /
                                        stats['totalSubmissions']) *
                                    100)
                              : 0)
                          .toStringAsFixed(1) +
                      '%',
                ],
                [
                  'Female',
                  stats['genderDistribution']['Female'].toString(),
                  (stats['totalSubmissions'] > 0
                              ? ((stats['genderDistribution']['Female'] /
                                        stats['totalSubmissions']) *
                                    100)
                              : 0)
                          .toStringAsFixed(1) +
                      '%',
                ],
              ],
            ),
            pw.SizedBox(height: 20),

            // Average Ratings by Question
            pw.Text(
              'Average Satisfaction Ratings by Question',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            if ((stats['ratingsByQuestion'] as Map).isNotEmpty)
              pw.Table.fromTextArray(
                headers: ['Question', 'Average Rating'],
                data: _getSortedQuestionRatings(
                  stats['ratingsByQuestion'] as Map<String, dynamic>,
                ),
              )
            else
              pw.Text('No rating data available'),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: 'form_summaries.pdf',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
      if (!mounted) return;
    } catch (e) {
      if (mounted) {
        print('Error generating PDF: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to generate PDF at this time.')),
        );
      }
    }
  }

  List<List<String>> _getSortedQuestionRatings(Map<String, dynamic> ratings) {
    final entries = ratings.entries.toList();
    entries.sort((a, b) => _sortQuestions(a.key, b.key));
    return entries
        .map((e) => [e.key, (e.value as double).toStringAsFixed(2)])
        .toList();
  }

  int _sortQuestions(String a, String b) {
    // Extract numeric part from question codes like "SQD1", "SQD2", etc.
    final regExp = RegExp(r'(\d+)');
    final matchA = regExp.firstMatch(a);
    final matchB = regExp.firstMatch(b);

    if (matchA != null && matchB != null) {
      final numA = int.tryParse(matchA.group(1)!) ?? 0;
      final numB = int.tryParse(matchB.group(1)!) ?? 0;
      return numA.compareTo(numB);
    }

    return a.compareTo(b);
  }

  String _getCurrentFilterLabel() {
    switch (_filterType) {
      case 'service':
        return 'Service: ${_selectedFilter ?? 'All Services'}';
      case 'customerType':
        return 'Customer Type: ${_selectedFilter ?? 'All Types'}';
      case 'office':
        return 'Office: ${_selectedFilter ?? 'All Offices'}';
      default:
        return 'All Submissions';
    }
  }

  Widget _buildSecondaryFilterDropdown() {
    if (_filterType == 'service') {
      return FutureBuilder<List<String>>(
        future: _getUniqueServices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return DropdownButton(
              items: [],
              onChanged: null,
              isExpanded: true,
              hint: Text('Loading...'),
            );
          }

          return DropdownButton<String>(
            value: _selectedFilter,
            isExpanded: true,
            hint: const Text('Select Service'),
            onChanged: (value) {
              setState(() => _selectedFilter = value);
            },
            items: snapshot.data!
                .map(
                  (service) =>
                      DropdownMenuItem(value: service, child: Text(service)),
                )
                .toList(),
          );
        },
      );
    } else if (_filterType == 'customerType') {
      return FutureBuilder<List<String>>(
        future: _getUniqueCustomerTypes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return DropdownButton(
              items: [],
              onChanged: null,
              isExpanded: true,
              hint: Text('Loading...'),
            );
          }

          return DropdownButton<String>(
            value: _selectedFilter,
            isExpanded: true,
            hint: const Text('Select Customer Type'),
            onChanged: (value) {
              setState(() => _selectedFilter = value);
            },
            items: snapshot.data!
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
          );
        },
      );
    } else if (_filterType == 'office') {
      return FutureBuilder<List<String>>(
        future: _getUniqueOffices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return DropdownButton(
              items: [],
              onChanged: null,
              isExpanded: true,
              hint: Text('Loading...'),
            );
          }

          return DropdownButton<String>(
            value: _selectedFilter,
            isExpanded: true,
            hint: const Text('Select Office'),
            onChanged: (value) {
              setState(() => _selectedFilter = value);
            },
            items: snapshot.data!
                .map(
                  (office) =>
                      DropdownMenuItem(value: office, child: Text(office)),
                )
                .toList(),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Future<List<String>> _getUniqueServices() async {
    try {
      final snapshot = await _firestoreService.getFormSubmissionsOnce();
      final services = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['selectedService'] != null) {
          services.add(data['selectedService'] as String);
        }
      }

      return services.toList()..sort();
    } catch (e) {
      print('Error getting unique services: $e');
      return [];
    }
  }

  Future<List<String>> _getUniqueCustomerTypes() async {
    try {
      final snapshot = await _firestoreService.getFormSubmissionsOnce();
      final types = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['customerType'] != null) {
          types.add(data['customerType'] as String);
        }
      }

      return types.toList()..sort();
    } catch (e) {
      print('Error getting unique customer types: $e');
      return [];
    }
  }

  Future<List<String>> _getUniqueOffices() async {
    try {
      final snapshot = await _firestoreService.getFormSubmissionsOnce();
      final offices = <String>{};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['selectedOffice'] != null &&
            (data['selectedOffice'] as String).isNotEmpty) {
          offices.add(data['selectedOffice'] as String);
        }
      }

      return offices.toList()..sort();
    } catch (e) {
      print('Error getting unique offices: $e');
      return [];
    }
  }

  Widget _buildSubmissionDetails(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Service', data['selectedService'] ?? 'N/A'),
        _buildDetailRow('Office', data['selectedOffice'] ?? 'N/A'),
        _buildDetailRow('Customer Type', data['customerType'] ?? 'N/A'),
        _buildDetailRow('Age', data['age'].toString()),
        _buildDetailRow('Sex', data['sex'] ?? 'N/A'),
        _buildDetailRow(
          'Citizen Charter Awareness',
          data['citizenCharterAwareness'] ?? 'N/A',
        ),
        _buildDetailRow(
          'Used Citizen Charter',
          data['citizenCharterUsed'] ?? 'N/A',
        ),
        if (data['remarks'] != null && data['remarks'].toString().isNotEmpty)
          _buildDetailRow('Remarks', data['remarks'].toString()),
        const SizedBox(height: 12),
        const Text(
          'Satisfaction Ratings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 8),
        if (data['satisfactionRatings'] != null)
          _buildRatingsTable(data['satisfactionRatings'] as List<dynamic>),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildRatingsTable(List<dynamic> ratings) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text(
              'Question',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Rating',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: [
          for (var rating in ratings)
            DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      rating['question_code']?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    '${rating['rating_value']} - ${rating['rating_label'] ?? ''}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = (timestamp as Timestamp).toDate();
      return '${date.month}/${date.day}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}
