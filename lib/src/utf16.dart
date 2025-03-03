// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library utf.utf16;

import 'dart:collection';

import 'constants.dart';
import 'list_range.dart';
import 'utf_16_code_unit_decoder.dart';
import 'util.dart';

/// Generate a string from the provided Unicode codepoints.
///
/// *Deprecated* Use [String.fromCharCodes] instead.
@deprecated
String codepointsToString(List<int> codepoints) {
  return String.fromCharCodes(codepoints);
}

/// Decodes the UTF-16 bytes as an iterable. Thus, the consumer can only convert
/// as much of the input as needed. Determines the byte order from the BOM,
/// or uses big-endian as a default. This method always strips a leading BOM.
/// Set the [replacementCodepoint] to null to throw an ArgumentError
/// rather than replace the bad value. The default value for
/// [replacementCodepoint] is U+FFFD.
IterableUtf16Decoder decodeUtf16AsIterable(List<int> bytes,
    [int offset = 0,
    int? length,
    int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]) {
  return IterableUtf16Decoder._(
      () => Utf16BytesToCodeUnitsDecoder(
          bytes, offset, length, replacementCodepoint),
      replacementCodepoint);
}

/// Decodes the UTF-16BE bytes as an iterable. Thus, the consumer can only
/// convert as much of the input as needed. This method strips a leading BOM by
/// default, but can be overridden by setting the optional parameter [stripBom]
/// to false. Set the [replacementCodepoint] to null to throw an
/// ArgumentError rather than replace the bad value. The default
/// value for the [replacementCodepoint] is U+FFFD.
IterableUtf16Decoder decodeUtf16beAsIterable(List<int> bytes,
    [int offset = 0,
    int? length,
    bool stripBom = true,
    int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]) {
  return IterableUtf16Decoder._(
      () => Utf16beBytesToCodeUnitsDecoder(
          bytes, offset, length, stripBom, replacementCodepoint),
      replacementCodepoint);
}

/// Decodes the UTF-16LE bytes as an iterable. Thus, the consumer can only
/// convert as much of the input as needed. This method strips a leading BOM by
/// default, but can be overridden by setting the optional parameter [stripBom]
/// to false. Set the [replacementCodepoint] to null to throw an
/// ArgumentError rather than replace the bad value. The default
/// value for the [replacementCodepoint] is U+FFFD.
IterableUtf16Decoder decodeUtf16leAsIterable(List<int> bytes,
    [int offset = 0,
    int? length,
    bool stripBom = true,
    int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]) {
  return IterableUtf16Decoder._(
      () => Utf16leBytesToCodeUnitsDecoder(
          bytes, offset, length, stripBom, replacementCodepoint),
      replacementCodepoint);
}

/// Produce a String from a sequence of UTF-16 encoded bytes. This method always
/// strips a leading BOM. Set the [replacementCodepoint] to null to throw  an
/// ArgumentError rather than replace the bad value. The default
/// value for the [replacementCodepoint] is U+FFFD.
String decodeUtf16(List<int> bytes,
    [int offset = 0,
    int? length,
    int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]) {
  var decoder =
      Utf16BytesToCodeUnitsDecoder(bytes, offset, length, replacementCodepoint);
  var codeunits = decoder.decodeRest();
  return String.fromCharCodes(
      utf16CodeUnitsToCodepoints(codeunits, 0, null, replacementCodepoint)
          as Iterable<int>);
}

/// Produce a String from a sequence of UTF-16BE encoded bytes. This method
/// strips a leading BOM by default, but can be overridden by setting the
/// optional parameter [stripBom] to false. Set the [replacementCodepoint] to
/// null to throw an ArgumentError rather than replace the bad value.
/// The default value for the [replacementCodepoint] is U+FFFD.
String decodeUtf16be(List<int> bytes,
    [int offset = 0,
    int? length,
    bool stripBom = true,
    int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]) {
  var codeunits = (Utf16beBytesToCodeUnitsDecoder(
          bytes, offset, length, stripBom, replacementCodepoint))
      .decodeRest();
  return String.fromCharCodes(
      utf16CodeUnitsToCodepoints(codeunits, 0, null, replacementCodepoint)
          as Iterable<int>);
}

/// Produce a String from a sequence of UTF-16LE encoded bytes. This method
/// strips a leading BOM by default, but can be overridden by setting the
/// optional parameter [stripBom] to false. Set the [replacementCodepoint] to
/// null to throw an ArgumentError rather than replace the bad value.
/// The default value for the [replacementCodepoint] is U+FFFD.
String decodeUtf16le(List<int> bytes,
    [int offset = 0,
    int? length,
    bool stripBom = true,
    int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]) {
  var codeunits = (Utf16leBytesToCodeUnitsDecoder(
          bytes, offset, length, stripBom, replacementCodepoint))
      .decodeRest();
  return String.fromCharCodes(
      utf16CodeUnitsToCodepoints(codeunits, 0, null, replacementCodepoint)
          as Iterable<int>);
}

