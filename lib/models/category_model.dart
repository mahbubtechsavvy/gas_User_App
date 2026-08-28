class CategoryModel {
  final String id;
  final String nameBn;
  final String nameEn;
  final String slug;
  final String? iconUrl;
  final String? parentId;
  final List<CategoryModel> children;

  CategoryModel({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.slug,
    this.iconUrl,
    this.parentId,
    this.children = const [],
  });

  String localizedName(String locale) => locale == 'en' ? nameEn : nameBn;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    var rawChildren = json['children'] as List<dynamic>? ?? [];
    List<CategoryModel> childList = rawChildren
        .map((child) => CategoryModel.fromJson(child as Map<String, dynamic>))
        .toList();

    return CategoryModel(
      id: json['id']?.toString() ?? '',
      nameBn: json['nameBn']?.toString() ?? json['name']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString(),
      parentId: json['parentId']?.toString(),
      children: childList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameBn': nameBn,
      'nameEn': nameEn,
      'slug': slug,
      'iconUrl': iconUrl,
      'parentId': parentId,
      'children': children.map((c) => c.toJson()).toList(),
    };
  }
}
