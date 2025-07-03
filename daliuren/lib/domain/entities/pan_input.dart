// lib/domain/entities/pan_input.dart

/// Enum defining the type of input used for Liu Ren pan calculation.
enum PanInputType {
  /// Input is based on a specific date and time.
  TIME_INPUT,
  /// Input is based on manually provided GanZhi (Stems and Branches) and other parameters.
  GANZHI_INPUT,
}

/// Represents the input parameters for calculating a Liu Ren pan.
/// This class supports two main ways of input: by specific time or by GanZhi.
class PanInput {
  /// The specific date and time for time-based input. Null for GanZhi input.
  final DateTime? dateTime;

  /// Year JiaZi (e.g., "甲子"). Used for GanZhi input, optional. String representation.
  final String? yearJiaZi;
  /// Month JiaZi (e.g., "丙寅"). Used for GanZhi input, optional. String representation.
  final String? monthJiaZi;
  /// Day JiaZi (e.g., "丁卯"). Required for GanZhi input. String representation.
  final String? dayJiaZi;
  /// Time JiaZi (e.g., "戊辰"). Used for GanZhi input. String representation.
  final String? timeJiaZi;
  /// YinYang Dun (e.g., "YANG", "YIN"). Used for GanZhi input, particularly with JuNumber. String representation.
  final String? yinYangDun;
  /// Ju Number (局数). Used for GanZhi input, often with YinYangDun.
  final int? juNumber;

  /// The type of input provided.
  final PanInputType inputType;

  /// Constructor for time-based pan input.
  PanInput.byTime({
    required this.dateTime,
  }) : inputType = PanInputType.TIME_INPUT,
       yearJiaZi = null,
       monthJiaZi = null,
       dayJiaZi = null,
       timeJiaZi = null,
       yinYangDun = null,
       juNumber = null;

  /// Constructor for GanZhi-based pan input.
  /// Requires [dayJiaZi].
  /// Either [timeJiaZi] (for direct lookup of preset pans) or
  /// both [juNumber] and [yinYangDun] (for specific Ju lookup) must be provided.
  PanInput.byGanZhi({
    this.yearJiaZi,
    this.monthJiaZi,
    required this.dayJiaZi,
    this.timeJiaZi,
    this.yinYangDun,
    this.juNumber,
  }) : inputType = PanInputType.GANZHI_INPUT,
       dateTime = null {
    // Ensure dayJiaZi is always provided for GanZhi input.
    assert(dayJiaZi != null, "Day JiaZi is required for GanZhi input.");
    // Ensure that if not using timeJiaZi, both juNumber and yinYangDun are provided.
    assert(timeJiaZi != null || (juNumber != null && yinYangDun != null),
           "For GanZhi input, either Time JiaZi or both Ju Number and YinYang Dun must be provided.");
  }

  @override
  String toString() {
    if (inputType == PanInputType.TIME_INPUT) {
      return "PanInput(Time: $dateTime)";
    } else {
      return "PanInput(GanZhi: Day=$dayJiaZi, Time=$timeJiaZi, Dun=$yinYangDun, Ju=$juNumber)";
    }
  }

  // Consider Equatable
}
