enum ContactType {
  customer('customer', 'عميل'),
  supplier('supplier', 'مورد'),
  both('both', 'عميل ومورد');

  final String code;
  final String labelAr;
  const ContactType(this.code, this.labelAr);
}

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final ContactType type;
  final double balance; // موجب: لنا عنده (مدين)، سالب: له عندنا (دائن)
  final double creditLimit;
  final String? address;
  final String? notes;
  final DateTime createdAt;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
    this.balance = 0.0,
    this.creditLimit = 0.0,
    this.address,
    this.notes,
    required this.createdAt,
  });

  ContactModel copyWith({
    String? id,
    String? name,
    String? phone,
    ContactType? type,
    double? balance,
    double? creditLimit,
    String? address,
    String? notes,
    DateTime? createdAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      creditLimit: creditLimit ?? this.creditLimit,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'type': type.code,
        'balance': balance,
        'creditLimit': creditLimit,
        'address': address,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      type: ContactType.values.firstWhere((t) => t.code == json['type']),
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
