-- =====================================================================
-- Laboratorio 1 - Script 03
-- Registro del esquema XML (XSD) en Oracle XML DB y creacion de la tabla
-- cuya columna XMLTYPE queda ligada a ese esquema.
--
-- Conexion: usuario HR, servicio XEPDB1.
-- El contenido del XSD es identico al fichero xsd/departamentos_hr.xsd
-- =====================================================================
SET SERVEROUTPUT ON
SET DEFINE OFF

-- ---------------------------------------------------------------------
-- 3.1 Limpieza (permite volver a ejecutar el script sin errores)
-- ---------------------------------------------------------------------
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE departamentos_xml PURGE';
  DBMS_OUTPUT.PUT_LINE('Tabla anterior eliminada.');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN RAISE; END IF;   -- -942: la tabla no existia
END;
/

BEGIN
  DBMS_XMLSCHEMA.deleteSchema(
    schemaurl     => 'http://localhost/hr/departamentos_hr.xsd',
    delete_option => DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
  DBMS_OUTPUT.PUT_LINE('Esquema anterior eliminado.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('No habia esquema previo registrado.');
END;
/

-- ---------------------------------------------------------------------
-- 3.2 Registro del esquema XML
--     OPTIONS => REGISTER_BINARYXML : el esquema se usa con almacenamiento
--     BINARY XML, que valida por completo cada documento al insertarlo.
-- ---------------------------------------------------------------------
DECLARE
  v_xsd CLOB := '<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
  <xs:simpleType name="texto20">
    <xs:restriction base="xs:string">
      <xs:minLength value="1"/>
      <xs:maxLength value="20"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="texto25">
    <xs:restriction base="xs:string">
      <xs:minLength value="1"/>
      <xs:maxLength value="25"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="texto30">
    <xs:restriction base="xs:string">
      <xs:minLength value="1"/>
      <xs:maxLength value="30"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="texto35">
    <xs:restriction base="xs:string">
      <xs:minLength value="1"/>
      <xs:maxLength value="35"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="texto40">
    <xs:restriction base="xs:string">
      <xs:minLength value="1"/>
      <xs:maxLength value="40"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="tipoSalario">
    <xs:restriction base="xs:decimal">
      <xs:totalDigits value="8"/>
      <xs:fractionDigits value="2"/>
      <xs:minExclusive value="0"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:simpleType name="tipoComision">
    <xs:restriction base="xs:decimal">
      <xs:fractionDigits value="2"/>
      <xs:minInclusive value="0"/>
      <xs:maxInclusive value="0.99"/>
    </xs:restriction>
  </xs:simpleType>
  <xs:complexType name="tipoUbicacion">
    <xs:sequence>
      <xs:element name="ciudad" type="texto30"/>
      <xs:element name="pais"   type="texto40"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="tipoEmpleado">
    <xs:sequence>
      <xs:element name="nombre"            type="texto20"/>
      <xs:element name="apellido"          type="texto25"/>
      <xs:element name="email"             type="texto25"/>
      <xs:element name="fechaContratacion" type="xs:date"/>
      <xs:element name="cargo"             type="texto35"/>
      <xs:element name="salario"           type="tipoSalario"/>
      <xs:element name="comision"          type="tipoComision" minOccurs="0"/>
    </xs:sequence>
    <xs:attribute name="id" type="xs:positiveInteger" use="required"/>
  </xs:complexType>
  <xs:complexType name="tipoEmpleados">
    <xs:sequence>
      <xs:element name="empleado" type="tipoEmpleado" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:complexType name="tipoDepartamento">
    <xs:sequence>
      <xs:element name="ubicacion" type="tipoUbicacion"/>
      <xs:element name="empleados" type="tipoEmpleados"/>
    </xs:sequence>
    <xs:attribute name="id"     type="xs:positiveInteger" use="required"/>
    <xs:attribute name="nombre" type="texto30"            use="required"/>
  </xs:complexType>
  <xs:complexType name="tipoDepartamentos">
    <xs:sequence>
      <xs:element name="departamento" type="tipoDepartamento" maxOccurs="unbounded"/>
    </xs:sequence>
  </xs:complexType>
  <xs:element name="departamentos" type="tipoDepartamentos"/>
</xs:schema>';
BEGIN
  DBMS_XMLSCHEMA.registerSchema(
    schemaurl => 'http://localhost/hr/departamentos_hr.xsd',
    schemadoc => XMLTYPE(v_xsd),
    local     => TRUE,
    gentypes  => FALSE,
    gentables => FALSE,
    options   => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
  DBMS_OUTPUT.PUT_LINE('Esquema registrado correctamente.');
END;
/

-- ---------------------------------------------------------------------
-- 3.3 Comprobar que el esquema quedo registrado
-- ---------------------------------------------------------------------
SELECT schema_url, local, binary
FROM   user_xml_schemas
WHERE  schema_url = 'http://localhost/hr/departamentos_hr.xsd';

-- ---------------------------------------------------------------------
-- 3.4 Tabla con columna XMLTYPE ligada al esquema registrado
-- ---------------------------------------------------------------------
CREATE TABLE departamentos_xml (
  id_doc      NUMBER        CONSTRAINT departamentos_xml_pk PRIMARY KEY,
  descripcion VARCHAR2(100),
  documento   XMLTYPE
)
XMLTYPE COLUMN documento STORE AS BINARY XML
  XMLSCHEMA "http://localhost/hr/departamentos_hr.xsd"
  ELEMENT "departamentos";

DESC departamentos_xml
