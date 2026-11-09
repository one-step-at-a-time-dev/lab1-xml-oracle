-- =====================================================================
-- Laboratorio 1 - Script 04
-- Inserciones en la tabla DEPARTAMENTOS_XML (columna ligada al XSD):
--   4.1 Insercion que SI se ajusta al esquema  -> 1 fila creada
--   4.2 Insercion que NO se ajusta al esquema  -> Oracle la rechaza
--
-- Conexion: usuario HR, servicio XEPDB1. Ejecutar despues del script 03.
-- Ejecutar cada sentencia por separado (Ctrl+Enter en SQL Developer) para
-- tomar la captura del resultado de cada una.
-- =====================================================================
SET DEFINE OFF

-- ---------------------------------------------------------------------
-- 4.1 INSERCION VALIDA
--     Cumple todas las reglas: raiz <departamentos>, atributos id y nombre,
--     elementos en el orden del xs:sequence, fecha xs:date, salario decimal
--     positivo y <comision> opcional (solo en el segundo empleado).
-- ---------------------------------------------------------------------
INSERT INTO departamentos_xml (id_doc, descripcion, documento)
VALUES (1, 'Insercion valida: cumple departamentos_hr.xsd',
  XMLTYPE('<departamentos xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:noNamespaceSchemaLocation="http://localhost/hr/departamentos_hr.xsd">
  <departamento id="280" nombre="Desarrollo de Software">
    <ubicacion>
      <ciudad>Bogota</ciudad>
      <pais>Colombia</pais>
    </ubicacion>
    <empleados>
      <empleado id="300">
        <nombre>Laura</nombre>
        <apellido>Gomez</apellido>
        <email>LGOMEZ</email>
        <fechaContratacion>2026-10-20</fechaContratacion>
        <cargo>Programmer</cargo>
        <salario>6500.00</salario>
      </empleado>
      <empleado id="301">
        <nombre>Andres</nombre>
        <apellido>Rojas</apellido>
        <email>AROJAS</email>
        <fechaContratacion>2026-10-27</fechaContratacion>
        <cargo>Sales Representative</cargo>
        <salario>7200.00</salario>
        <comision>0.15</comision>
      </empleado>
    </empleados>
  </departamento>
</departamentos>'));

COMMIT;

-- ---------------------------------------------------------------------
-- 4.2 INSERCION NO VALIDA (debe fallar)
--     El documento esta BIEN FORMADO (etiquetas abiertas y cerradas, una
--     sola raiz), pero NO ES VALIDO frente al XSD porque:
--       - <salario> contiene "seis mil", y el XSD exige xs:decimal.
--     Resultado esperado: error ORA-31061 / ORA-19202 con un mensaje LSX-...
--     indicando que el valor no es un decimal valido; no se inserta la fila.
--     (El numero exacto del error puede variar segun la version de Oracle.)
-- ---------------------------------------------------------------------
INSERT INTO departamentos_xml (id_doc, descripcion, documento)
VALUES (2, 'Insercion NO valida: salario no numerico',
  XMLTYPE('<departamentos xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
               xsi:noNamespaceSchemaLocation="http://localhost/hr/departamentos_hr.xsd">
  <departamento id="290" nombre="Soporte Tecnico">
    <ubicacion>
      <ciudad>Medellin</ciudad>
      <pais>Colombia</pais>
    </ubicacion>
    <empleados>
      <empleado id="302">
        <nombre>Camila</nombre>
        <apellido>Torres</apellido>
        <email>CTORRES</email>
        <fechaContratacion>2026-11-03</fechaContratacion>
        <cargo>Programmer</cargo>
        <salario>seis mil</salario>
      </empleado>
    </empleados>
  </departamento>
</departamentos>'));

ROLLBACK;

-- ---------------------------------------------------------------------
-- 4.3 Comprobar el contenido de la tabla: solo debe existir id_doc = 1
-- ---------------------------------------------------------------------
SELECT id_doc, descripcion FROM departamentos_xml ORDER BY id_doc;
