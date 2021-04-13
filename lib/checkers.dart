import 'dart:convert';

import 'dart:io';

void playCheckers() {
  final checkerBoard = CheckerBoard();

  var done = false;

  var whitesTurn = true;

  var successfulMove = true;

  while (!done) {
    if (successfulMove) {
      print('...');
      checkerBoard.printBoard();
      print(whitesTurn ? 'White\'s turn!' : 'Black\'s turn!');
      successfulMove = false;
    }

    print('Select piece to move:');
    final pieceToMove = getInput();

    if ((whitesTurn &&
            checkerBoard.getPieceAtCoordinate(pieceToMove) ==
                CheckerPiece.white) ||
        (!whitesTurn &&
            checkerBoard.getPieceAtCoordinate(pieceToMove) ==
                CheckerPiece.black)) {
      // get valid moves...
      final availableMoves = checkerBoard.getValidMovesForPiece(pieceToMove);
      final captureMoves =
          checkerBoard.getValidCaptureMovesForPiece(pieceToMove);

      if (availableMoves.isNotEmpty || captureMoves.isNotEmpty) {
        print(
            'Choose where to: (Available moves are: ${availableMoves.join(', ')}' +
                (captureMoves.isNotEmpty
                    ? ', Capture moves are: ${captureMoves.join('*, ')})'
                    : ')'));
        final destination = getInput();

        if (availableMoves.contains(destination)) {
          checkerBoard.move(pieceToMove, destination, false);
          successfulMove = true;
          whitesTurn = !whitesTurn;
        } else if (captureMoves.contains(destination)) {
          checkerBoard.move(pieceToMove, destination, true);
          successfulMove = true;
        } else {
          print('! Please enter a valid move.');
        }
      } else {
        print('! This piece has no available moves.');
      }
    } else {
      print('! That\'s not a ${whitesTurn ? 'white' : 'black'} piece.');
    }
  }
}

String getInput() {
  print(
      '> Enter a coordinate by specifying a number and a letter. Like this: \'6A\'...');
  final line = stdin.readLineSync(encoding: Encoding.getByName('utf-8'));
  if (line.length != 2) {
    print('! Please enter two characters, a number and a letter.');
    return getInput();
  }

  final number = int.tryParse(line.substring(0, 1));

  if (number == null || number < 1 || number > 8) {
    print(
        '! Please make sure the first character is a number between 1 and 8 inclusive.');
    return getInput();
  }

  line.toLowerCase();

  final letter = line.substring(1, 2);

  if (letter.compareTo('a').isNegative || letter.compareTo('h') > 0) {
    print(
        '! Please make sure the second character is a letter between A and H inclusive.');
    return getInput();
  }

  return line;
}

enum CheckerPiece { blank, white, black }

String getPrintRepresentation(CheckerPiece piece) {
  switch (piece) {
    case CheckerPiece.blank:
      return '-';
    case CheckerPiece.white:
      return 'W';
    case CheckerPiece.black:
      return 'B';
    default:
      return '?';
  }
}

class CheckerBoard {
  static const numbers = ['1', '2', '3', '4', '5', '6', '7', '8']; // row
  static const letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']; // col

  /// an array of rows, top to bottom
  List<List<CheckerPiece>> checkerBoard = [];

  CheckerBoard() {
    blankCheckerBoard();
  }

  bool coordinateIsAPiece(String coordinate) =>
      getPieceAtCoordinate(coordinate) != CheckerPiece.blank;

  CheckerPiece getPieceAtCoordinate(String coordinate) =>
      checkerBoard[getRow(coordinate)][getCol(coordinate)];

  int getRow(String coordinate) => int.tryParse(coordinate.substring(0, 1)) - 1;

  int getCol(String coordinate) => letters.indexOf(coordinate.substring(1, 2));

  /// assume the move is valid
  void move(String from, String to, bool isCaptureMove) {
    final typeOfPiece = getPieceAtCoordinate(from);

    // clear old spot
    checkerBoard[getRow(from)][getCol(from)] = CheckerPiece.blank;

    // place in new spot
    checkerBoard[getRow(to)][getCol(to)] = typeOfPiece;

    // if it's a capture move, also clear the middle spot
    if (isCaptureMove) {
      checkerBoard[(getRow(to) + getRow(from)) ~/ 2]
          [(getCol(to) + getCol(from)) ~/ 2] = CheckerPiece.blank;
    }
  }

