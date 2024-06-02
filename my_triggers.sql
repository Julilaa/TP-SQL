CREATE OR REPLACE TRIGGER trg_insert_all_workers_elapsed
INSTEAD OF INSERT ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
  IF :NEW.age IS NOT NULL THEN
    INSERT INTO WORKERS_FACTORY_1 (first_name, last_name, age, first_day)
    VALUES (:NEW.first_name, :NEW.last_name, :NEW.age, :NEW.start_date);
  ELSE
    INSERT INTO WORKERS_FACTORY_2 (first_name, last_name, start_date)
    VALUES (:NEW.first_name, :NEW.last_name, :NEW.start_date);
  END IF;
END;

CREATE OR REPLACE TRIGGER trg_no_update_delete_all_workers_elapsed
INSTEAD OF UPDATE OR DELETE ON ALL_WORKERS_ELAPSED
FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20001, 'Different.');
END;

CREATE OR REPLACE TRIGGER trg_new_robot_audit
AFTER INSERT ON ROBOTS
FOR EACH ROW
BEGIN
  INSERT INTO AUDIT_ROBOT (robot_id, created_at)
  VALUES (:NEW.id, SYSDATE);
END;

-- Trigger sur la table ROBOTS
CREATE OR REPLACE TRIGGER trg_check_factories_count_robots
BEFORE INSERT OR UPDATE OR DELETE ON ROBOTS
DECLARE
  v_factory_count NUMBER;
  v_table_count NUMBER;
BEGIN
  -- Compter le nombre d'usines
  SELECT COUNT(*) INTO v_factory_count FROM FACTORIES;

  -- Compter le nombre de tables WORKERS_FACTORY_<N>
  SELECT COUNT(*) INTO v_table_count 
  FROM USER_TABLES 
  WHERE TABLE_NAME LIKE 'WORKERS_FACTORY_%';

  -- Vérifier si les comptes correspondent
  IF v_factory_count != v_table_count THEN
    RAISE_APPLICATION_ERROR(-20002, 'Mismatch between number of factories and WORKERS_FACTORY tables.');
  END IF;
END;

-- Trigger sur la table ROBOTS_FROM_FACTORY
CREATE OR REPLACE TRIGGER trg_check_factories_count_robots_from_factory
BEFORE INSERT OR UPDATE OR DELETE ON ROBOTS_FROM_FACTORY
DECLARE
  v_factory_count NUMBER;
  v_table_count NUMBER;
BEGIN
  -- Compter le nombre d'usines
  SELECT COUNT(*) INTO v_factory_count FROM FACTORIES;

  -- Compter le nombre de tables WORKERS_FACTORY_<N>
  SELECT COUNT(*) INTO v_table_count 
  FROM USER_TABLES 
  WHERE TABLE_NAME LIKE 'WORKERS_FACTORY_%';

  -- Vérifier si les comptes correspondent
  IF v_factory_count != v_table_count THEN
    RAISE_APPLICATION_ERROR(-20002, 'Mismatch between number of factories and WORKERS_FACTORY tables.');
  END IF;
END;


CREATE OR REPLACE TRIGGER trg_calculate_duration_factory_1
BEFORE UPDATE OF last_day ON WORKERS_FACTORY_1
FOR EACH ROW
DECLARE
  duration_in_factory NUMBER;
BEGIN
  IF :NEW.last_day IS NOT NULL THEN
    duration_in_factory := :NEW.last_day - :OLD.first_day;
    -- Traiter la durée (par exemple, enregistrer dans une autre table ou utiliser comme nécessaire)
  END IF;
END;

CREATE OR REPLACE TRIGGER trg_calculate_duration_factory_2
BEFORE UPDATE OF end_date ON WORKERS_FACTORY_2
FOR EACH ROW
DECLARE
  duration_in_factory NUMBER;
BEGIN
  IF :NEW.end_date IS NOT NULL THEN
    duration_in_factory := :NEW.end_date - :OLD.start_date;
    -- Traiter la durée (par exemple, enregistrer dans une autre table ou utiliser comme nécessaire)
  END IF;
END;


