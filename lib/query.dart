class SelectQuery {
  List<String>_columns = [];
  String? _table;
  final List<String> _joins = [];
  final List<String> _wheres = [];
  final List<dynamic> _whereArgs = [];
  bool _matchAllWheres = false;
  String? _having;
  int? _limit;
  int? _offset;  
  final List<String> _groupBys = [];
  final List<String> _orderBys = [];
  final List<Order> _orderdDirections = []; 
  bool _debugEnabled = false;

  void select(List<String> columns, [String? table]) {
    if(table != null) {
      _columns.addAll(columns.map((col) => '$table.$col').toList());
    } else {   
      _columns.addAll(columns);
    }
  }

  void selectAll([String? table]) {
    _columns = table != null ? ['$table.*'] : ['*'];
  }

  void count([String? column]) {
    _columns.add(column != null ? 'COUNT($column)' : 'COUNT(*)');
  }

  void countAs(String alias, [String? column]) {
    _columns.add(column != null ? 'COUNT($column) AS $alias' : 'COUNT(*) AS $alias');
  }

  void from(String table) {
    _table = table;
  }

  void join(String table, String condition, { JoinType? type }) {
    if(type == null) {
      _joins.add('JOIN $table ON $condition'); 
    } else {
      _joins.add('${type.name.toString().toUpperCase()} JOIN $table ON $condition');
    }
  }

  void innerJoin(String table, String condition) {
    join(table, condition, type: JoinType.inner);
  }

  void leftJoin(String table, String condition) {
    join(table, condition, type: JoinType.left);
  }

  void rightJoin(String table, String condition) {
    join(table, condition, type: JoinType.right);
  }

  void fullJoin(String table, String condition) {
    join(table, condition, type: JoinType.full);
  }

  void where(String clause, [List<dynamic>? args]) {
    _wheres.add(clause);
    _whereArgs.addAll(args ?? []);
  }

  void whereNull(String column) {
    _wheres.add('$column IS NULL');
  }

  void whereNotNull(String column) {
    _wheres.add('$column IS NOT NULL');
  }

  void whereIn(String column, List<dynamic> options) {
    _wheres.add('WHERE $column IN ?');
    _whereArgs.add(options);
  }

  void matchAllWheres() {
    _matchAllWheres = true;
  }

  void having(String having) {
    _having = having;
  }

  void limit(int limit) {
    _limit = limit;
  }

  void take(int value) {
    limit(value);
  }

  void offset(int offset) {
    _offset = offset;
  }

  void skip(int value) {
    offset(value);
  }

  void orderBy(String column, { Order order = Order.asc }) {
    _orderBys.add(column);
    _orderdDirections.add(order);
  }

  void orderByDesc(String column) {
    _orderBys.add(column);
    _orderdDirections.add(Order.desc);
  }

  void orderByMultiple(List<String> columns, List<Order> orders) {
    _orderBys.addAll(columns);
    _orderdDirections.addAll(orders);
  }

  void groupBy(String column) {
    _groupBys.add(column);
  }

  void groupByMultiple(List<String> columns) {
    _groupBys.addAll(columns);
  }

  String build() {
    String query = _columns.isNotEmpty ? 'SELECT ${_columns.join(', ')} FROM $_table' : 'SELECT * FROM $_table';  
    
    for(var join in _joins) {
      query += ' $join';
    }
    
    if(_wheres.isNotEmpty) {
      if(_matchAllWheres) {
        query += ' WHERE ${_wheres.join(' AND ')}';
      } else {
        query += ' WHERE ${_wheres.join(' OR ')}';
      }
    }

    if(_groupBys.isNotEmpty) {
      query += ' GROUP BY ${_groupBys.join(', ')}';
    }

    if(_having != null) {
      query += ' HAVING $_having';
    }

    if(_orderBys.isNotEmpty) {
      List<String> orders = [];
      for (final (index, column) in _orderBys.indexed) {
        orders.add('$column ${_orderdDirections[index].name.toString().toUpperCase()}');
      }            
      query += ' ORDER BY ${orders.join(', ')}';
    }
    
    if(_limit != null) {
      query += ' LIMIT $_limit';
    }
    if(_offset != null) {
      query += ' OFFSET $_offset';
    }
    return query;
  }

  List<dynamic> get args {
    return _whereArgs;
  }

  void enableDebug() {
    _debugEnabled = true;
  }
  
  String debug() { 
    if(!_debugEnabled) {
      return 'disabled';
    }
    List argsList = [...args];   
    return build().replaceAllMapped(RegExp(r'((\w+)\s*[<>=]+\s*)\?'), (Match m) {
      if(argsList.isNotEmpty) {
        var arg = argsList.first;
        argsList.removeAt(0);                
        return '${m[1]}${transformArg(arg)}';  
      }
      return m[0]!;
    });
  }

  dynamic transformArg(dynamic arg) {
    if(arg is bool) {
      return arg ? 'true' : 'false';
    }
    if(arg is String) {
      return '"$arg"';
    }
    if(arg is List) {
      return arg.map((e) => transformArg(e));
    }
    return arg;
  }

  @override
  String toString() {
    return build();
  }
}

enum Order { asc, desc }

enum JoinType { inner, left, right, full }
