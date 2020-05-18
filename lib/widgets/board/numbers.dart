import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudoku/presentation/sudoku_bloc/bloc.dart';
import 'package:sudoku/theme.dart';
import 'package:provider/provider.dart';

class SudokuNumbers extends StatelessWidget {
  final List<NumberInfo> state;
  final bool isPortrait;

  const SudokuNumbers({Key key, this.state, this.isPortrait}) : super(key: key);

  Widget renderNumber(NumberInfo info, BuildContext context) {
    void onTap() {
      context.bloc<SudokuBloc>().add(NumberTap(info.number));
    }
    final decoration = BoxDecoration(color: info.isSelected ? Provider.of<SudokuTheme>(context).secondary : null, shape: BoxShape.circle, border: Border.all(color: Provider.of<SudokuTheme>(context).mainDarkened));
    var textStyle = Theme.of(context).textTheme.headline4;
    if (info.isSelected) {
      textStyle =  textStyle.copyWith(color: Theme.of(context).colorScheme.onSecondary);
    }
    final textOrIcon = info.number == 0 || info.number == null ? Padding(padding: EdgeInsets.all(2.5),child: Icon(Icons.clear, color: textStyle.color,)) : Text(info.number.toString(), style: textStyle,);
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Ink(
          decoration: decoration,
          child: InkWell(
            onTap: onTap,
            customBorder: CircleBorder(),
            child: FractionallySizedBox(
              widthFactor: 0.75,
              heightFactor: 0.75,
                          child: FittedBox(
                fit: BoxFit.contain,
                  child: textOrIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static double buttonSize = 52;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final crossAxis = isPortrait ? constraints.maxWidth : constraints.maxHeight;
      final mainAxisMax = isPortrait ? constraints.maxHeight : constraints.maxWidth;
      final numbersPerCrossAxis = max(crossAxis ~/ buttonSize, state.length ~/ 3);
      final crossAxisCount = (state.length / numbersPerCrossAxis).ceil();
      final mainAxisCount = (state.length / crossAxisCount).ceil();

      final zeroAtEnd = state.toList()..sort((a,b) => a.number == 0 ? 1 : 0);
      final toBeFitted = List<List<NumberInfo>>.generate(crossAxisCount, (_) => <NumberInfo>[]);
      for (var i = 0; i < state.length; i++) {
        final toBeFittedI = i == state.length - 1 ? toBeFitted.length -1 : i ~/ mainAxisCount;
        toBeFitted[toBeFittedI].add(zeroAtEnd[i]);
      }
      final children = toBeFitted.where((e) => e.isNotEmpty).map((list) {
        final children = list.map((e) => Expanded(child: renderNumber(e, context))).toList();
        if (!isPortrait) {
          return ConstrainedBox(constraints: BoxConstraints(maxWidth: mainAxisMax / crossAxisCount), child: Column(children: children));
        }
        return ConstrainedBox(constraints: BoxConstraints(maxHeight: mainAxisMax / crossAxisCount), child: Row(children: children));
      }).toList();

        if (!isPortrait) {
          return Row(mainAxisSize: MainAxisSize.min, children: children);
        }
        return Column(mainAxisSize: MainAxisSize.min, children: children);
    });
  }
}