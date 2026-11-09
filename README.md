# Laboratorio 1 – Almacenamiento y validación de ficheros XML en Oracle

Bases de Datos Avanzadas · Docente: Deivis Eduard Ramírez Martínez
Integrantes: [Integrante 1] · [Integrante 2] · [Integrante 3]

## Entorno
- Oracle Database 21c Express Edition (contenedor `XEPDB1`)
- Esquema de ejemplo **HR** (db-sample-schemas v21.1)
- SQL Developer y SQL*Plus
- Conexión: usuario `hr`, host `localhost`, puerto `1521`, **nombre de servicio** `XEPDB1`

## Estructura
| Ruta | Contenido |
|---|---|
| `sql/01_consulta_sqlxml.sql` | Consulta SQL/XML (XMLELEMENT, XMLATTRIBUTES, XMLFOREST, XMLAGG) sobre DEPARTMENTS, LOCATIONS, COUNTRIES, EMPLOYEES y JOBS |
| `sql/02_exportar_fichero_xml.sql` | Genera `departamentos_hr.xml` con SPOOL |
| `sql/03_registrar_esquema.sql` | Registra el XSD con `DBMS_XMLSCHEMA` y crea la tabla `DEPARTAMENTOS_XML` (XMLTYPE, BINARY XML) |
| `sql/04_inserciones.sql` | Inserción válida (se acepta) e inserción no válida (Oracle la rechaza) |
| `sql/05_verificaciones.sql` | `XMLISVALID` y lectura con `XMLTABLE` |
| `xsd/departamentos_hr.xsd` | Esquema XML |
| `xml/departamentos_hr.xml` | Fichero obtenido con la consulta |
| `xml/insercion_valida.xml`, `xml/insercion_no_valida.xml` | Documentos usados en las inserciones |

## Orden de ejecución (conectado como HR)
1. `01_consulta_sqlxml.sql` → ver el XML generado.
2. `02_exportar_fichero_xml.sql` → crear `departamentos_hr.xml`.
3. Validar `departamentos_hr.xml` contra `departamentos_hr.xsd` en https://www.freeformatter.com/xml-validator-xsd.html
4. `03_registrar_esquema.sql` → registrar el esquema y crear la tabla.
5. `04_inserciones.sql` → la primera inserción se acepta; la segunda falla por `<salario>seis mil</salario>`.
6. `05_verificaciones.sql` → `XMLISVALID = 1`.
