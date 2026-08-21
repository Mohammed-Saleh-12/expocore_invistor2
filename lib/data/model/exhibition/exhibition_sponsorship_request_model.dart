class ExhibitionSponsorshipRequestModel {
  final String id;
  final int exhibitionId;
  final String companyName;
  final String companyType;
  final String website;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final String proposedTier;
  final double proposedAmount;
  final String offerDetails;
  final String conditions;
  final String contractTerms;
  final String startDate;
  final String endDate;
  final String status;
  final String rejectReason;
  final String organizerNotes;

  const ExhibitionSponsorshipRequestModel({
    required this.id,
    required this.exhibitionId,
    required this.companyName,
    required this.companyType,
    required this.website,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.proposedTier,
    required this.proposedAmount,
    required this.offerDetails,
    required this.conditions,
    required this.contractTerms,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.rejectReason,
    required this.organizerNotes,
  });

  String get statusLabel {
    switch (status) {
      case 'approved':
      case 'accepted':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'pending':
      case 'new':
      case 'negotiating':
        return 'قيد المراجعة';
      default:
        return status.isEmpty ? 'قيد المراجعة' : status;
    }
  }

  factory ExhibitionSponsorshipRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExhibitionSponsorshipRequestModel(
      id: (json['id'] ?? '').toString(),
      exhibitionId: _toInt(json['exhibitionId'] ?? json['exhibition_id']),
      companyName: (json['companyName'] ?? json['company_name'] ?? '')
          .toString(),
      companyType: (json['companyType'] ?? json['company_type'] ?? '')
          .toString(),
      website: (json['website'] ?? '').toString(),
      contactName: (json['contactName'] ?? json['contact_name'] ?? '')
          .toString(),
      contactPhone: (json['contactPhone'] ?? json['contact_phone'] ?? '')
          .toString(),
      contactEmail: (json['contactEmail'] ?? json['contact_email'] ?? '')
          .toString(),
      proposedTier: (json['proposedTier'] ?? json['proposed_tier'] ?? '')
          .toString(),
      proposedAmount: _toDouble(
        json['proposedAmount'] ?? json['proposed_amount'],
      ),
      offerDetails: (json['offerDetails'] ?? json['offer_details'] ?? '')
          .toString(),
      conditions: (json['conditions'] ?? '').toString(),
      contractTerms: (json['contractTerms'] ?? json['contract_terms'] ?? '')
          .toString(),
      startDate: (json['startDate'] ?? json['start_date'] ?? '').toString(),
      endDate: (json['endDate'] ?? json['end_date'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      rejectReason: (json['rejectReason'] ?? json['reject_reason'] ?? '')
          .toString(),
      organizerNotes: (json['organizerNotes'] ?? json['organizer_notes'] ?? '')
          .toString(),
    );
  }

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  static double _toDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;
}
