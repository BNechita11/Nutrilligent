import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeMeter extends StatelessWidget {
  final double calorieBudget;
  final double caloriesConsumed;

  const GaugeMeter({
    super.key,
    required this.calorieBudget,
    required this.caloriesConsumed,
  });

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: calorieBudget,
          ranges: <GaugeRange>[
            GaugeRange(
              startValue: 0,
              endValue: calorieBudget * 0.5,
              color: Colors.green,
            ),
            GaugeRange(
              startValue: calorieBudget * 0.5,
              endValue: calorieBudget * 0.8,
              color: Colors.orange,
            ),
            GaugeRange(
              startValue: calorieBudget * 0.8,
              endValue: calorieBudget,
              color: Colors.red,
            ),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
              value: caloriesConsumed,
              enableAnimation: true,
              needleColor: Colors.white,
              knobStyle: KnobStyle(color: Colors.purple),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${caloriesConsumed.toStringAsFixed(0)} cal",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    "Consumed",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],
        ),
      ],
    );
  }
}
