// This file is part of Sanmill.
// Copyright (C) 2019-2022 The Sanmill developers (see AUTHORS file)
//
// Sanmill is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Sanmill is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

part of '../mill.dart';

/// Mill Controller
///
/// A singleton class that holds all objects and methods needed to play Mill.
///
/// Controls:
/// * The tip [HeaderTipNotifier]
/// * The engine [Engine]
/// * The position [Position]
/// * The game instance [Game]
/// * The recorder [GameRecorder]
class MillController {
  static const _tag = "[Controller]";

  bool disposed = false;
  bool isReady = false;
  bool isActive = false;
  bool isEngineGoing = false;

  late Game gameInstance;
  late Position position;
  late Engine engine;

  final HeaderTipNotifier headerTipNotifier = HeaderTipNotifier();
  final HeaderIconsNotifier headerIconsNotifier = HeaderIconsNotifier();
  final BoardSemanticsNotifier boardSemanticsNotifier =
      BoardSemanticsNotifier();

  late GameRecorder recorder;
  GameRecorder? newRecorder;

  late AnimationController animationController;
  late Animation<double> animation;

  bool _initialized = false;
  bool get initialized => _initialized;

  @visibleForTesting
  static MillController instance = MillController._();

  factory MillController() => instance;

  /// Mill Controller
  ///
  /// A singleton class that holds all objects and methods needed to play Mill.
  ///
  /// Controls:
  /// * The tip [HeaderTipNotifier]
  /// * The engine [Engine]
  /// * The position [Position]
  /// * The game instance [Game]
  /// * The recorder [GameRecorder]
  ///
  /// All listed objects should not be crated outside of this scope.
  MillController._() {
    _init();
  }

  /// Starts up the controller. It will initialize the audio subsystem and heat the engine.
  Future<void> start() async {
    if (_initialized) return;

    await Audios().loadSounds();

    _initialized = true;
    logger.i("$_tag initialized");
  }

  /// Resets the controller.
  ///
  /// This method is suitable to use for starting a new game.
  void reset() {
    final gameModeBak = gameInstance.gameMode;

    MillController().engine.stopSearching();
    _init();

    gameInstance.gameMode = gameModeBak;
  }

  /// Starts the current game.
  ///
  /// This method is suitable to use for starting a new game.
  void _startGame() {
    // TODO: [Leptopoda] Reimplement this and clean onBoardTap()
  }

  /// Initializes the controller.
  void _init() {
    position = Position();
    gameInstance = Game();
    engine = Engine();
    recorder = GameRecorder(lastPositionWithRemove: position._fen);

    _startGame();
  }

  // TODO: [Leptopoda] The reference of this method has been removed in a few instances.
  // We'll need to find a better way for this.
  Future<EngineResponse> engineToGo(BuildContext context,
      {required bool isMoveNow}) async {
    const tag = "[engineToGo]";

    bool searched = false;
    bool loopIsFirst = true;

    final aiStr = S.of(context).ai;
    final thinkingStr = S.of(context).thinking;
    final humanStr = S.of(context).human;

    final controller = MillController();
    final gameMode = MillController().gameInstance.gameMode;
    bool isGameRunning = position.winner == PieceColor.nobody;

    if (isMoveNow == true) {
      if (MillController().gameInstance.isHumanToMove) {
        return const EngineResponseSkip();
      }

      if (!MillController().recorder.isClean) {
        return const EngineResponseSkip();
      }
    }

    if (MillController().isEngineGoing == true) {
      // TODO: No triggering scene found
      logger.v("$tag engineToGo() is still running, skip.");
      return const EngineResponseSkip();
    } else {
      MillController().isEngineGoing == true;
    }

    MillController().isActive = true;

    // TODO
    logger.v("$tag engine type is $gameMode");

    while ((gameInstance.isAiToMove &&
            (isGameRunning || DB().generalSettings.isAutoRestart)) &&
        MillController().isActive) {
      if (gameMode == GameMode.aiVsAi) {
        MillController()
            .headerTipNotifier
            .showTip(MillController().position.scoreString);
      } else {
        MillController().headerTipNotifier.showTip(thinkingStr);

        showSnakeBarHumanNotation(humanStr);
      }

      MillController().headerIconsNotifier.showIcons();
      MillController().boardSemanticsNotifier.updateSemantics();

      try {
        logger.v("$tag Searching..., isMoveNow: $isMoveNow");

        final extMove = await controller.engine
            .search(moveNow: loopIsFirst ? isMoveNow : false);

        if (MillController().isActive == false) break;

        controller.gameInstance.doMove(extMove);

        loopIsFirst = false;
        searched = true;

        if (MillController().disposed == false) {
          MillController().animationController.reset();
          MillController().animationController.animateTo(1.0);
        }

        // TODO: Do not use BuildContexts across async gaps.
        if (DB().generalSettings.screenReaderSupport) {
          rootScaffoldMessengerKey.currentState!.showSnackBar(
            CustomSnackBar("$aiStr: ${extMove.notation}"),
          );
        }
      } on EngineTimeOut {
        logger.i("$tag Engine response type: timeout");
        MillController().isEngineGoing = false;
        return const EngineTimeOut();
      } on EngineNoBestMove {
        logger.i("$tag Engine response type: nobestmove");
        MillController().isEngineGoing = false;
        return const EngineNoBestMove();
      }

      if (MillController().position.winner != PieceColor.nobody) {
        if (DB().generalSettings.isAutoRestart == true) {
          MillController().reset();
        } else {
          MillController().isEngineGoing = false;
          if (MillController().gameInstance.gameMode == GameMode.aiVsAi) {
            MillController()
                .headerTipNotifier
                .showTip(MillController().position.scoreString);
            MillController().headerIconsNotifier.showIcons();
            MillController().boardSemanticsNotifier.updateSemantics();
          }
          return const EngineResponseOK();
        }
      }
    }

    MillController().isEngineGoing = false;

    // TODO: Why need not update tip and icons?
    MillController().boardSemanticsNotifier.updateSemantics();

    return searched ? const EngineResponseOK() : const EngineResponseHumanOK();
  }

  showSnakeBarHumanNotation(String humanStr) {
    final String? n = recorder.lastF?.notation;

    if (DB().generalSettings.screenReaderSupport &&
        MillController().position._action != Act.remove &&
        n != null) {
      rootScaffoldMessengerKey.currentState!
          .showSnackBar(CustomSnackBar("$humanStr: $n"));
    }
  }

  /// Starts a game save.
  static Future<void> save(BuildContext context) async =>
      LoadService.saveGame(context);

  /// Starts a game load.
  static Future<void> load(BuildContext context) async =>
      LoadService.loadGame(context);

  /// Starts a game import.
  static Future<void> import(BuildContext context) async =>
      ImportService.importGame(context);

  /// Starts a game export.
  static Future<void> export(BuildContext context) async =>
      ImportService.exportGame(context);
}