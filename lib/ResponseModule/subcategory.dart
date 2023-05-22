class Category {
  final String categoryId;
  final String cCategory;
  final List<SubCategory> subCategory;

  Category({
    required this.categoryId,
    required this.cCategory,
    required this.subCategory,
  });
}

class SubCategory {
  final String subcategoryId;
  final String cCategory;
  final List<KidCategory> kidCategory;

  SubCategory({
    required this.subcategoryId,
    required this.cCategory,
    required this.kidCategory,
  });
}

class KidCategory {
  final String subcategoryId;
  final String cCategory;

  KidCategory({
    required this.subcategoryId,
    required this.cCategory,
  });
}
