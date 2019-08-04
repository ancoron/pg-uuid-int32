#
# Makefile for extension 'uuid_int32'
#
# See: https://www.postgresql.org/docs/current/extend-extensions.html

MODULE_big = uuid_int32
OBJS = uuid_int32.o

# Define name of the extension
EXTENSION = uuid_int32

# Which SQL to execution at "CREATE EXTENSION ..."
DATA = $(EXTENSION)--0.1.sql

# pg_regress settings
REGRESS_PORT := 5432
REGRESS = $(EXTENSION)
REGRESS_OPTS = --load-extension=$(EXTENSION) --port=$(REGRESS_PORT)

# Use PGXS for installation
# See: https://www.postgresql.org/docs/current/extend-pgxs.html
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
