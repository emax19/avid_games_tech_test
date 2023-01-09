# Avid Games DB Technical Test


## Question 1
Using MariaDB 10.4, create a stored procedure that takes a JSON object as input which contains n key/value pairs. This procedure should use a Common     Table Expression in some way and output a result set that contains two columns: key and value. If the input is invalid or not a JSON object, throw error 333.

Example:

```
MariaDB> call json_to_table('{"foo":true,"bar":{"baz":2},"0":1,"2":"three"}'); 
+------+------------+
| key  | value      |
+------+------------+
| foo  | true       |
| bar  | {"baz": 2} |
| 0    | 1          |
| 2    | three      |
+------+------------+
4 rows in set (0.004 sec)

Query OK, 0 rows affected (0.004 sec)

MariaDB> call json_to_table('{"invalid"}'); 
ERROR 333 (45000): Invalid JSON object
```

When complete, commit your SQL file to a public GIT repository and supply the link.

### Answer
[json_to_table.sql](https://github.com/emax19/avid_games_tech_test/blob/main/json_to_table.sql)

## Question 2
A Mariadb 10.3 Galera cluster with three nodes requires a schema change that, if put through normally, will block queries to a frequently accessed table and bring down the API. If this change is backwards compatible with the existing queries made to the database, what steps, being specific, would you take to roll out the new schema?

### Answer 

Migration Guide:
If we want to update schema without any server degradations then the changes during the migration process must be backward compatible, but the whole migration should not be backward compatible. Migrations steps:
1. prepare sql ddl update(open/closed principle - it must not rename(instead of rename, add new column) or delete columns). If it’s the adding of a new column, use default values under null constraint as this column will not be used during the migration process.
2. Use RSU(Rolling Schema Upgrade) method. Run ddl update on all nodes consequently. The node is disconnecting from the cluster during the dll update. When update is done, node synchronizes all write operations from the cluster. Then go to the next node and run ddl there.
3. Now we can deploy an updated service which consumes new dll schema, and it also has to be backward compatible, i.e. if we rename column, then in ddl we create new column, and for first change we should write into 2 columns(deprecated and new/renamed) the same data(we probably need to implement a feature toggle, but it depends on requirements, in most cases we can omit it)
4. (If migration requires delete any column or table) Deploy an updated service which already don’t use deprecated ddl.
5. (If migration requires delete any column or table) Using RSU method delete deprecated columns, tables

## Question 3

Queries on a large InnoDB table are taking longer and longer to complete. After some investigation, it is determined that indexes are fine and queries are optimal. However, the CPU is increasingly waiting for IO to complete while retrieving data from persistent storage. Assuming the system hardware configuration is also optimal, what would you do to remedy the situation?

### Answer
   Context: hardware, indexes and queries are optimal. CPU is increasingly waiting for IO for read operations.
   The main thing what has to be done is to determine the source of the degradation. As a part of investigation, the IO waiting degradation can be led by increasing amount of request to the storage(hard drive, SDD). There are some improvements can be done to reduce the amount of reads to the physical storage:
   - Increase the size of the InnoDB buffer pool: The InnoDB buffer pool is an in-memory cache that stores data and indexes for InnoDB tables. Increasing the size of the buffer pool can help to reduce the amount of IO required to access data, as more data and indexes will be stored in memory.
   - Enable InnoDB compression: InnoDB tables can be compressed to reduce the amount of storage space required, which can also help to reduce IO overhead.
   - Consider using cache providers in service level to decrease the amount of traffic to sql database.
   - Scale more nodes of the sql cluster
