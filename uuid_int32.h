/*-------------------------------------------------------------------------
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
 *
 * uuid_int64.h
 *	  Header file for the "uuid_int64" ADT. In C, we use the name pg_uuid_int64,
 *	  to avoid conflicts with any uuid_t type that might be defined by
 *	  the system headers.
 *
 * uuid_int64.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef UUID_INT32_H
#define UUID_INT32_H

typedef struct pg_uuid_int32
{
    uint32 data[4];
} pg_uuid_int32;

/* fmgr interface macros */
#define UUID32PGetDatum(X)		PointerGetDatum(X)
#define PG_RETURN_UUID32_P(X)	return UUID32PGetDatum(X)
#define DatumGetUUID32P(X)		((pg_uuid_int32 *) DatumGetPointer(X))
#define PG_GETARG_UUID32_P(X)	DatumGetUUID32P(PG_GETARG_DATUM(X))

extern pg_uuid_int32* uuid_std_to_32(const pg_uuid_t *uuid);
extern pg_uuid_t* uuid_32_to_std(const pg_uuid_int32 *uuid);

#endif							/* UUID_INT32_H */