  List<String> getValidCaptureMovesForPiece(String coordinate) {
    final captureMoves = <String>[];

    if (!coordinateIsAPiece(coordinate)) {
      return captureMoves;
    }

    final row = getRow(coordinate);
    final col = getCol(coordinate);

    final pieceType = getPieceAtCoordinate(coordinate);
    CheckerPiece pieceTypeToCapture;

    if (pieceType == CheckerPiece.white) {
      pieceTypeToCapture = CheckerPiece.black;
    } else if (pieceType == CheckerPiece.black) {
      pieceTypeToCapture = CheckerPiece.white;
    } else {
      return captureMoves;
    }

    if (pieceType == CheckerPiece.white && row <= 6) {
      // white, pieces move down

      // leftward moves
      if (col > 1) {
        if (checkerBoard[row + 1][col - 1] == pieceTypeToCapture &&
            checkerBoard[row + 2][col - 2] == CheckerPiece.blank) {
          captureMoves.add('${numbers[row + 2]}${letters[col - 2]}');
        }
      }

      // rightward moves
      if (col < 6) {
        if (checkerBoard[row + 1][col + 1] == pieceTypeToCapture &&
            checkerBoard[row + 2][col + 2] == CheckerPiece.blank) {
          captureMoves.add('${numbers[row + 2]}${letters[col + 2]}');
        }
      }
    } else if (pieceType == CheckerPiece.black && row >= 1) {
      // black, pieces move up

      // leftward moves
      if (col > 1) {
        if (checkerBoard[row - 1][col - 1] == pieceTypeToCapture &&
            checkerBoard[row - 2][col - 2] == CheckerPiece.blank) {
          captureMoves.add('${numbers[row - 2]}${letters[col - 2]}');
        }
      }

      // rightward moves
      if (col < 6) {
        if (checkerBoard[row - 1][col + 1] == pieceTypeToCapture &&
            checkerBoard[row - 2][col + 2] == CheckerPiece.blank) {
          captureMoves.add('${numbers[row - 2]}${letters[col + 2]}');
        }
      }
    } else {
      // ?? kings probably
    }

    return captureMoves;
  }

  List<String> getValidMovesForPiece(String coordinate) {
    final validMoves = <String>[];

    if (!coordinateIsAPiece(coordinate)) {
      return validMoves;
    }

    final row = getRow(coordinate);
    final col = getCol(coordinate);

    final pieceType = getPieceAtCoordinate(coordinate);

    if (pieceType == CheckerPiece.white && row <= 7) {
      // white, pieces move down

      // leftward moves
      if (col > 0) {
        if (checkerBoard[row + 1][col - 1] == CheckerPiece.blank) {
          validMoves.add('${numbers[row + 1]}${letters[col - 1]}');
        }
      }

      // rightward moves
      if (col < 7) {
        if (checkerBoard[row + 1][col + 1] == CheckerPiece.blank) {
          validMoves.add('${numbers[row + 1]}${letters[col + 1]}');
        }
      }
    } else if (pieceType == CheckerPiece.black && row >= 0) {
      // black, pieces move up

      // leftward moves
      if (col > 0) {
        if (checkerBoard[row - 1][col - 1] == CheckerPiece.blank) {
          validMoves.add('${numbers[row - 1]}${letters[col - 1]}');
        }
      }

      // rightward moves
      if (col < 7) {
        if (checkerBoard[row - 1][col + 1] == CheckerPiece.blank) {
          validMoves.add('${numbers[row - 1]}${letters[col + 1]}');
        }
      }
    } else {
      // ?? kings probably
    }

    return validMoves;
  }

  void printBoard() {
    print('    ${letters.join(' ')}');
    for (var r = 0; r < 8; r++) {
      final rowString = checkerBoard[r]
          .map((piece) => getPrintRepresentation(piece))
          .join(' ');
      print('${numbers[r]} | $rowString |');
    }
  }

  void blankCheckerBoard() {
    checkerBoard.clear();

    for (var rowCount = 0; rowCount < 8; rowCount++) {
      final row = <CheckerPiece>[];
      for (var col = 0; col < 8; col++) {
        if (rowCount < 3) {
          // top three rows
          if ((rowCount + col).isOdd) {
            row.add(CheckerPiece.white);
          } else {
            row.add(CheckerPiece.blank);
          }
        } else if (rowCount >= 3 && rowCount < 5) {
          // middle blank bit
          row.add(CheckerPiece.blank);
        } else {
          // last three rows
          if ((rowCount + col).isOdd) {
            row.add(CheckerPiece.black);
          } else {
            row.add(CheckerPiece.blank);
          }
        }
      }

      checkerBoard.add(row);
    }
  }
}
