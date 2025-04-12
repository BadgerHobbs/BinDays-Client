// External Imports
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

// Internal Imports
import 'bin_day.dart';
import 'client_side_request.dart';

part 'get_bin_days_response.g.dart';

/// Represents the response from a bin day lookup request.
@immutable
@JsonSerializable()
class GetBinDaysResponse {
  /// Gets the next client-side request to be made.
  final ClientSideRequest? nextClientSideRequest;

  /// Gets the list of bin days found.
  final List<BinDay>? binDays;

  /// Creates an instance of [GetBinDaysResponse].
  const GetBinDaysResponse({this.nextClientSideRequest, this.binDays});

  /// Creates a [GetBinDaysResponse] from its JSON representation.
  factory GetBinDaysResponse.fromJson(Map<String, dynamic> json) =>
      _$GetBinDaysResponseFromJson(json);

  /// Converts this [GetBinDaysResponse] instance to its JSON representation.
  Map<String, dynamic> toJson() => _$GetBinDaysResponseToJson(this);
}
