/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "CREATE EXTENSION uuid_int32" to load this file. \quit


-- create new data type "uuid_int32"
CREATE FUNCTION uuid_int32_in(cstring)
RETURNS uuid_int32
AS 'MODULE_PATHNAME', 'uuid_int32_in'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

CREATE FUNCTION uuid_int32_out(uuid_int32)
RETURNS cstring
AS 'MODULE_PATHNAME', 'uuid_int32_out'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

CREATE FUNCTION uuid_int32_recv(internal)
RETURNS uuid_int32
AS 'MODULE_PATHNAME', 'uuid_int32_recv'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

CREATE FUNCTION uuid_int32_send(uuid_int32)
RETURNS bytea
AS 'MODULE_PATHNAME', 'uuid_int32_send'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

CREATE TYPE uuid_int32 (
    INTERNALLENGTH = 16,
    INPUT = uuid_int32_in,
    OUTPUT = uuid_int32_out,
    RECEIVE = uuid_int32_recv,
    SEND = uuid_int32_send,
    STORAGE = plain,
    ALIGNMENT = int4
);

-- type conversion helper functions
CREATE FUNCTION uuid_int32_convert(uuid_int32) RETURNS uuid
AS 'MODULE_PATHNAME', 'uuid_int32_conv_to_std'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

CREATE FUNCTION uuid_int32_convert(uuid) RETURNS uuid_int32
AS 'MODULE_PATHNAME', 'uuid_int32_conv_from_std'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

-- create casts
CREATE CAST (uuid AS uuid_int32) WITH FUNCTION uuid_int32_convert(uuid) AS IMPLICIT;

CREATE CAST (uuid_int32 AS uuid) WITH FUNCTION uuid_int32_convert(uuid_int32) AS IMPLICIT;

-- extract information
CREATE FUNCTION uuid_int32_timestamp(uuid_int32) RETURNS timestamp with time zone
AS 'MODULE_PATHNAME', 'uuid_int32_timestamp'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

-- equal
CREATE FUNCTION uuid_int32_eq(uuid_int32, uuid_int32)
RETURNS bool
AS 'MODULE_PATHNAME', 'uuid_int32_eq'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_eq(uuid_int32, uuid_int32) IS 'equal to';

CREATE OPERATOR = (
    LEFTARG = uuid_int32,
    RIGHTARG = uuid_int32,
    PROCEDURE = uuid_int32_eq,
    COMMUTATOR = '=',
    NEGATOR = '<>',
    RESTRICT = eqsel,
    JOIN = eqjoinsel,
    MERGES
);

-- not equal
CREATE FUNCTION uuid_int32_ne(uuid_int32, uuid_int32)
RETURNS bool
AS 'MODULE_PATHNAME', 'uuid_int32_ne'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_ne(uuid_int32, uuid_int32) IS 'not equal to';

CREATE OPERATOR <> (
	LEFTARG = uuid_int32,
    RIGHTARG = uuid_int32,
    PROCEDURE = uuid_int32_ne,
    COMMUTATOR = '<>',
    NEGATOR = '=',
    RESTRICT = neqsel,
    JOIN = neqjoinsel
);

-- lower than
CREATE FUNCTION uuid_int32_lt(uuid_int32, uuid_int32)
RETURNS bool
AS 'MODULE_PATHNAME', 'uuid_int32_lt'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_lt(uuid_int32, uuid_int32) IS 'lower than';

CREATE OPERATOR < (
	LEFTARG = uuid_int32,
    RIGHTARG = uuid_int32,
    PROCEDURE = uuid_int32_lt,
	COMMUTATOR = '>',
    NEGATOR = '>=',
	RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);

-- greater than
CREATE FUNCTION uuid_int32_gt(uuid_int32, uuid_int32)
RETURNS bool
AS 'MODULE_PATHNAME', 'uuid_int32_gt'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_gt(uuid_int32, uuid_int32) IS 'greater than';

CREATE OPERATOR > (
	LEFTARG = uuid_int32,
    RIGHTARG = uuid_int32,
    PROCEDURE = uuid_int32_gt,
	COMMUTATOR = '<',
    NEGATOR = '<=',
	RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);

-- lower than or equal
CREATE FUNCTION uuid_int32_le(uuid_int32, uuid_int32)
RETURNS bool
AS 'MODULE_PATHNAME', 'uuid_int32_le'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_le(uuid_int32, uuid_int32) IS 'lower than or equal to';

CREATE OPERATOR <= (
	LEFTARG = uuid_int32,
    RIGHTARG = uuid_int32,
    PROCEDURE = uuid_int32_le,
	COMMUTATOR = '>=',
    NEGATOR = '>',
	RESTRICT = scalarltsel,
    JOIN = scalarltjoinsel
);

-- greater than or equal
CREATE FUNCTION uuid_int32_ge(uuid_int32, uuid_int32)
RETURNS bool
AS 'MODULE_PATHNAME', 'uuid_int32_ge'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_ge(uuid_int32, uuid_int32) IS 'greater than or equal to';

CREATE OPERATOR >= (
	LEFTARG = uuid_int32,
    RIGHTARG = uuid_int32,
    PROCEDURE = uuid_int32_ge,
	COMMUTATOR = '<=',
    NEGATOR = '<',
	RESTRICT = scalargtsel,
    JOIN = scalargtjoinsel
);

-- generic comparison function
CREATE FUNCTION uuid_int32_cmp(uuid_int32, uuid_int32)
RETURNS int4
AS 'MODULE_PATHNAME', 'uuid_int32_cmp'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_cmp(uuid_int32, uuid_int32) IS 'UUID v1 comparison function';

-- sort support function
CREATE FUNCTION uuid_int32_sortsupport(internal)
RETURNS void
AS 'MODULE_PATHNAME', 'uuid_int32_sortsupport'
LANGUAGE C IMMUTABLE LEAKPROOF STRICT PARALLEL SAFE;

COMMENT ON FUNCTION uuid_int32_sortsupport(internal) IS 'btree sort support function';


-- create operator class
CREATE OPERATOR CLASS uuid_int32_ops DEFAULT FOR TYPE uuid_int32
    USING btree AS
        OPERATOR        1       <,
        OPERATOR        2       <=,
        OPERATOR        3       =,
        OPERATOR        4       >=,
        OPERATOR        5       >,
        FUNCTION        1       uuid_int32_cmp(uuid_int32, uuid_int32),
        FUNCTION        2       uuid_int32_sortsupport(internal)
;
