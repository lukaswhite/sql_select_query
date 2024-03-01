import 'package:sql_select_query/sql_select_query.dart';
import 'package:test/test.dart';

void main() {
  group('basic select', () {
    test('single column', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people');
      expect(query.build(), 'SELECT forename FROM people');  
    });
    test('multiple columns', () {
      final query = SelectQuery();
      query
        ..select(['forename', 'surname'])
        ..from('people');
      expect(query.build(), 'SELECT forename, surname FROM people');
    });
    test('multiple columns, specifying table', () {
      final query = SelectQuery();
      query
        ..select(['forename', 'surname'], 'people')
        ..from('people');
      expect(query.build(), 'SELECT people.forename, people.surname FROM people');
    });
    test('all', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people');
      expect(query.build(), 'SELECT * FROM people');
    });
    test('all, specifying table', () {
      final query = SelectQuery();
      query
        ..selectAll('people')
        ..from('people');
      expect(query.build(), 'SELECT people.* FROM people');
    });
    test('all by default', () {
      final query = SelectQuery();
      query.from('people');
      expect(query.build(), 'SELECT * FROM people');
    });
    test('count column', () {
      final query = SelectQuery();
      query
        ..count('id')
        ..from('people');
      expect(query.build(), 'SELECT COUNT(id) FROM people');
    });
    test('count default', () {
      final query = SelectQuery();
      query
        ..count()
        ..from('people');
      expect(query.build(), 'SELECT COUNT(*) FROM people');
    });
    test('count plus more columns', () {
      final query = SelectQuery();
      query
        ..count('id')
        ..select(['foo'])
        ..from('people');
      expect(query.build(), 'SELECT COUNT(id), foo FROM people');
    });
  });
  group('joins', () {
    test('single default', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..join('departments', 'people.department_id = departments.id');
      expect(query.build(), 'SELECT forename FROM people JOIN departments ON people.department_id = departments.id');  
    });
    test('multiple default', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..join('departments', 'people.department_id = departments.id')
        ..join('teams', 'people.team_id = teams.id');
      expect(query.build(), 'SELECT forename FROM people JOIN departments ON people.department_id = departments.id JOIN teams ON people.team_id = teams.id');  
    });
    test('multiple specific type', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..join('departments', 'people.department_id = departments.id', type: JoinType.left)
        ..join('teams', 'people.team_id = teams.id', type: JoinType.right);
      expect(query.build(), 'SELECT forename FROM people LEFT JOIN departments ON people.department_id = departments.id RIGHT JOIN teams ON people.team_id = teams.id');  
    });
    test('more multiple specific type', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..join('departments', 'people.department_id = departments.id', type: JoinType.inner)
        ..join('teams', 'people.team_id = teams.id', type: JoinType.full);
      expect(query.build(), 'SELECT forename FROM people INNER JOIN departments ON people.department_id = departments.id FULL JOIN teams ON people.team_id = teams.id');  
    });
    test('multiple specific type aliases', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..leftJoin('departments', 'people.department_id = departments.id')
        ..rightJoin('teams', 'people.team_id = teams.id');
      expect(query.build(), 'SELECT forename FROM people LEFT JOIN departments ON people.department_id = departments.id RIGHT JOIN teams ON people.team_id = teams.id');  
    });
    test('more multiple specific type aliases', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..innerJoin('departments', 'people.department_id = departments.id')
        ..fullJoin('teams', 'people.team_id = teams.id');
      expect(query.build(), 'SELECT forename FROM people INNER JOIN departments ON people.department_id = departments.id FULL JOIN teams ON people.team_id = teams.id');  
    });
  });
  group('where clauses', () {
    test('single where clause', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..where('age > ?', [18]);
      expect(query.build(), 'SELECT * FROM people WHERE age > ?');
      expect(query.args, [18]);  
    });
    test('multiple where clauses, all must match', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..matchAllWheres()
        ..where('age > ?', [18])
        ..where('active = ?', [true]);
      expect(query.build(), 'SELECT * FROM people WHERE age > ? AND active = ?');
      expect(query.args, [18, true]);  
      
      query.where('banned = ?', [false]);
    
      expect(query.build(), 'SELECT * FROM people WHERE age > ? AND active = ? AND banned = ?');
      expect(query.args, [18, true, false]);  
      
    });
    test('multiple where clauses, some no args', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..matchAllWheres()
        ..where('age > ?', [18])
        ..where('mask & 11 != 0')
        ..where('active = ?', [true]);
      expect(query.build(), 'SELECT * FROM people WHERE age > ? AND mask & 11 != 0 AND active = ?');
      expect(query.args, [18, true]);  
      
    });
    test('multiple where clauses, including null checks', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..matchAllWheres()
        ..where('age > ?', [18])
        ..whereNotNull('email_confirmed')
        ..whereNull('banned_at');
      expect(query.build(), 'SELECT * FROM people WHERE age > ? AND email_confirmed IS NOT NULL AND banned_at IS NULL');
      expect(query.args, [18]);  
      
    });
  });
  group('where clauses with conjunctions', () {
    test('two clauses with and', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..where('age > ?', [18])
        ..and()
        ..where('age < ?', [90]);
        expect(query.build(), 'SELECT * FROM people WHERE age > ? AND age < ?');
    });
    test('three clauses with and', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..where('age > ?', [18])
        ..and()
        ..where('age < ?', [90])
        ..and()
        ..where('active = ?', [true]);
        expect(query.build(), 'SELECT * FROM people WHERE age > ? AND age < ? AND active = ?');
    });
    test('three clauses with and using alias', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..where('age > ?', [18])
        ..andWhere('age < ?', [90])
        ..andWhere('active = ?', [true]);
        expect(query.build(), 'SELECT * FROM people WHERE age > ? AND age < ? AND active = ?');
    });
  });
  group('where clauses with conjunctions', () {
    test('two clauses with or', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..where('age > ?', [18])
        ..or()
        ..where('active = ?', [false]);
        expect(query.build(), 'SELECT * FROM people WHERE age > ? OR active = ?');
    });
    test('three clauses with or', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..where('age > ?', [18])        
        ..or()
        ..where('active = ?', [false])
        ..or()
        ..where('banned = ?', [true]);
        expect(query.build(), 'SELECT * FROM people WHERE age > ? OR active = ? OR banned = ?');
    });
    test('three clauses with or using alias', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..where('age > ?', [18])        
        ..orWhere('active = ?', [false])
        ..orWhere('banned = ?', [true]);
        expect(query.build(), 'SELECT * FROM people WHERE age > ? OR active = ? OR banned = ?');
    });
  });
  group('debug where clauses', () {
    test('disabled by default', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..matchAllWheres()
        ..where('age > ?', [18])
        ..where('mask & 11 != 0')
        ..where('active = ?', [true]);
      expect(query.debug(), 'disabled');
    });
    test('multiple where clauses, some no args', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..matchAllWheres()
        ..where('age > ?', [18])
        ..where('mask & 11 != 0')
        ..where('active = ?', [true])
        ..enableDebug();

      expect(query.debug(), 'SELECT * FROM people WHERE age > 18 AND mask & 11 != 0 AND active = true');
      expect(query.args, [18, true]);  
      
    });
    test('quotes strings', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..matchAllWheres()
        ..where('age > ?', [18])
        ..where('mask & 11 != 0')
        ..where('title = ?', ['Mr.'])
        ..where('active = ?', [true])
        ..enableDebug();

      expect(query.debug(), 'SELECT * FROM people WHERE age > 18 AND mask & 11 != 0 AND title = "Mr." AND active = true');      
    });
    test('handles where in', () {
      final query = SelectQuery();
      query
        ..selectAll()
        ..from('people')
        ..whereIn('role', ['admin', 'superadmin'])
        ..enableDebug();

      //expect(query.debug(), 'SELECT * FROM people WHERE role IN ');      
    });
  });
  group('having', () {
    test('single having', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..having('age > 18')
        ..orderBy('surname', order: Order.asc);
      expect(query.build(), 'SELECT forename FROM people HAVING age > 18 ORDER BY surname ASC');  
    });
  });
  group('ordering', () {
    test('single column asc', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..orderBy('surname', order: Order.asc);
      expect(query.build(), 'SELECT forename FROM people ORDER BY surname ASC');  
    });
    test('single column asc by default', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..orderBy('surname');
      expect(query.build(), 'SELECT forename FROM people ORDER BY surname ASC');  
    });
    test('single column desc', () {
      final query = SelectQuery();
      query
        ..select(['forename', 'age'])
        ..from('people')
        ..orderBy('age', order: Order.desc);
      expect(query.build(), 'SELECT forename, age FROM people ORDER BY age DESC');  
    });
    test('single column desc alias', () {
      final query = SelectQuery();
      query
        ..select(['forename', 'age'])
        ..from('people')
        ..orderByDesc('age');
      expect(query.build(), 'SELECT forename, age FROM people ORDER BY age DESC');  
    });
    test('multiple columns', () {
      final query = SelectQuery();
      query
        ..select(['forename', 'age'])
        ..from('people')
        ..orderByMultiple(['age', 'surname'], [Order.desc, Order.asc]);
      expect(query.build(), 'SELECT forename, age FROM people ORDER BY age DESC, surname ASC');  
    });
  });  
  group('grouping', () {
    test('single column', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..groupBy('department');
      expect(query.build(), 'SELECT forename FROM people GROUP BY department');  
    });
    test('single column multiple times', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..groupBy('department')
        ..groupBy('position');
      expect(query.build(), 'SELECT forename FROM people GROUP BY department, position');  
    });      
    test('multiple columns', () {
      final query = SelectQuery();
      query
        ..select(['forename', 'age'])
        ..from('people')
        ..groupByMultiple(['department', 'position']);
      expect(query.build(), 'SELECT forename, age FROM people GROUP BY department, position');  
    });
  });  
  group('limits and offsets', () {
    test('has limit', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..orderBy('surname', order: Order.asc)
        ..limit(25);
      expect(query.build(), 'SELECT forename FROM people ORDER BY surname ASC LIMIT 25');  
    });
    test('has offset', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..orderBy('surname', order: Order.asc)
        ..offset(10);
      expect(query.build(), 'SELECT forename FROM people ORDER BY surname ASC OFFSET 10');  
    });
    test('has limit and offset', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..orderBy('surname', order: Order.asc)
        ..limit(25)
        ..offset(10);
      expect(query.build(), 'SELECT forename FROM people ORDER BY surname ASC LIMIT 25 OFFSET 10');  
    });
    test('take and skip aliases', () {
      final query = SelectQuery();
      query
        ..select(['forename'])
        ..from('people')
        ..orderBy('surname', order: Order.asc)
        ..take(25)
        ..skip(10);
      expect(query.build(), 'SELECT forename FROM people ORDER BY surname ASC LIMIT 25 OFFSET 10');  
    });
  });
  group('grouping, counting, aliases', () {
    test('count by alias', () {
      final query = SelectQuery();
      query          
          ..countAs('num_people')    
          ..select(['name'], 'departments')
          ..from('people')
          ..join('departments', 'people.department_id = departments.id')
          ..groupBy('department_id')
          ..orderByDesc('num_people');
      expect(query.build(), 'SELECT COUNT(*) AS num_people, departments.name FROM people JOIN departments ON people.department_id = departments.id GROUP BY department_id ORDER BY num_people DESC'); 
    });
  });
}

