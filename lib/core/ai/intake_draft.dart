// lib/core/ai/intake_draft.dart

class IntakeDraft {
  final String? fullName;
  final String? nric;
  final String? address;
  final String? phone;
  final String? allergies;

  const IntakeDraft({
    this.fullName,
    this.nric,
    this.address,
    this.phone,
    this.allergies,
  });
  

  // ---------------------------------------------------------------------------
  // Merge helper (useful when LLM returns partial fields)
  // ---------------------------------------------------------------------------

  IntakeDraft merge(IntakeDraft other) {
    return IntakeDraft(
      fullName: other.fullName ?? fullName,
      nric: other.nric ?? nric,
      address: other.address ?? address,
      phone: other.phone ?? phone,
      allergies: other.allergies ?? allergies,
    );
  }

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  bool get hasAnyField =>
      (fullName?.trim().isNotEmpty ?? false) ||
      (nric?.trim().isNotEmpty ?? false) ||
      (address?.trim().isNotEmpty ?? false) ||
      (phone?.trim().isNotEmpty ?? false) ||
      (allergies?.trim().isNotEmpty ?? false);

  bool get isComplete =>
      (fullName?.trim().isNotEmpty ?? false) &&
      (nric?.trim().isNotEmpty ?? false) &&
      (address?.trim().isNotEmpty ?? false);

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, Object?> toJson() => {
        'fullName': fullName,
        'nric': nric,
        'address': address,
        'phone': phone,
        'allergies': allergies,
      };

  factory IntakeDraft.fromJson(Map<String, dynamic> json) {
    return IntakeDraft(
      fullName: json['fullName'] as String?,
      nric: json['nric'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      allergies: json['allergies'] as String?,
    );
  }

  /// Converts intake data into readable note body
  /// (used for Events.bodyText for quick display)
  String toNoteText() {
    final lines = <String>[];

    if (fullName?.trim().isNotEmpty ?? false) {
      lines.add('Full name: $fullName');
    }
    if (nric?.trim().isNotEmpty ?? false) {
      lines.add('NRIC: $nric');
    }
    if (address?.trim().isNotEmpty ?? false) {
      lines.add('Address: $address');
    }
    if (phone?.trim().isNotEmpty ?? false) {
      lines.add('Phone: $phone');
    }
    if (allergies?.trim().isNotEmpty ?? false) {
      lines.add('Allergies: $allergies');
    }

    return lines.join('\n');
  }

  // ---------------------------------------------------------------------------
  // Deterministic free-text parsing (MVP offline parser)
  // ---------------------------------------------------------------------------

  factory IntakeDraft.fromFreeText(String input) {
    final t = input.trim();

    // 1️⃣ NRIC (12 consecutive digits)
    final nricMatch = RegExp(r'(\d{12})').firstMatch(t);
    final nric = nricMatch?.group(1);

    // 2️⃣ Phone (Malaysia tolerant pattern)
    final phoneMatch =
        RegExp(r'(\+?6?0?1\d[\d\- ]{7,10})').firstMatch(t);
    final phone = phoneMatch
        ?.group(1)
        ?.replaceAll(RegExp(r'[^0-9+]'), '');

    // 3️⃣ Allergies keyword detection
    String? allergies;
    final allergyMatch = RegExp(
      r'(allergy|allergic|alahan)\s*[:\-]?\s*([^,;\n]+)',
      caseSensitive: false,
    ).firstMatch(t);
    if (allergyMatch != null) {
      allergies = allergyMatch.group(2)?.trim();
    }

    // 4️⃣ Address keyword detection
    String? address;
    final addrMatch = RegExp(
      r'(address|alamat)\s*[:\-]?\s*([^;\n]+)',
      caseSensitive: false,
    ).firstMatch(t);
    if (addrMatch != null) {
      address = addrMatch.group(2)?.trim();
    }

    // 5️⃣ Name keyword detection
    String? fullName;
    final nameMatch = RegExp(
      r'(name|nama)\s*[:\-]?\s*([^,;\n]+)',
      caseSensitive: false,
    ).firstMatch(t);
    if (nameMatch != null) {
      fullName = nameMatch.group(2)?.trim();
    }

    return IntakeDraft(
      fullName: fullName,
      nric: nric,
      address: address,
      phone: phone,
      allergies: allergies,
    );
  }

  @override
  String toString() {
    return 'IntakeDraft(fullName: $fullName, nric: $nric, '
        'address: $address, phone: $phone, allergies: $allergies)';
  }
}

class SaveIntakeDraftRequest {
  final String encounterId;
  final IntakeDraft draft;

  final String? unitId;
  final String? authorUserId;

  const SaveIntakeDraftRequest({
    required this.encounterId,
    required this.draft,
    this.unitId,
    this.authorUserId,
  });

  Map<String, Object?> toJson() => {
        'encounterId': encounterId,
        'draft': draft.toJson(),
        if (unitId != null) 'unitId': unitId,
        if (authorUserId != null) 'authorUserId': authorUserId,
      };
}