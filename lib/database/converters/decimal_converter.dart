import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';

/// Drift [TypeConverter] to map arbitrary-precision [Decimal] values to and from SQLite String storage.
///
/// Ensures exact fractional dosing and inventory balances without IEEE-754 floating point rounding errors.
class DecimalConverter extends TypeConverter<Decimal, String> {
  const DecimalConverter();

  @override
  Decimal fromSql(String fromDb) {
    return Decimal.tryParse(fromDb) ?? Decimal.zero;
  }

  @override
  String toSql(Decimal value) {
    return value.toString();
  }
}
