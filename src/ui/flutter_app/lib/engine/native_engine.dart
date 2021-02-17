/*
  This file is part of Sanmill.
  Copyright (C) 2019-2021 The Sanmill developers (see AUTHORS file)

  Sanmill is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Sanmill is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import 'package:flutter/services.dart';
import 'package:sanmill/common/config.dart';
import 'package:sanmill/mill/mill.dart';
import 'package:sanmill/mill/position.dart';

import 'engine.dart';

class NativeEngine extends AiEngine {
  static const platform = const MethodChannel('com.calcitem.sanmill/engine');

  Future<void> startup() async {
    await platform.invokeMethod('startup');
    await waitResponse(['uciok'], sleep: 1, times: 30);
  }

  Future<void> send(String command) async {
    print("send: $command");
    await platform.invokeMethod('send', command);
  }

  Future<String> read() async {
    return await platform.invokeMethod('read');
  }

  Future<void> shutdown() async {
    await platform.invokeMethod('shutdown');
  }

  Future<bool> isReady() async {
    return await platform.invokeMethod('isReady');
  }

  Future<bool> isThinking() async {
    return await platform.invokeMethod('isThinking');
  }

  @override
  Future<EngineResponse> search(Position position, {bool byUser = true}) async {
    if (await isThinking()) await stopSearching();

    send(getPositionFen(position));
    send('go');

    final response = await waitResponse(['bestmove', 'nobestmove']);

    print("response: $response");

    if (response.startsWith('bestmove')) {
      var best = response.substring('bestmove'.length + 1);

      final pos = best.indexOf(' ');
      if (pos > -1) best = best.substring(0, pos);

      return EngineResponse('move', value: Move.set(best));
    }

    if (response.startsWith('nobestmove')) {
      return EngineResponse('nobestmove');
    }

    return EngineResponse('timeout');
  }

  Future<String> waitResponse(List<String> prefixes,
      {sleep = 100, times = 100}) async {
    if (times <= 0) return '';

    final response = await read();

    if (response != null) {
      for (var prefix in prefixes) {
        if (response.startsWith(prefix)) return response;
      }
    }

    return Future<String>.delayed(
      Duration(milliseconds: sleep),
      () => waitResponse(prefixes, times: times - 1),
    );
  }

  Future<void> stopSearching() async {
    await send('stop');
  }

  Future<void> setOptions() async {
    await send('setoption name SkillLevel value ${Config.skillLevel}');
    await send('setoption name Shuffling value ${Config.shufflingEnabled}');
    await send('setoption name piecesCount value ${Config.piecesCount}');
    await send(
        'setoption name piecesAtLeastCount value ${Config.piecesAtLeastCount}');
    await send(
        'setoption name hasObliqueLines value ${Config.hasObliqueLines}');
    await send(
        'setoption name hasBannedLocations value ${Config.hasBannedLocations}');
    await send(
        'setoption name isDefenderMoveFirst value ${Config.isDefenderMoveFirst}');
    await send(
        'setoption name mayRemoveMultiple value ${Config.mayRemoveMultiple}');
    await send(
        'setoption name mayRemoveFromMillsAlways value ${Config.mayRemoveFromMillsAlways}');
    await send(
        'setoption name isBlackLoseButNotDrawWhenBoardFull value ${Config.isBlackLoseButNotDrawWhenBoardFull}');
    await send(
        'setoption name isLoseButNotChangeSideWhenNoWay value ${Config.isLoseButNotChangeSideWhenNoWay}');
    await send('setoption name mayFly value ${Config.mayFly}');
    await send(
        'setoption name maxStepsLedToDraw value ${Config.maxStepsLedToDraw}');
  }

  String getPositionFen(Position position) {
    final startPosition = position.lastPositionWithRemove;
    final moves = position.movesSinceLastRemove();

    String posFenStr;

    if (moves.isEmpty) {
      posFenStr = "position fen $startPosition";
    } else {
      posFenStr = "position fen $startPosition moves $moves";
    }

    print("posFenStr: $posFenStr");

    return posFenStr;
  }
}