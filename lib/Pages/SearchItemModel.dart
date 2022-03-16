class SearchItemModel {
  var categoryId;
  var categoryName;
  var subcatId;
  var subcatName;
  var productId;
  var productName;
  var productImage;

  SearchItemModel(
      {this.categoryId,
        this.categoryName,
        this.subcatId,
        this.subcatName,
        this.productId,
        this.productName,
        this.productImage});

  SearchItemModel.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    categoryName = json['category_name'];
    subcatId = json['subcat_id'];
    subcatName = json['subcat_name'];
    productId = json['product_id'];
    productName = json['product_name'];
    productImage = json['product_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category_id'] = this.categoryId;
    data['category_name'] = this.categoryName;
    data['subcat_id'] = this.subcatId;
    data['subcat_name'] = this.subcatName;
    data['product_id'] = this.productId;
    data['product_name'] = this.productName;
    data['product_image'] = this.productImage;
    return data;
  }
}