# SQL Select Query

A tiny Dart library for constructing SQl SELECT queries programmatically. It's  particularly useful if you need to build them dynamically.

An example:

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..select(['name'], 'departments)
    ..from('people')
    ..join('departments', 'people.department_id = departments.id')
    ..where('status = ?', ['active'])
    ..take(25)
    ..offset(50)
    ..orderBy('surname');
```

To use it, call `build()` to return the query as a string; the arguments are accessible via the `args` getter.

For example, if you're using SQFlite:

```dart
var results = db.rawQuery(query.build(), query.args);
```

## Usage

Using the double-dot operator is highly recommended; then, just build up your query piece-by-piece.

### Specify the Table

```dart
final query = SelectQuery();
query
    ..from('people');
```

Because there's no SELECT explicitly set, this will resolve to `SELECT * FROM people`.

This is equivalent:

```dart
final query = SelectQuery();
query
    ..selectAll()
    ..from('people');
```

### Select Column(s)

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..select(['name'], 'departments)
    ..from('people')
    ..join('departments', 'people.department_id = departments.id')
    ..where('status = ?', ['active'])
    ..orderBy('surname');
```

Note in that second call to `select`, the name of the table has been provided; this will resolve as `SELECT forename, surname, department.name ...`. 

### Counting

```dart
final query = SelectQuery();
query
    ..count()
    ..from('people');
```

This resolves to `SELECT COUNT(*) FROM people`.

You can also specify the column:

```dart
final query = SelectQuery();
query
    ..count('id')
    ..from('people');
```

This resolves to `SELECT COUNT(id) FROM people`.

You can provide an alias:

```dart
final query = SelectQuery();
query
    ..countAs('num_people')
    ..from('people');
```

This resolves to `SELECT COUNT(*) AS num_people FROM people`.

### Joins

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..select(['name'], 'departments)
    ..from('people')
    ..join('departments', 'people.department_id = departments.id')
```

There are also the following four methods, all with the same signature:

```dart
innerJoin(String column, String condition)
leftJoin(String column, String condition)
rightJoin(String column, String condition)
fullJoin(String column, String condition)
```

### Where Clauses

To add a WHERE clause:

```dart
final query = SelectQuery();
query
    ///   
    ..where('status = ?', ['active']);
```

It's quite common to have a bunch of WHERE clauses where all of them must match; you may also find you need this when you don't know ahead of time how many you've got, so calling and() each time can be problematic.

Just do this:

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')
    ..matchAllWheres()
    ..where('age > ?', 19)
    ..whereNotNull('department_id')
    ..where('status = ?', ['active'])
    ..orderBy('surname');
```

### Ordering results

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')    
    ..orderBy('surname');
```

or

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')    
    ..orderByDesc('age');
```

You can chain multiple calls:

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')
    ..orderBy('surname')    
    ..orderBy('forename');
```

### Grouping

```dart
final query = SelectQuery();
query
    ..select(['department_id'])
    ..countAs('num_people')    
    ..from('people')
    ..groupBy('department_id')
    ..orderByDesc('num_people');
```


### Limit

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')
    ..limit(10);
```

If you prefer a different terminology:

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')
    ..take(10);
```

### Offset

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')
    ..limit(10)
    ..offset(10);
```

If you prefer a different terminology:

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')
    ..take(10)
    ..skip(10);
```

### Debug Mode

It can be useful during development to see an SQl query with all of the parameters in their correct place.

> Use with caution!

This is vulnerable to SQL injection, so use with extreme caution. Indeed, you have to specifically enable it:

```dart
final query = SelectQuery();
query
    ..select(['forename', 'surname'])
    ..from('people')
    ..matchAllWheres()
    ..where('age > ?', [18])
    ..where('active = ?', [true])
    ..enableDebug();
```

Calling `debug()` will return `SELECT forename, surname FROM people WHERE age ? 18 AND active = true`; print it to the console, inspect it in the debugger, maybe even paste it into an SQL tool in your local environment &mdash; but don't use it in production.