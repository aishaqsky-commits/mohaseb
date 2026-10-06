class JournalLineModel {
  final String id;
  final String accountId;
  final String accountName;
  final double debit;
  final double credit;
  final String? contactId;
  final String? contactName;
  final String? memo;

  const JournalLineModel({
    required this.id,
    required this.accountId,
    required this.accountName,
    this.debit = 0.0,
    this.credit = 0.0,
    this.contactId,
    this.contactName,
    this.memo,
  }) : assert((debit > 0 && credit == 0) || (credit > 0 && debit == 0),
            'يجب أن يكون السطر إما مديناً أو دائناً فقط (Checked constraint)');

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountId': accountId,
        'accountName': accountName,
        'debit': debit,
        'credit': credit,
        'contactId': contactId,
        'contactName': contactName,
        'memo': memo,
      };

  factory JournalLineModel.fromJson(Map<String, dynamic> json) {
    return JournalLineModel(
      id: json['id'] as String,
      accountId: json['accountId'] as String,
      accountName: json['accountName'] as String,
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      contactId: json['contactId'] as String?,
      contactName: json['contactName'] as String?,
      memo: json['memo'] as String?,
    );
  }
}

enum EntryStatus { draft, posted, reversed }
enum EntrySource { button, manual, ai, system }

class JournalEntryModel {
  final String id;
  final int entryNumber;
  final DateTime entryDate;
  final String referenceType;
  final String? referenceId;
  final String description;
  final EntrySource source;
  final EntryStatus status;
  final String? reversalOf;
  final String operationId; // UUID v7/v4 for Idempotency
  final List<JournalLineModel> lines;
  final DateTime createdAt;

  const JournalEntryModel({
    required this.id,
    required this.entryNumber,
    required this.entryDate,
    required this.referenceType,
    this.referenceId,
    required this.description,
    this.source = EntrySource.button,
    this.status = EntryStatus.posted,
    this.reversalOf,
    required this.operationId,
    required this.lines,
    required this.createdAt,
  });

  /// إجمالي المدين
  double get totalDebit => lines.fold(0.0, (sum, l) => sum + l.debit);

  /// إجمالي الدائن
  double get totalCredit => lines.fold(0.0, (sum, l) => sum + l.credit);

  /// التحقق الصارم من توازن القيد المحاسبي المزدوج
  bool get isBalanced => (totalDebit - totalCredit).abs() < 0.0001;

  Map<String, dynamic> toJson() => {
        'id': id,
        'entryNumber': entryNumber,
        'entryDate': entryDate.toIso8601String(),
        'referenceType': referenceType,
        'referenceId': referenceId,
        'description': description,
        'source': source.name,
        'status': status.name,
        'reversalOf': reversalOf,
        'operationId': operationId,
        'lines': lines.map((l) => l.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      entryNumber: json['entryNumber'] as int,
      entryDate: DateTime.parse(json['entryDate'] as String),
      referenceType: json['referenceType'] as String,
      referenceId: json['referenceId'] as String?,
      description: json['description'] as String,
      source: EntrySource.values.byName(json['source'] as String),
      status: EntryStatus.values.byName(json['status'] as String),
      reversalOf: json['reversalOf'] as String?,
      operationId: json['operationId'] as String,
      lines: (json['lines'] as List)
          .map((l) => JournalLineModel.fromJson(l as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
