CREATE TABLE "main"."object_set" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT,
    "description" TEXT,
    "update_date" DATETIME
);

-- Describe OBJECT
CREATE TABLE "object_" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "set_id" INTEGER REFERENCES object_set(id),
    "name" TEXT,
    "description" TEXT,
    "path" TEXT,
    "width" INTEGER,
    "height" INTEGER,
    "format" INTEGER,
    "obj_date" DATETIME,
    "update_date" DATETIME
);

-- Describe STATISTIC
CREATE TABLE "statistic" (
    "id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "name" TEXT,
    "type" TEXT,
    "description" TEXT,
    "update_date" DATETIME
);

-- Describe STAT_INT
CREATE TABLE "stat_int" (
    "stat_id" INTEGER REFERENCES statistic (id),
    "obj_id" INTEGER REFERENCES object_(id),
    "val" INTEGER,
    "update_date" DATETIME
);

-- Describe STAT_REAL
CREATE TABLE "stat_real" (
    "stat_id" INTEGER REFERENCES statistic (id),
    "obj_id" INTEGER REFERENCES object_(id),
    "val" REAL,
    "update_date" DATETIME
);

-- Describe STAT_TEXT
CREATE TABLE "stat_text" (
    "stat_id" INTEGER REFERENCES statistic (id),
    "obj_id" INTEGER REFERENCES object_(id),
    "val" TEXT,
    "update_date" DATETIME
);

------------------------------------------------------------------------------------------
-- Constraint Triggers
------------------------------------------------------------------------------------------

-- Describe TR_CONS_OBJECT_DEL
CREATE TRIGGER tr_cons_object_del BEFORE DELETE ON main.object_ FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'set_id violates foreign key object_set(id)') WHERE (SELECT id FROM object_set WHERE id = old.set_id) IS NOT NULL;
END;

---------------------------------------------
-- Describe TR_CONS_OBJECT_UPD
CREATE TRIGGER tr_cons_object_upd BEFORE UPDATE ON main.object_ FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'set_id violates foreign key object_set(id)')
    where  (SELECT id FROM object_set WHERE id = new.set_id) IS NULL;
END;

---------------------------------------------
-- Describe TR_CONS_OBJECT_INS
CREATE TRIGGER tr_cons_object_ins BEFORE INSERT ON main.object_ FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'set_id violates foreign key object_set(id)')
    where  (SELECT id FROM object_set WHERE id = new.set_id) IS NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_INT_DEL
CREATE TRIGGER tr_cons_stat_int_del BEFORE DELETE ON main.stat_int FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)') WHERE (SELECT id FROM object_ WHERE id = old.obj_id) IS NOT NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)') WHERE (SELECT id FROM statistic WHERE id = old.stat_id) IS NOT NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_INT_UPD
CREATE TRIGGER tr_cons_stat_int_upd BEFORE UPDATE ON main.stat_int FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)')
    where  (SELECT id FROM object_ WHERE id = new.obj_id) IS NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)')
    where  (SELECT id FROM statistic WHERE id = new.stat_id) IS NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_INT_INS
CREATE TRIGGER tr_cons_stat_int_ins BEFORE INSERT ON main.stat_int FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)')
    where  (SELECT id FROM object_ WHERE id = new.obj_id) IS NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)')
    where  (SELECT id FROM statistic WHERE id = new.stat_id) IS NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_REAL_DEL
CREATE TRIGGER tr_cons_stat_real_del BEFORE DELETE ON main.stat_real FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)') WHERE (SELECT id FROM object_ WHERE id = old.obj_id) IS NOT NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)') WHERE (SELECT id FROM statistic WHERE id = old.stat_id) IS NOT NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_REAL_UPD
CREATE TRIGGER tr_cons_stat_real_upd BEFORE UPDATE ON main.stat_real FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)')
    where  (SELECT id FROM object_ WHERE id = new.obj_id) IS NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)')
    where  (SELECT id FROM statistic WHERE id = new.stat_id) IS NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_REAL_INS
CREATE TRIGGER tr_cons_stat_real_ins BEFORE INSERT ON main.stat_real FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)')
    where  (SELECT id FROM object_ WHERE id = new.obj_id) IS NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)')
    where  (SELECT id FROM statistic WHERE id = new.stat_id) IS NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_TEXT_DEL
CREATE TRIGGER tr_cons_stat_text_del BEFORE DELETE ON main.stat_text FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)') WHERE (SELECT id FROM object_ WHERE id = old.obj_id) IS NOT NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)') WHERE (SELECT id FROM statistic WHERE id = old.stat_id) IS NOT NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_TEXT_UPD
CREATE TRIGGER tr_cons_stat_text_upd BEFORE UPDATE ON main.stat_text FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)')
    where  (SELECT id FROM object_ WHERE id = new.obj_id) IS NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)')
    where  (SELECT id FROM statistic WHERE id = new.stat_id) IS NULL;
END;

---------------------------------------------
-- Describe TR_CONS_STAT_TEXT_INS
CREATE TRIGGER tr_cons_stat_text_ins BEFORE INSERT ON main.stat_text FOR EACH ROW
BEGIN
-- created by Sqliteman tool

-- FK check
SELECT 
    RAISE(ABORT, 'obj_id violates foreign key object_(id)')
    where  (SELECT id FROM object_ WHERE id = new.obj_id) IS NULL;

-- FK check
SELECT 
    RAISE(ABORT, 'stat_id violates foreign key statistic(id)')
    where  (SELECT id FROM statistic WHERE id = new.stat_id) IS NULL;
END;

------------------------------------------------------------------------------------------
-- INDICES
------------------------------------------------------------------------------------------
-- Describe IDX_OBJECT_DATE
CREATE INDEX "idx_object_date" on object_ (obj_date ASC);

-- Describe IDX_OBJECT_NAME
CREATE INDEX "idx_object_name" on object_ (name ASC);

-- Describe IDX_STATISTIC_NAMETYPE
CREATE UNIQUE INDEX "idx_statistic_nametype" on statistic (name ASC, type ASC);

-- Describe IDX_STATINT_VALUE
CREATE INDEX "idx_statint_value" on stat_int (stat_id ASC, val ASC);

-- Describe IDX_STATREAL_VALUE
CREATE INDEX "idx_statreal_value" on stat_real (stat_id ASC, val ASC);

-- Describe IDX_STATTEXT_VALUE
CREATE INDEX "idx_stattext_value" on stat_text (stat_id ASC, val ASC);
