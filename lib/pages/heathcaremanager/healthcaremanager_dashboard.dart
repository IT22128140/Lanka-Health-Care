// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lanka_health_care/components/drawers/drawer_HCM.dart';
import 'package:lanka_health_care/services/database.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:lanka_health_care/shared/constants.dart';

class HealthcaremanagerDashboard extends StatefulWidget {
  const HealthcaremanagerDashboard({super.key});

  @override
  State<HealthcaremanagerDashboard> createState() =>
      _HealthcaremanagerDashboardState();
}

class _HealthcaremanagerDashboardState
    extends State<HealthcaremanagerDashboard> {
  DatabaseService database = DatabaseService();

  List<Color> gradientColors = [
    Colors.yellow,
    Colors.blue,
  ];

  GlobalKey monthlyChartKey = GlobalKey();
  GlobalKey weeklyChartKey = GlobalKey();
  GlobalKey dailyChartKey = GlobalKey();

  // Function to capture the chart as an image
  Future<Uint8List?> _captureChart(GlobalKey chartKey) async {
    await Future.delayed(
        const Duration(milliseconds: 100)); // Small delay to allow rendering
    try {
      RenderRepaintBoundary boundary =
          chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      var image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> generatePdfAndDownload() async {
    // Load the custom font (Nunito or Roboto)
    final fontData = await rootBundle.load('lib/fonts/Nunito-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    final monthlyChartImage = await _captureChart(monthlyChartKey);
    final weeklyChartImage = await _captureChart(weeklyChartKey);
    final dailyChartImage = await _captureChart(dailyChartKey);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  AppStrings.healthCareManDashBoard,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 24,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  AppStrings.monthlyAppoinmentsChart,
                  style: pw.TextStyle(font: ttf),
                ),
                if (monthlyChartImage != null)
                  pw.Image(pw.MemoryImage(monthlyChartImage),
                      height: 200, width: 300),
                pw.SizedBox(height: 20),
                pw.Text(
                  AppStrings.weeklyAppoinmentsChart,
                  style: pw.TextStyle(font: ttf),
                ),
                if (weeklyChartImage != null)
                  pw.Image(pw.MemoryImage(weeklyChartImage),
                      height: 200, width: 300),
                pw.SizedBox(height: 20),
                pw.Text(
                  AppStrings.dailyAppoinmentsChart,
                  style: pw.TextStyle(font: ttf),
                ),
                if (dailyChartImage != null)
                  pw.Image(pw.MemoryImage(dailyChartImage),
                      height: 200, width: 300),
              ],
            ),
          );
        },
      ),
    );

    Uint8List pdfBytes = await pdf.save();

    // Create a blob from the byte array and download the PDF
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute(AppStrings.download, AppStrings.healthcareDashboardpdf);
    html.document.body!.append(anchor);
    anchor.click();
    anchor.remove();

    // Revoke the object URL after downloading
    html.Url.revokeObjectUrl(url);
  }

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.healthCareManDashBoard),
      ),
      drawer: const DrawerHcm(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await generatePdfAndDownload(); // Use this function to generate and download the PDF on web
              },
              child: const Text(AppStrings.downloadAsPDF),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          AppStrings.monthlyAppoinments,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Monthly Appointments Chart
                      RepaintBoundary(
                        key: monthlyChartKey,
                        child: SizedBox(
                          height: 500,
                          width: 700,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 18,
                              left: 12,
                              top: 24,
                              bottom: 12,
                            ),
                            child: FutureBuilder<LineChartData>(
                              future: mainData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: Text(AppStrings.errorLoadingData));
                                } else {
                                  return LineChart(snapshot.data!);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  RepaintBoundary(
                    key: weeklyChartKey,
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            AppStrings.weeklyAppoinments,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 500,
                          width: 700,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 18,
                              left: 12,
                              top: 24,
                              bottom: 12,
                            ),
                            child: FutureBuilder<LineChartData>(
                              future: weeklyData(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(
                                      child: Text(AppStrings.errorLoadingData));
                                } else {
                                  return LineChart(snapshot.data!);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                   AppStrings.dailyAppoinments,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RepaintBoundary(
                  key: dailyChartKey,
                  child: SizedBox(
                    height: 500,
                    width: 700,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 18,
                        left: 12,
                        top: 24,
                        bottom: 12,
                      ),
                      child: FutureBuilder<LineChartData>(
                        future: dailyData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text(AppStrings.errorLoadingData));
                          } else {
                            return LineChart(snapshot.data!);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text(AppStrings.january, style: style);
        break;
      case 1:
        text = const Text(AppStrings.february, style: style);
        break;
      case 2:
        text = const Text(AppStrings.march, style: style);
        break;
      case 3:
        text = const Text(AppStrings.april, style: style);
        break;
      case 4:
        text = const Text(AppStrings.may, style: style);
        break;
      case 5:
        text = const Text(AppStrings.june, style: style);
        break;
      case 6:
        text = const Text(AppStrings.july, style: style);
        break;
      case 7:
        text = const Text(AppStrings.august, style: style);
        break;
      case 8:
        text = const Text(AppStrings.september, style: style);
        break;
      case 9:
        text = const Text(AppStrings.october, style: style);
        break;
      case 10:
        text = const Text(AppStrings.november, style: style);
        break;
      case 11:
        text = const Text(AppStrings.december, style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 10:
        text = AppStrings.ten;
        break;
      case 20:
        text = AppStrings.twenty;
        break;
      case 30:
        text = AppStrings.thirty;
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  Future<LineChartData> mainData() async {
    String year = DateTime.now().year.toString();
    double jan = (await database.getAppointmentCountByMonth('$year${AppStrings.year01}'));
    double feb = (await database.getAppointmentCountByMonth('$year${AppStrings.year02}'));
    double mar = (await database.getAppointmentCountByMonth('$year${AppStrings.year03}'));
    double apr = (await database.getAppointmentCountByMonth('$year${AppStrings.year04}'));
    double may = (await database.getAppointmentCountByMonth('$year${AppStrings.year05}'));
    double jun = (await database.getAppointmentCountByMonth('$year${AppStrings.year06}'));
    double jul = (await database.getAppointmentCountByMonth('$year${AppStrings.year07}'));
    double aug = (await database.getAppointmentCountByMonth('$year${AppStrings.year08}'));
    double sep = (await database.getAppointmentCountByMonth('$year${AppStrings.year09}'));
    double oct = (await database.getAppointmentCountByMonth('$year${AppStrings.year10}'));
    double nov = (await database.getAppointmentCountByMonth('$year${AppStrings.year11}'));
    double dec = (await database.getAppointmentCountByMonth('$year${AppStrings.year12}'));

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 30,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, jan),
            FlSpot(1, feb),
            FlSpot(2, mar),
            FlSpot(3, apr),
            FlSpot(4, may),
            FlSpot(5, jun),
            FlSpot(6, jul),
            FlSpot(7, aug),
            FlSpot(8, sep),
            FlSpot(9, oct),
            FlSpot(10, nov),
            FlSpot(11, dec),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<LineChartData> weeklyData() async {
    String yearMonth =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, AppStrings.zero)}";

// Week 1: From day 1 to day 7
    double week1 = (await database.getAppointmentCountByWeek(
        '$yearMonth${AppStrings.yearmonth01}', '$yearMonth${AppStrings.yearmonth07}'));

// Week 2: From day 8 to day 14
    double week2 = (await database.getAppointmentCountByWeek(
        '$yearMonth${AppStrings.yearmonth08}', '$yearMonth${AppStrings.yearmonth14}'));

// Week 3: From day 15 to day 21
    double week3 = (await database.getAppointmentCountByWeek(
        '$yearMonth${AppStrings.yearmonth15}', '$yearMonth${AppStrings.yearmonth21}'));

// Week 4: From day 22 to day 28
    double week4 = (await database.getAppointmentCountByWeek(
        '$yearMonth${AppStrings.yearmonth22}', '$yearMonth${AppStrings.yearmonth28}'));

// Week 5: From day 29 to the end of the month (adjust to handle months with different numbers of days)
    double week5 = (await database.getAppointmentCountByWeek(
        '$yearMonth${AppStrings.yearmonth29}', '$yearMonth${AppStrings.yearmonth31}'));

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text(AppStrings.week1, style: style);
                  break;
                case 1:
                  text = const Text(AppStrings.week2, style: style);
                  break;
                case 2:
                  text = const Text(AppStrings.week3, style: style);
                  break;
                case 3:
                  text = const Text(AppStrings.week4, style: style);
                  break;
                case 4:
                  text = const Text(AppStrings.week5, style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }

              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: text,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 4,
      minY: 0,
      maxY: 30,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, week1),
            FlSpot(1, week2),
            FlSpot(2, week3),
            FlSpot(3, week4),
            FlSpot(4, week5),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Future<LineChartData> dailyData() async {
    String yearMonthDay =
        "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
    double Sunday = (await database.getAppointmentCountByDay(yearMonthDay, 1));
    double Monday = (await database.getAppointmentCountByDay(yearMonthDay, 2));
    double Tuesday = (await database.getAppointmentCountByDay(yearMonthDay, 3));
    double Wednesday =
        (await database.getAppointmentCountByDay(yearMonthDay, 4));
    double Thursday =
        (await database.getAppointmentCountByDay(yearMonthDay, 5));
    double Friday = (await database.getAppointmentCountByDay(yearMonthDay, 6));
    double Saturday =
        (await database.getAppointmentCountByDay(yearMonthDay, 7));

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.black,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const style = TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = const Text(AppStrings.day1, style: style);
                  break;
                case 1:
                  text = const Text(AppStrings.day2, style: style);
                  break;
                case 2:
                  text = const Text(AppStrings.day3, style: style);
                  break;
                case 3:
                  text = const Text(AppStrings.day4, style: style);
                  break;
                case 4:
                  text = const Text(AppStrings.day5, style: style);
                  break;
                case 5:
                  text = const Text(AppStrings.day6, style: style);
                  break;
                case 6:
                  text = const Text(AppStrings.day7, style: style);
                  break;
                default:
                  text = const Text('', style: style);
                  break;
              }

              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: text,
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 30,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(0, Sunday),
            FlSpot(1, Monday),
            FlSpot(2, Tuesday),
            FlSpot(3, Wednesday),
            FlSpot(4, Thursday),
            FlSpot(5, Friday),
            FlSpot(6, Saturday),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
