-- =====================================================================
-- Laboratorio 1 - Script 02
-- Genera el fichero departamentos_hr.xml con el resultado de la consulta
-- SQL/XML del script 01 (el fichero que luego se valida en la web).
--
-- Como ejecutarlo (usuario HR):
--   SQL*Plus : abrir CMD en la carpeta donde quiera el fichero y ejecutar
--              sqlplus hr/<clave_hr>@localhost:1521/XEPDB1 @02_exportar_fichero_xml.sql
--   SQL Developer: abrir el script y pulsar "Ejecutar script" (F5).
--              Si no encuentra la ruta, cambie la linea SPOOL por una ruta
--              absoluta, por ejemplo: SPOOL C:\lab1\xml\departamentos_hr.xml
-- =====================================================================
SET ECHO OFF
SET FEEDBACK OFF
SET HEADING OFF
SET VERIFY OFF
SET PAGESIZE 0
SET LINESIZE 32767
SET LONG 1000000
SET LONGCHUNKSIZE 1000000
SET TRIMSPOOL ON
SET TRIMOUT ON

SPOOL departamentos_hr.xml

SELECT '<?xml version="1.0"?>' FROM dual;

SELECT XMLSERIALIZE(DOCUMENT
         XMLELEMENT("departamentos",
           XMLAGG(dep.xml_departamento ORDER BY dep.department_id)
         )
       AS CLOB INDENT SIZE = 2)
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
     ) dep;

SPOOL OFF

SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 50
PROMPT Fichero departamentos_hr.xml generado.
