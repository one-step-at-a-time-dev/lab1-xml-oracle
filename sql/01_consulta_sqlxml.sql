-- =====================================================================
-- Laboratorio 1: Almacenamiento y validacion de ficheros XML en Oracle
-- Script 01 - Recuperacion de datos del esquema HR en formato XML (SQL/XML)
--
-- Conexion : usuario HR, servicio XEPDB1 (Oracle Database 21c XE)
-- Tablas   : DEPARTMENTS, LOCATIONS, COUNTRIES, EMPLOYEES, JOBS (5 tablas)
-- Funciones: XMLELEMENT, XMLATTRIBUTES, XMLFOREST, XMLAGG
-- Resultado: un unico documento XML que cumple departamentos_hr.xsd
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1.1 Consulta que devuelve el documento como XMLTYPE
--     Nivel interno : un <departamento> por cada departamento con empleados
--                     (GROUP BY + XMLAGG de sus empleados).
--     Nivel externo : XMLAGG de todos los departamentos dentro de la raiz
--                     <departamentos>.
-- ---------------------------------------------------------------------
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
     ) dep;

-- Notas de diseno:
--  * TO_CHAR(fecha,'YYYY-MM-DD') produce el formato xs:date del XSD sin
--    depender de NLS_DATE_FORMAT.
--  * TO_CHAR(numero,'FM...0.00') usa siempre punto decimal; asi el salario
--    no sale con coma aunque el equipo tenga configuracion regional de Colombia.
--  * XMLFOREST omite los elementos con valor NULL: por eso <comision> solo
--    aparece en los empleados que tienen comision (minOccurs="0" en el XSD).
--  * JOIN interno con EMPLOYEES: solo salen departamentos con empleados
--    (el XSD exige al menos un <empleado> dentro de <empleados>).


-- ---------------------------------------------------------------------
-- 1.2 Misma consulta, serializada como texto con sangria (CLOB).
--     Util para copiar el resultado desde SQL Developer.
-- ---------------------------------------------------------------------
SELECT XMLSERIALIZE(DOCUMENT
         XMLELEMENT("departamentos",
           XMLAGG(dep.xml_departamento ORDER BY dep.department_id)
         )
       AS CLOB INDENT SIZE = 2) AS documento_xml
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
