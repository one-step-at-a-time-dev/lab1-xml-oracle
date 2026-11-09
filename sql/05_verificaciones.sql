-- =====================================================================
-- Laboratorio 1 - Script 05 (verificaciones complementarias)
-- 5.1 Validar DENTRO de Oracle que el XML generado por la consulta SQL/XML
--     (script 01) cumple el esquema registrado: XMLISVALID = 1.
-- 5.2 Validar los documentos almacenados en la tabla.
-- 5.3 Recuperar los datos del documento almacenado con XMLTABLE.
--
-- Conexion: usuario HR, servicio XEPDB1. Ejecutar despues de los scripts 03 y 04.
-- =====================================================================

-- Punto como separador decimal en esta sesion: Oracle convierte los
-- decimales guardados (salario, comision) a texto con la configuracion
-- regional; con la de Colombia saldria ",15" y la validacion fallaria.
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = '.,';

-- ---------------------------------------------------------------------
-- 5.1 1 = valido, 0 = no valido
-- ---------------------------------------------------------------------
SELECT XMLISVALID(q.documento_xml,
                  'http://localhost/hr/departamentos_hr.xsd',
                  'departamentos') AS consulta_es_valida
FROM (
  SELECT XMLELEMENT("departamentos",
           XMLAGG(dep.xml_departamento ORDER BY dep.department_id)
         ) AS documento_xml
  FROM (
         SELECT d.department_id,
                XMLELEMENT("departamento",
                  XMLATTRIBUTES(d.department_id   AS "id",
                                d.department_name AS "nombre"),
                  XMLELEMENT("ubicacion",
                    XMLFOREST(l.city         AS "ciudad",
                              c.country_name AS "pais")
                  ),
                  XMLELEMENT("empleados",
                    XMLAGG(
                      XMLELEMENT("empleado",
                        XMLATTRIBUTES(e.employee_id AS "id"),
                        XMLFOREST(e.first_name                          AS "nombre",
                                  e.last_name                           AS "apellido",
                                  e.email                               AS "email",
                                  TO_CHAR(e.hire_date, 'YYYY-MM-DD')    AS "fechaContratacion",
                                  j.job_title                           AS "cargo",
                                  TO_CHAR(e.salary, 'FM99999990.00')    AS "salario",
                                  TO_CHAR(e.commission_pct, 'FM0.00')   AS "comision")
                      )
                      ORDER BY e.employee_id
                    )
                  )
                ) AS xml_departamento
         FROM   departments d
                JOIN locations l ON l.location_id   = d.location_id
                JOIN countries c ON c.country_id    = l.country_id
                JOIN employees e ON e.department_id = d.department_id
                JOIN jobs      j ON j.job_id        = e.job_id
         GROUP  BY d.department_id, d.department_name, l.city, c.country_name
       ) dep
) q;

-- ---------------------------------------------------------------------
-- 5.2 Documentos almacenados (deben dar 1)
-- ---------------------------------------------------------------------
SELECT id_doc,
       descripcion,
       XMLISVALID(documento,
                  'http://localhost/hr/departamentos_hr.xsd',
                  'departamentos') AS es_valido
FROM   departamentos_xml
ORDER  BY id_doc;

-- ---------------------------------------------------------------------
-- 5.3 Lectura relacional del documento almacenado
-- ---------------------------------------------------------------------
SELECT t.id_doc,
       d.departamento,
       x.id_empleado,
       x.nombre,
       x.apellido,
       x.cargo,
       x.salario
FROM   departamentos_xml t,
       XMLTABLE('/departamentos/departamento'
                PASSING t.documento
                COLUMNS
                  departamento VARCHAR2(30) PATH '@nombre',
                  empleados    XMLTYPE      PATH 'empleados') d,
       XMLTABLE('/empleados/empleado'
                PASSING d.empleados
                COLUMNS
                  id_empleado  NUMBER       PATH '@id',
                  nombre       VARCHAR2(20) PATH 'nombre',
                  apellido     VARCHAR2(25) PATH 'apellido',
                  cargo        VARCHAR2(35) PATH 'cargo',
                  salario      VARCHAR2(12) PATH 'salario') x
ORDER  BY t.id_doc, x.id_empleado;
