import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlparser/src/reader/tokenizer/token.dart';
import 'package:sqlparser/src/analysis/analysis.dart';

part 'clauses/limit.dart';
part 'clauses/ordering.dart';

part 'common/queryables.dart';
part 'common/renamable.dart';

part 'expressions/expressions.dart';
part 'expressions/function.dart';
part 'expressions/literals.dart';
part 'expressions/reference.dart';
part 'expressions/simple.dart';
part 'expressions/variables.dart';

part 'statements/select.dart';

abstract class AstNode {
  /// The parent of this node, or null if this is the root node. Will be set
  /// by the analyzer after the tree has been parsed.
  AstNode parent;

  Iterable<AstNode> get parents sync* {
    var node = parent;
    while (node != null) {
      yield node;
      node = node.parent;
    }
  }

  final Map<Type, dynamic> _metadata = {};
  T meta<T>() {
    return _metadata[T] as T;
  }

  void setMeta<T>(T value) {
    _metadata[T] = value;
  }

  ReferenceScope get scope {
    var node = this;

    while (node != null) {
      final scope = node.meta<ReferenceScope>();
      if (scope != null) return scope;
      node = node.parent;
    }

    throw StateError('No reference scope found in this or any parent node');
  }

  set scope(ReferenceScope scope) {
    setMeta<ReferenceScope>(scope);
  }

  Iterable<AstNode> get childNodes;
  T accept<T>(AstVisitor<T> visitor);

  /// Whether the content of this node is equal to the [other] node of the same
  /// type. The "content" refers to anything stored only in this node, children
  /// are ignored.
  bool contentEquals(covariant AstNode other);
}

abstract class AstVisitor<T> {
  T visitSelectStatement(SelectStatement e);
  T visitResultColumn(ResultColumn e);

  T visitOrderBy(OrderBy e);
  T visitOrderingTerm(OrderingTerm e);
  T visitLimit(Limit e);
  T visitQueryable(Queryable e);
  T visitJoin(Join e);
  T visitGroupBy(GroupBy e);

  T visitBinaryExpression(BinaryExpression e);
  T visitUnaryExpression(UnaryExpression e);
  T visitIsExpression(IsExpression e);
  T visitLiteral(Literal e);
  T visitReference(Reference e);
  T visitFunction(FunctionExpression e);

  T visitNumberedVariable(NumberedVariable e);
  T visitNamedVariable(ColonNamedVariable e);
}

/// Visitor that walks down the entire tree, visiting all children in order.
class RecursiveVisitor<T> extends AstVisitor<T> {
  @override
  T visitBinaryExpression(BinaryExpression e) => visitChildren(e);

  @override
  T visitFunction(FunctionExpression e) => visitChildren(e);

  @override
  T visitGroupBy(GroupBy e) => visitChildren(e);

  @override
  T visitIsExpression(IsExpression e) => visitChildren(e);

  @override
  T visitJoin(Join e) => visitChildren(e);

  @override
  T visitLimit(Limit e) => visitChildren(e);

  @override
  T visitLiteral(Literal e) => visitChildren(e);

  @override
  T visitNamedVariable(ColonNamedVariable e) => visitChildren(e);

  @override
  T visitNumberedVariable(NumberedVariable e) => visitChildren(e);

  @override
  T visitOrderBy(OrderBy e) => visitChildren(e);

  @override
  T visitOrderingTerm(OrderingTerm e) => visitChildren(e);

  @override
  T visitQueryable(Queryable e) => visitChildren(e);

  @override
  T visitReference(Reference e) => visitChildren(e);

  @override
  T visitResultColumn(ResultColumn e) => visitChildren(e);

  @override
  T visitSelectStatement(SelectStatement e) => visitChildren(e);

  @override
  T visitUnaryExpression(UnaryExpression e) => visitChildren(e);

  @protected
  T visitChildren(AstNode e) {
    for (var child in e.childNodes) {
      child.accept(this);
    }
    return null;
  }
}