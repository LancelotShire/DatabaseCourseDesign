import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'main.dart';
import 'dart:convert';

Future<Map<String, dynamic>?> getCategoryCounts() async {
  var res = await http.get(Uri.parse('$URL/getCategoryCounts'));

  if (res.statusCode == 200) {
    var body = json.decode(utf8.decode(res.body.runes.toList()));
    return body;
  } else {
    return null;
  }
}

Future<List?> getMostPopular() async {
  var res = await http.get(Uri.parse('$URL/getMostPopular'));

  if (res.statusCode == 200) {
    var body = json.decode(utf8.decode(res.body.runes.toList()));
    return body;
  } else {
    return null;
  }
}

Future<List?> getMostPopularCategory() async {
  var res = await http.get(Uri.parse('$URL/getMostPopularCategory'));

  if (res.statusCode == 200) {
    var body = json.decode(utf8.decode(res.body.runes.toList()));
    return body;
  } else {
    return null;
  }
}

Future<List?> getBookCount() async {
  var res = await http.get(Uri.parse('$URL/getBookCount'));

  if (res.statusCode == 200) {
    var body = json.decode(utf8.decode(res.body.runes.toList()));
    return body;
  } else {
    return null;
  }
}

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  List<Color> generatePieChartColors(int numberOfColors) {
    List<Color> colors = [];

    // 生成配色方案
    for (int i = 0; i < numberOfColors; i++) {
      colors.add(generateColor(i, numberOfColors));
    }

    return colors;
  }

  Color generateColor(int index, int numberOfColors) {
    double hue = (360.0 / numberOfColors) * index;
    return HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder(
              future: getCategoryCounts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Color> colors = generatePieChartColors(50);
                  List<PieChartSectionData> sections = [];
                  int count = 0;
                  snapshot.data?.forEach((key, value) {
                    var title = "$key\n$value";
                    sections.add(
                      PieChartSectionData(
                          value: value.toDouble(),
                          title: title,
                          color: colors[count],
                          titleStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontFamily: 'CustomFont',
                              fontWeight: FontWeight.bold)),
                    );
                    count++;
                  });
                  return Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            width: 500,
                            height: 500,
                            child: PieChart(PieChartData(sections: sections)),
                          ),
                        ),
                        const Text(
                          "库存各种类型的书籍种类数量占比",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          FutureBuilder(
              future: getBookCount(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Color> colors = generatePieChartColors(50);
                  List<PieChartSectionData> sections = [];
                  int count = 0;
                  for (int i = 0; i < snapshot.data!.length; i++) {
                    int value = snapshot.data![i][1];
                    var title = "${snapshot.data![i][0]}\n$value";
                    sections.add(PieChartSectionData(
                        value: value.toDouble(),
                        title: title,
                        color: colors[count],
                        titleStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'CustomFont',
                            fontWeight: FontWeight.bold)));
                    count++;
                  }
                  return Center(
                      child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: 500,
                          height: 500,
                          child: PieChart(PieChartData(sections: sections)),
                        ),
                      ),
                      const Text(
                        "库存的所有书籍各类型数量占比",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          FutureBuilder(
              future: getMostPopularCategory(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Color> colors = generatePieChartColors(50);
                  List<PieChartSectionData> sections = [];
                  int count = 0;
                  for (int i = 0; i < snapshot.data!.length; i++) {
                    int value = snapshot.data![i][1];
                    var title = "${snapshot.data![i][0]}\n$value";
                    sections.add(PieChartSectionData(
                        value: value.toDouble(),
                        title: title,
                        color: colors[count],
                        titleStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'CustomFont',
                            fontWeight: FontWeight.bold)));
                    count++;
                  }
                  return Center(
                      child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SizedBox(
                          width: 500,
                          height: 500,
                          child: PieChart(PieChartData(sections: sections)),
                        ),
                      ),
                      const Text(
                        "被借阅书籍中各类型的占比",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ));
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
          FutureBuilder(
              future: getMostPopular(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<BarChartGroupData> list = [];
                  List<String> labels = [];
                  int count = 0;
                  for (int i = 0; i < min(snapshot.data!.length, 7); i++) {
                    list.add(BarChartGroupData(
                      x: count,
                      barRods: [
                        BarChartRodData(
                            y: snapshot.data![i][1].toDouble(), width: 20)
                      ],
                    ));
                    labels.add(snapshot.data![i][0]);
                    count++;
                  }
                  return Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(50),
                          child: SizedBox(
                              width: 500,
                              height: 500,
                              child: BarChart(BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: ((snapshot.data![0][1] ~/ 10 + 1) * 10)
                                    .toDouble(),
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: SideTitles(
                                    showTitles: true,
                                    margin: 20,
                                    rotateAngle: 45,
                                    getTitles: (double value) {
                                      // 返回横轴标签
                                      return labels[value.toInt()];
                                    },
                                    getTextStyles: (value) => const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: "CustomFont"),
                                  ),
                                  leftTitles: SideTitles(
                                    showTitles: true,
                                    getTextStyles: (value) =>
                                        const TextStyle(color: Colors.black),
                                    margin: 10,
                                    reservedSize: 30,
                                    interval: (snapshot.data![0][1] ~/ 10 + 1)
                                        .toDouble(),
                                  ),
                                ),
                                borderData: FlBorderData(show: true),
                                barGroups: list,
                              ))),
                        ),
                        const Text(
                          "借阅量前七的书籍",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("错误！请重试！"),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text("统计数据"),
        ),
        body: _buildBody());
  }
}
