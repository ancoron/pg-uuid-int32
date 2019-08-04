
# PostgreSQL UUID data type stored as 32-bit integers

This extension for PostgreSQL provides a new generic data type `uuid_int32` for
UUID values of any version or variant that is more efficient than the standard
[UUID][2] data type in many scenarios.

The tested scenarios where this data type is more efficient than the standard
UUID are described shortly in the following section.


## Usage

After the extension has been installed (see the Build/Install section), you can
start using the data type as follows:

```sql
CREATE EXTENSION uuid_int32;

CREATE TABLE my_log (
    id uuid_int32 PRIMARY KEY,
    ...
);
```


## Internals

Instead of storing the 128-bit integer UUID value using 16 bytes as the standard
PostgreSQL `uuid` data type does, the `uuid_int32` stores it using 4 32-bit
unsigned integer values.

In addition, the most significant integer is not just a copy of the bytes from
a UUID representation but reshuffles the bytes to optimize for [RFC 4122][1]
version 1 UUID's and its timestamp field.


## Performance compared to standard UUID

As this data type is optimized for version 1 UUID's it provides much better
performance compared to standard [UUID][2] data type in PostgreSQL.


### INSERT / COPY ... FROM

Overall, using a query such as `COPY <table> FROM <file> (FORMAT text)`, the
performance has been improved by a factor of 8 for version 1 time-based UUID's.
In other words, such a statement usually just takes 12.5 % of the time compared
to executing the same query with standard `uuid` column.

In detail, the parsing of a UUID string input value has been optimized to
execute ~3 times as fast as the standard UUID parser does.

In addition - and this is most important when having an index at a UUID type
column - the different internal structure is now optimized for the
time-series nature of version 1 UUID's (which usually are created using the
current time). This has lead to a speed-up of factor 6-7 for internal B-Tree
comparison logic (function `_bt_compare`).

Another nice side effect is that the UUID values can now benefit from the
PostgreSQL B-Tree "fastpath", which optimizes for ever-inceasing index values
by basically caching the right-most index page. This means that most of the
time, an INSERT into an indexed talbe column will not need to search for the
relevant index page and we're getting a nice fastpath hit-rate. The standard
UUID spends ~50% of the time during INSERT's in this index page searching,
while this should be less than 1% for the data type `uuid_int32` when using
version 1 time-based UUID's.

For any other UUID version, the overall performance benefit should be ~10-15 %,
so still noticeable for larger data sets.


### SELECT / COPY ... TO

When larger numbers of UUID's need to be converted into a string representation
the performance of the conversion method plays a significant role.

Testing (using COPY) has revealed that the implementation for the `uuid_int32`
data type is ~4 times faster compared to the standard UUID output. However, the
resulting overall performance benefit (e.g. using `COPY` with format `text`) is
limited to a speedup of ~33 % due to processing in PostgreSQL itself which is
not related to the actual data type.

This improvement applies to all UUID versions.


### Time-series queries

The `uuid_int32` data can be directly used for time-series queries on version 1
time-based UUID's as the internal sort order is time-based. This enables queries
like the following:

```sql
SELECT *
FROM my_log
WHERE id >= '4938f30e-8449-11e9-0000-000000000000'::uuid_int32 AND id < 'b647e96b-862d-11e9-0000-000000000000'::uuid_int32
ORDER BY id;
```

...giving you an execution plan such as the following:

```
                                                                 QUERY PLAN                                                                 
--------------------------------------------------------------------------------------------------------------------------------------------
 Index Only Scan using my_log_pkey on my_log
   Index Cond: ((id >= '4938f30e-8449-11e9-0000-000000000000'::uuid_int32) AND (id < 'b647e96b-862d-11e9-0000-000000000000'::uuid_int32))
(2 rows)
```

As all other UUID versions do not have any semantic encoded there is no
collision of sort order but it will be different compared to the standard `uuid`
data type.


## Support functions

To provide additional features when using the `uuid_int32` data type, the following
functions are provided.


### uuid_int32_timestamp

The function `uuid_int32_timestamp(uuid_int32)` extracts the timestamp into an
instance of the PostgreSQL type [`timestamp with time zone`][3], e.g.:

```sql
SET timezone TO 'Asia/Tokyo';
SELECT uuid_int32_timestamp('b647e96b-862d-11e9-ae2b-db6f0f573554');
     uuid_int32_timestamp     
-------------------------------
 2019-06-04 03:30:50.132721+09
(1 row)
```

In case of a UUID not of version 1, this method returns `NULL`.


## Conversion to/from standard data type

In order to help with integration into existing systems the conversion from and
to the standard `uuid` data type is supported, e.g.:

```sql
INSERT INTO my_log (id) VALUES ('4938f30e-8449-11e9-ae2b-e03f49467033'::uuid);
```

Although we explicitly casted to data type `uuid` (or have it selected from
another table), the insert can execute just fine and handles the type conversion
automatically.

Explicit casting is also possible, e.g.:

```sql
SELECT '4938f30e-8449-11e9-ae2b-e03f49467033'::uuid::uuid_int32
```

...or:

```sql
SELECT '4938f30e-8449-11e9-ae2b-e03f49467033'::uuid_int32::uuid
```


## Build

Straight forward but please ensure that you have the necessary PostgreSQL
development headers in-place as well as [PGXS][4] (which should be made
available with installing the development package).

```
make
```

## Executing Tests

Some basic tests are included by making use of `pg_regress` which can be run with:

```
make installcheck
```

You might need to create a role with super-user privileges with the same name as
your local user or you re-use an existing one, e.g.:

```
sudo -u postgres make installcheck
```

If your _default_ PostgreSQL installation doesn't listen on standard port 5432,
you can adapt it by specifying `REGRESS_PORT` variable, e.g.:

```
sudo -u postgres make REGRESS_PORT=5433 installcheck
```


## Installation

This also requires [PGXS][4] as it figures out where to find the installation:

```
sudo make install
```

If you want to install it into a non-default PostgreSQL installation, just
specify the path to the respective `pg_config` binary, e.g.:

```
sudo make PG_CONFIG=/usr/lib/postgresql/10/bin/pg_config install
```


[1]: https://tools.ietf.org/html/rfc4122
[2]: https://www.postgresql.org/docs/current/datatype-uuid.html
[3]: https://www.postgresql.org/docs/current/datatype-datetime.html
[4]: https://www.postgresql.org/docs/current/extend-pgxs.html
