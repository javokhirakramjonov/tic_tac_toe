import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  Player? _currentPlayer;
  final List<Player?> _board = List.filled(9, null);
  Player? winner;
  WinType? _winType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _buildInitialPlayerSelectorDialog(context);
    });
  }

  void _buildInitialPlayerSelectorDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Player'),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                spacing: 24,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPlayer = Player.X;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text('X'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentPlayer = Player.O;
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text('O'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentPlayer?.name ?? 'Select Player',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 48),
                _buildBoard(),
                const SizedBox(height: 48),
                _buildRetryButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() {
    return Stack(children: [_buildGameBoard(), _buildWinBoard()]);
  }

  Widget _buildGameBoard() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _board.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder:
          (context, index) => _buildCell(
            player: _board[index],
            onTap: () {
              setState(() {
                _board[index] = _currentPlayer;

                _currentPlayer =
                    _currentPlayer == Player.X ? Player.O : Player.X;
              });

              _checkWinner();
            },
          ),
    );
  }

  Widget _buildWinBoard() {
    if (_winType == null) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _board.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final int x = index ~/ 3;
        final int y = index % 3;

        final child = switch (_winType!) {
          WinType.row1 =>
            x != 0
                ? null
                : Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.black,
                ),
          WinType.row2 =>
            x != 1
                ? null
                : Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.black,
                ),
          WinType.row3 =>
            x != 2
                ? null
                : Container(
                  height: 8,
                  width: double.infinity,
                  color: Colors.black,
                ),
          WinType.column1 =>
            y != 0
                ? null
                : Container(
                  width: 8,
                  height: double.infinity,
                  color: Colors.black,
                ),
          WinType.column2 =>
            y != 1
                ? null
                : Container(
                  width: 8,
                  height: double.infinity,
                  color: Colors.black,
                ),
          WinType.column3 =>
            y != 2
                ? null
                : Container(
                  width: 8,
                  height: double.infinity,
                  color: Colors.black,
                ),
          WinType.diagonal1 =>
            x != y
                ? null
                : Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: double.infinity,
                    height: 8,
                    color: Colors.black,
                  ),
                ),
          WinType.diagonal2 =>
            x + y != 2
                ? null
                : Transform.rotate(
                  angle: -pi / 4,
                  child: Container(
                    width: double.infinity,
                    height: 8,
                    color: Colors.black,
                  ),
                ),
        };

        return Center(key: Key("winnerBoard$index"), child: child);
      },
    );
  }

  Widget _buildCell({Player? player, required VoidCallback onTap}) {
    return Material(
      color: switch (player) {
        Player.X => Colors.blue,
        Player.O => Colors.red,
        null => Colors.white,
      },
      child: InkWell(
        onTap: player == null && winner == null ? onTap : null,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFFe3e3e3)),
          ),
          child:
              player == null
                  ? null
                  : Center(
                    child: Text(
                      player.name,
                      style: const TextStyle(fontSize: 64, color: Colors.white),
                    ),
                  ),
        ),
      ),
    );
  }

  void _checkWinner() {
    final firstRow = _board.sublist(0, 3);
    if (_checkAllEqual(firstRow)) {
      _showWinnerDialog(firstRow.first!);
      setState(() {
        _winType = WinType.row1;
      });
      return;
    }

    final secondRow = _board.sublist(3, 6);
    if (_checkAllEqual(secondRow)) {
      _showWinnerDialog(secondRow.first!);
      setState(() {
        _winType = WinType.row2;
      });
      return;
    }

    final thirdRow = _board.sublist(6, 9);
    if (_checkAllEqual(thirdRow)) {
      _showWinnerDialog(thirdRow.first!);
      setState(() {
        _winType = WinType.row3;
      });
      return;
    }

    final firstColumn = [_board[0], _board[3], _board[6]];
    if (_checkAllEqual(firstColumn)) {
      _showWinnerDialog(firstColumn.first!);
      setState(() {
        _winType = WinType.column1;
      });
      return;
    }

    final secondColumn = [_board[1], _board[4], _board[7]];
    if (_checkAllEqual(secondColumn)) {
      _showWinnerDialog(secondColumn.first!);
      setState(() {
        _winType = WinType.column2;
      });
      return;
    }

    final thirdColumn = [_board[2], _board[5], _board[8]];
    if (_checkAllEqual(thirdColumn)) {
      _showWinnerDialog(thirdColumn.first!);
      setState(() {
        _winType = WinType.column3;
      });
      return;
    }

    final diagonal1 = [_board[0], _board[4], _board[8]];
    if (_checkAllEqual(diagonal1)) {
      _showWinnerDialog(diagonal1.first!);
      setState(() {
        _winType = WinType.diagonal1;
      });
      return;
    }

    final diagonal2 = [_board[2], _board[4], _board[6]];
    if (_checkAllEqual(diagonal2)) {
      _showWinnerDialog(diagonal2.first!);
      setState(() {
        _winType = WinType.diagonal2;
      });
      return;
    }
  }

  Widget _buildRetryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _board.fillRange(0, _board.length, null);
          winner = null;
          _currentPlayer = null;
          _winType = null;
        });

        _buildInitialPlayerSelectorDialog(context);
      },
      child: const Text('Retry'),
    );
  }

  bool _checkAllEqual(List<Player?> list) {
    return list.every((element) => element != null && element == list.first);
  }

  void _showWinnerDialog(Player player) {
    setState(() {
      winner = player;
    });

    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('${player.name} wins!'),
          children: [
            Lottie.asset(
              height: 100,
              width: 100,
              'assets/animations/congratulations.json',
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _board.fillRange(0, _board.length, null);
                      winner = null;
                      _currentPlayer = null;
                      _winType = null;
                    });

                    Navigator.of(context).pop();

                    _buildInitialPlayerSelectorDialog(context);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

enum Player { X, O }

enum WinType {
  row1,
  row2,
  row3,
  column1,
  column2,
  column3,
  diagonal1,
  diagonal2,
}
