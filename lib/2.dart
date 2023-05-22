
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class NoiseApp extends StatefulWidget {
  @override
  _NoiseAppState createState() => _NoiseAppState();
}

class _NoiseAppState extends State<NoiseApp> {
  bool _isRecording = false;
  // ignore: cancel_subscriptions
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  bool redFlag=false;
  double avr=0.0;
  double p=0.0;
  int counter=0;
  double? maxDB;
  double? meanDB;
  List<_ChartData> chartData = <_ChartData>[];
  // ChartSeriesController? _chartSeriesController;
  late int previousMillis;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);

  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (!this._isRecording) this._isRecording = true;
    });
    maxDB = noiseReading.maxDecibel;
    meanDB = noiseReading.meanDecibel;

    chartData.add(
      _ChartData(
        maxDB,
        meanDB,
        ((DateTime.now().millisecondsSinceEpoch - previousMillis) / 1000)
            .toDouble(),
      ),
    );
      Avr(maxDB!);

  }
  void Avr(double max)
  {
    p+=max;
    counter+=1;
    print(p);
    print(counter);

  }

  void onError(Object e) {
    print(e.toString());
    _isRecording = false;
  }

  void start() async {
    timer = Timer.periodic(Duration(seconds: 10), (Timer t){
      if((p/counter)>70)
      {
        redFlag=true;
        print('counter:$counter');
      }
      p=0.0;
      avr=0.0;
      counter=0;
    });
    previousMillis = DateTime.now().millisecondsSinceEpoch;
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (e) {
      print(e);
    }
  }

  void stop() async {
    timer?.cancel();
    try {
      _noiseSubscription!.cancel();
      _noiseSubscription = null;

      this.setState(() => this._isRecording = false);
    } catch (e) {
      print('stopRecorder error: $e');
    }
    previousMillis = 0;
    chartData.clear();
  }

  @override
  Widget build(BuildContext context) {
    bool _isDark = Theme.of(context).brightness == Brightness.light;
    if (chartData.length >= 25) {
      chartData.removeAt(0);
    }
    return Scaffold(

      appBar: AppBar(
        backgroundColor: _isDark ? Colors.green : Colors.green.shade800,
        title: Text('Noise Level'),
        centerTitle: true,
        actions: [

        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text(_isRecording ? 'Stop' : 'Start'),
        onPressed: _isRecording ? stop : start,
        icon: !_isRecording ? Icon(Icons.play_arrow_rounded) : null,
        backgroundColor: _isRecording ? Colors.red : Colors.green,
      ),
      body: Container(
        child: Column(
          children: [
            Visibility(
              visible: redFlag,
                child: Icon(Icons.flag,color: Colors.red,size: 35,)),
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  maxDB != null ? maxDB!.toStringAsFixed(2) : 'Press start',
                ),
              ),
            ),
            Text(
              meanDB != null
                  ? 'Mean: ${meanDB!.toStringAsFixed(2)}'
                  : 'Awaiting data',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
            ),
            Expanded(
              child: SfCartesianChart(

                series: <LineSeries<_ChartData, double>>[
                  LineSeries<_ChartData, double>(
                      dataSource: chartData,
                      xAxisName: 'Time',
                      yAxisName: 'dB',
                      name: 'dB values over time',
                      xValueMapper: (_ChartData value, _) => value.frames,
                      yValueMapper: (_ChartData value, _) => value.maxDB,
                      animationDuration: 0),
                ],
              ),
            ),
            SizedBox(
              height: 68,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final double? maxDB;
  final double? meanDB;
  final double frames;

  _ChartData(this.maxDB, this.meanDB, this.frames);
}