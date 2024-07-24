


class Graphpoint {
  final double min;
  final int max;
  final int median;
  final int hour;


  Graphpoint(this.min, this.max, this.median, this.hour);
}

List<Graphpoint> dummyData = [
  Graphpoint(29, 92, 53, 0),
  Graphpoint(20, 90, 50, 1),
  Graphpoint(25, 85, 55, 2),
  Graphpoint(15, 75, 40, 3),
  Graphpoint(30, 90, 35, 4),
  Graphpoint(10, 60, 15, 5),
  Graphpoint(5, 95, 10, 6),
  Graphpoint(20, 40, 25, 7),
  Graphpoint(15, 25, 20, 8),
  Graphpoint(35, 45, 40, 9),
  Graphpoint(25, 35, 30, 10),
  Graphpoint(40, 50, 45, 11),
  Graphpoint(45, 55, 50, 12),
  Graphpoint(30, 40, 35, 13),
  Graphpoint(20, 130, 25, 14),
  Graphpoint(10, 20, 15, 15),
  Graphpoint(5, 15, 10, 16),
  Graphpoint(25, 35, 30, 17),
  Graphpoint(15, 25, 20, 18),
  Graphpoint(35, 45, 40, 19),
  Graphpoint(40, 50, 45, 20),
  Graphpoint(30, 40, 35, 21),
  // Graphpoint(20, 30, 25, 22),
  // Graphpoint(10, 20, 15, 23),
  Graphpoint(5, 15, 10, 24),
  // Graphpoint(25, 35, 30, 25),
  // Graphpoint(15, 25, 20, 26),
  Graphpoint(35, 45, 40, 27),
  Graphpoint(40, 50, 45, 28),
  Graphpoint(30, 40, 35, 29),
  Graphpoint(20, 30, 25, 30),
  Graphpoint(10, 20, 15, 31),
  Graphpoint(5, 15, 10, 32),
  Graphpoint(25, 35, 30, 33),
  Graphpoint(15, 25, 20, 34),
  Graphpoint(35, 45, 40, 35),
  Graphpoint(40, 50, 45, 36),
  Graphpoint(30, 40, 35, 37),
  Graphpoint(20, 30, 25, 38),
  Graphpoint(10, 20, 15, 39),
  Graphpoint(5, 15, 10, 40),
  Graphpoint(25, 35, 30, 41),
  Graphpoint(15, 25, 20, 42),
  Graphpoint(35, 45, 40, 43),
  Graphpoint(35, 45, 40, 47),
];

List<Graphpoint> emptyData=[];

List<Graphpoint> actualData = [
  // Graphpoint(29, 92, 53, 0),
  // Graphpoint(20, 90, 50, 1),
  // Graphpoint(25, 85, 55, 2),
  // Graphpoint(15, 75, 40, 3),
  // Graphpoint(30, 90, 35, 4),
  // Graphpoint(10, 60, 15, 5),
  // Graphpoint(5, 95, 10, 6),
  // Graphpoint(20, 40, 25, 7),
  // Graphpoint(15, 25, 20, 8),
  // Graphpoint(35, 45, 40, 9),
  // Graphpoint(25, 35, 30, 10),
  // Graphpoint(40, 50, 45, 11),
  // Graphpoint(45, 55, 50, 12),
  // Graphpoint(30, 40, 35, 13),
  // Graphpoint(20, 130, 25, 14),
  // Graphpoint(10, 20, 15, 15),
  Graphpoint(5, 15, 10, 12),
  Graphpoint(25, 35, 70, 17),
  Graphpoint(15, 25, 77, 18),
  Graphpoint(35, 45, 75, 19),
  Graphpoint(40, 50, 82, 20),
  Graphpoint(30, 40, 85, 21),
  Graphpoint(20, 30, 83, 22),
  Graphpoint(10, 20, 86, 23),
  Graphpoint(5, 15, 89, 24),
  Graphpoint(25, 35, 91, 25),
  Graphpoint(15, 25, 95, 26),
  Graphpoint(94, 101, 98, 27),
  Graphpoint(94, 98, 96, 28),
  Graphpoint(94, 101, 98, 29),
  Graphpoint(94, 98, 98, 30),
  Graphpoint(94, 101, 98, 31),
  Graphpoint(94, 101, 98, 32),
  Graphpoint(94, 101, 98, 33),
  Graphpoint(94, 101, 98, 34),
  Graphpoint(35, 45, 40, 35),
  Graphpoint(40, 101, 45, 36),
  // Graphpoint(30, 40, 35, 37),
  // Graphpoint(20, 30, 25, 38),
  // Graphpoint(10, 20, 15, 39),
  // Graphpoint(5, 15, 10, 40),
  // Graphpoint(25, 35, 30, 41),
  Graphpoint(15, 120, 75, 42),
  // Graphpoint(35, 45, 40, 43),
  // Graphpoint(35, 45, 40, 47),
];