/// Produce a list of UTF-16 encoded bytes. This method prefixes the resulting
/// bytes with a big-endian byte-order-marker.
List<int?> encodeUtf16(String str) => encodeUtf16be(str, true);

/// Produce a list of UTF-16BE encoded bytes. By default, this method produces
/// UTF-16BE bytes with no BOM.
List<int?> encodeUtf16be(String str, [bool writeBOM = false]) {
  var utf16CodeUnits = _stringToUtf16CodeUnits(str);
  var encoding = List<int?>.filled(
      2 * utf16CodeUnits.length + (writeBOM ? 2 : 0), 0,
      growable: true);
  var i = 0;
  if (writeBOM) {
    encoding[i++] = UNICODE_UTF_BOM_HI;
    encoding[i++] = UNICODE_UTF_BOM_LO;
  }
  for (var unit in utf16CodeUnits) {
    encoding[i++] = (unit! & UNICODE_BYTE_ONE_MASK) >> 8;
    encoding[i++] = unit & UNICODE_BYTE_ZERO_MASK;
  }
  return encoding;
}

/// Produce a list of UTF-16LE encoded bytes. By default, this method produces
/// UTF-16LE bytes with no BOM.
List<int?> encodeUtf16le(String str, [bool writeBOM = false]) {
  var utf16CodeUnits = _stringToUtf16CodeUnits(str);
  var encoding = List<int?>.filled(
      2 * utf16CodeUnits.length + (writeBOM ? 2 : 0), 0,
      growable: true);
  var i = 0;
  if (writeBOM) {
    encoding[i++] = UNICODE_UTF_BOM_LO;
    encoding[i++] = UNICODE_UTF_BOM_HI;
  }
  for (var unit in utf16CodeUnits) {
    encoding[i++] = unit! & UNICODE_BYTE_ZERO_MASK;
    encoding[i++] = (unit & UNICODE_BYTE_ONE_MASK) >> 8;
  }
  return encoding;
}

/// Identifies whether a List of bytes starts (based on offset) with a
/// byte-order marker (BOM).
bool hasUtf16Bom(List<int> utf32EncodedBytes, [int offset = 0, int? length]) {
  return hasUtf16beBom(utf32EncodedBytes, offset, length) ||
      hasUtf16leBom(utf32EncodedBytes, offset, length);
}

/// Identifies whether a List of bytes starts (based on offset) with a
/// big-endian byte-order marker (BOM).
bool hasUtf16beBom(List<int> utf16EncodedBytes, [int offset = 0, int? length]) {
  var end = length != null ? offset + length : utf16EncodedBytes.length;
  return (offset + 2) <= end &&
      utf16EncodedBytes[offset] == UNICODE_UTF_BOM_HI &&
      utf16EncodedBytes[offset + 1] == UNICODE_UTF_BOM_LO;
}

/// Identifies whether a List of bytes starts (based on offset) with a
/// little-endian byte-order marker (BOM).
bool hasUtf16leBom(List<int> utf16EncodedBytes, [int offset = 0, int? length]) {
  var end = length != null ? offset + length : utf16EncodedBytes.length;
  return (offset + 2) <= end &&
      utf16EncodedBytes[offset] == UNICODE_UTF_BOM_LO &&
      utf16EncodedBytes[offset + 1] == UNICODE_UTF_BOM_HI;
}

List<int?> _stringToUtf16CodeUnits(String str) {
  return codepointsToUtf16CodeUnits(str.codeUnits);
}

typedef _CodeUnitsProvider = ListRangeIterator Function();

/// Return type of [decodeUtf16AsIterable] and variants. The Iterable type
/// provides an iterator on demand and the iterator will only translate bytes
/// as requested by the user of the iterator. (Note: results are not cached.)
// TODO(floitsch): Consider removing the extend and switch to implements since
// that's cheaper to allocate.
class IterableUtf16Decoder extends IterableBase<int?> {
  final _CodeUnitsProvider codeunitsProvider;
  final int replacementCodepoint;

  IterableUtf16Decoder._(this.codeunitsProvider, this.replacementCodepoint);

  @override
  Utf16CodeUnitDecoder get iterator =>
      Utf16CodeUnitDecoder.fromListRangeIterator(
          codeunitsProvider(), replacementCodepoint);
}

/// Convert UTF-16 encoded bytes to UTF-16 code units by grouping 1-2 bytes
/// to produce the code unit (0-(2^16)-1). Relies on BOM to determine
/// endian-ness, and defaults to BE.
abstract class Utf16BytesToCodeUnitsDecoder implements ListRangeIterator {
  // TODO(kevmoo): should this field be private?
  final ListRangeIterator utf16EncodedBytesIterator;
  final int replacementCodepoint;
  int? _current;

