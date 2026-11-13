import 'package:equatable/equatable.dart';

double _toDouble(dynamic v) => (v as num?)?.toDouble() ?? 0;
double? _toDoubleOrNull(dynamic v) => (v as num?)?.toDouble();
DateTime _toDate(dynamic v) =>
    DateTime.tryParse(v?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);

class Product extends Equatable {
  final int? id;
  final String? title;
  final String? description;
  final String? category;
  final double? price;
  final double? discountPercentage;
  final double? rating;
  final int? stock;
  final List<String>? tags;
  final String? brand;
  final String? sku;
  final double? weight;
  final Dimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final List<Review>? reviews;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final Meta? meta;
  final List<String>? images;
  final String? thumbnail;

  const Product({
    this.id,
    this.title,
    this.description,
    this.category,
    this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.tags,
    this.brand,
    this.sku,
    this.weight,
    this.dimensions,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
    this.reviews,
    this.returnPolicy,
    this.minimumOrderQuantity,
    this.meta,
    this.images,
    this.thumbnail,
  });

  double get unitPrice {
    final p = price ?? 0;
    final d = discountPercentage ?? 0;
    return d > 0 ? p * (1 - d / 100) : p;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      price: _toDoubleOrNull(json['price']),
      discountPercentage: _toDoubleOrNull(json['discountPercentage']),
      rating: _toDoubleOrNull(json['rating']),
      stock: (json['stock'] as num?)?.toInt(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
      weight: _toDoubleOrNull(json['weight']),
      dimensions: json['dimensions'] is Map<String, dynamic>
          ? Dimensions.fromJson(json['dimensions'] as Map<String, dynamic>)
          : null,
      warrantyInformation: json['warrantyInformation'] as String?,
      shippingInformation: json['shippingInformation'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
      reviews: (json['reviews'] as List?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList(),
      returnPolicy: json['returnPolicy'] as String?,
      minimumOrderQuantity: (json['minimumOrderQuantity'] as num?)?.toInt(),
      meta: json['meta'] is Map<String, dynamic>
          ? Meta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      thumbnail: json['thumbnail'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'brand': brand,
      'sku': sku,
      'weight': weight,
      'dimensions': dimensions?.toJson(),
      'warrantyInformation': warrantyInformation,
      'shippingInformation': shippingInformation,
      'availabilityStatus': availabilityStatus,
      'reviews': reviews?.map((e) => e.toJson()).toList(),
      'returnPolicy': returnPolicy,
      'minimumOrderQuantity': minimumOrderQuantity,
      'meta': meta?.toJson(),
      'images': images,
      'thumbnail': thumbnail,
    };
  }

  @override
  List<Object?> get props => [id, title, price, discountPercentage, stock];
}

class Dimensions {
  final double width;
  final double height;
  final double depth;

  const Dimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) {
    return Dimensions(
      width: _toDouble(json['width']),
      height: _toDouble(json['height']),
      depth: _toDouble(json['depth']),
    );
  }

  Map<String, dynamic> toJson() => {'width': width, 'height': height, 'depth': depth};
}

class Review {
  final int rating;
  final String comment;
  final DateTime date;
  final String reviewerName;
  final String reviewerEmail;

  const Review({
    required this.rating,
    required this.comment,
    required this.date,
    required this.reviewerName,
    required this.reviewerEmail,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String? ?? '',
      date: _toDate(json['date']),
      reviewerName: json['reviewerName'] as String? ?? 'Anonymous',
      reviewerEmail: json['reviewerEmail'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'rating': rating,
        'comment': comment,
        'date': date.toIso8601String(),
        'reviewerName': reviewerName,
        'reviewerEmail': reviewerEmail,
      };
}

class Meta {
  final DateTime createdAt;
  final DateTime updatedAt;
  final String barcode;
  final String qrCode;

  const Meta({
    required this.createdAt,
    required this.updatedAt,
    required this.barcode,
    required this.qrCode,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      createdAt: _toDate(json['createdAt']),
      updatedAt: _toDate(json['updatedAt']),
      barcode: json['barcode'] as String? ?? '',
      qrCode: json['qrCode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'barcode': barcode,
        'qrCode': qrCode,
      };
}
