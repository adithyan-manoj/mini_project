
import 'package:campusapp/models/comment_model.dart';
import 'package:flutter/material.dart';


class CommentUtils {
  /// Converts a flat list of comments from the database into a nested tree structure.
  static List<CommentModel> convertToTree(List<CommentModel> allComments) {
    // 1. Map every comment to its ID for quick lookup
    final Map<String, CommentModel> mapping = {
      for (var item in allComments) item.id: item.copyWith(subComments: [])
    };

    final List<CommentModel> tree = [];

    // 2. Iterate through comments to establish parent-child relationships
    for (var item in allComments) {
      if (item.parentId == null) {
        // Root comment
        tree.add(mapping[item.id]!);
      } else {
        // Child comment: Find parent and add to its subComments list
        final parent = mapping[item.parentId];
        if (parent != null) {
          parent.subComments.add(mapping[item.id]!);
        }
      }
    }
    return tree;
  }
}