  Utf16BytesToCodeUnitsDecoder._fromListRangeIterator(
      this.utf16EncodedBytesIterator, this.replacementCodepoint);

  factory Utf16BytesToCodeUnitsDecoder(List<int> utf16EncodedBytes,
      [int offset = 0,
      int? length,
      int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT]) {
    length ??= utf16EncodedBytes.length - offset;
    if (hasUtf16beBom(utf16EncodedBytes, offset, length)) {
      return Utf16beBytesToCodeUnitsDecoder(utf16EncodedBytes, offset + 2,
          length - 2, false, replacementCodepoint);
    } else if (hasUtf16leBom(utf16EncodedBytes, offset, length)) {
      return Utf16leBytesToCodeUnitsDecoder(utf16EncodedBytes, offset + 2,
          length - 2, false, replacementCodepoint);
    } else {
      return Utf16beBytesToCodeUnitsDecoder(
          utf16EncodedBytes, offset, length, false, replacementCodepoint);
    }
  }

  /// Provides a fast way to decode the rest of the source bytes in a single
  /// call. This method trades memory for improved speed in that it potentially
  /// over-allocates the List containing results.
  List<int?> decodeRest() {
    var codeunits = List<int?>.filled(remaining, 0, growable: true);
    var i = 0;
    while (moveNext()) {
      codeunits[i++] = current;
    }
    if (i == codeunits.length) {
      return codeunits;
    } else {
      var truncCodeunits = List<int?>.filled(i, 0, growable: true);
      truncCodeunits.setRange(0, i, codeunits);
      return truncCodeunits;
    }
  }

  @override
  int? get current => _current;

  @override
  bool moveNext() {
    _current = null;
    var remaining = utf16EncodedBytesIterator.remaining;
    if (remaining == 0) {
      _current = null;
      return false;
    }
    if (remaining == 1) {
      utf16EncodedBytesIterator.moveNext();
      if (replacementCodepoint != null) {
        _current = replacementCodepoint;
        return true;
      } else {
        throw ArgumentError(
            'Invalid UTF16 at ${utf16EncodedBytesIterator.position}');
      }
    }
    _current = decode();
    return true;
  }

  @override
  int get position => utf16EncodedBytesIterator.position ~/ 2;

  @override
  void backup([int? by = 1]) {
    utf16EncodedBytesIterator.backup(2 * by!);
  }

  @override
  int get remaining => (utf16EncodedBytesIterator.remaining + 1) ~/ 2;

  @override
  void skip([int? count = 1]) {
    utf16EncodedBytesIterator.skip(2 * count!);
  }

  int decode();
}

/// Convert UTF-16BE encoded bytes to utf16 code units by grouping 1-2 bytes
/// to produce the code unit (0-(2^16)-1).
class Utf16beBytesToCodeUnitsDecoder extends Utf16BytesToCodeUnitsDecoder {
  Utf16beBytesToCodeUnitsDecoder(List<int> utf16EncodedBytes,
      [int offset = 0,
      int? length,
      bool stripBom = true,
      int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT])
      : super._fromListRangeIterator(
            (ListRange(utf16EncodedBytes, offset, length)).iterator,
            replacementCodepoint) {
    if (stripBom && hasUtf16beBom(utf16EncodedBytes, offset, length)) {
      skip();
    }
  }

  @override
  int decode() {
    utf16EncodedBytesIterator.moveNext();
    var hi = utf16EncodedBytesIterator.current!;
    utf16EncodedBytesIterator.moveNext();
    var lo = utf16EncodedBytesIterator.current!;
    return (hi << 8) + lo;
  }
}

/// Convert UTF-16LE encoded bytes to utf16 code units by grouping 1-2 bytes
/// to produce the code unit (0-(2^16)-1).
class Utf16leBytesToCodeUnitsDecoder extends Utf16BytesToCodeUnitsDecoder {
  Utf16leBytesToCodeUnitsDecoder(List<int> utf16EncodedBytes,
      [int offset = 0,
      int? length,
      bool stripBom = true,
      int replacementCodepoint = UNICODE_REPLACEMENT_CHARACTER_CODEPOINT])
      : super._fromListRangeIterator(
            (ListRange(utf16EncodedBytes, offset, length)).iterator,
            replacementCodepoint) {
    if (stripBom && hasUtf16leBom(utf16EncodedBytes, offset, length)) {
      skip();
    }
  }

  @override
  int decode() {
    utf16EncodedBytesIterator.moveNext();
    var lo = utf16EncodedBytesIterator.current!;
    utf16EncodedBytesIterator.moveNext();
    var hi = utf16EncodedBytesIterator.current!;
    return (hi << 8) + lo;
  }
}
