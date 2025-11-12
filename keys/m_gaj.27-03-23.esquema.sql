CREATE ROLE gaj_owner WITH SUPERUSER;
CREATE ROLE gaj_r WITH SUPERUSER;
CREATE ROLE gaj_rw WITH SUPERUSER;

CREATE ROLE dgaj_owner WITH SUPERUSER;
CREATE ROLE tsugitw1 WITH SUPERUSER;

CREATE ROLE cbasel0 WITH SUPERUSER;
CREATE ROLE chernan0 WITH SUPERUSER;
CREATE ROLE pgrigio0 WITH SUPERUSER;

SET search_path TO sch_gaj;

--
-- PostgreSQL database dump
--

-- Dumped from database version 11.19 (Debian 11.19-1.pgdg100+1)
-- Dumped by pg_dump version 12.14 (Debian 12.14-1.pgdg100+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: sch_gaj; Type: SCHEMA; Schema: -; Owner: gaj_owner
--

CREATE SCHEMA sch_gaj;


ALTER SCHEMA sch_gaj OWNER TO gaj_owner;

--
-- Name: SCHEMA sch_gaj; Type: COMMENT; Schema: -; Owner: gaj_owner
--

COMMENT ON SCHEMA sch_gaj IS 'Secretaría de Gobierno; Esquema del sistema de Gestion de Actas y Juzgamiento; Almacena datos de las multas;';


--
-- Name: dblink; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dblink WITH SCHEMA sch_gaj;


--
-- Name: EXTENSION dblink; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dblink IS 'connect to other PostgreSQL databases from within a database';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: actualizar_persona_ids(bigint, bigint); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.actualizar_persona_ids(idpersonaold bigint, idpersonanew bigint) RETURNS integer
    LANGUAGE plpgsql
    AS $$
   BEGIN
        update cor_egreso set persona_retira_id=idPersonaNew where persona_retira_id = idPersonaOld;
        update cor_novedad set persona_notificada_id=idPersonaNew where persona_notificada_id = idPersonaOld;
        update cor_verificaciontecnica set persona_verifica_id=idPersonaNew where persona_verifica_id = idPersonaOld;
        update pad_agente set persona_id=idPersonaNew where persona_id = idPersonaOld;
        update pad_titular       set persona_id = idPersonaNew where persona_id = idPersonaOld;
        update pad_autorizado set persona_id = idPersonaNew where persona_id = idPersonaOld;
        update com_presunto_infractor set persona_id = idPersonaNew where persona_id = idPersonaOld;
        update com_acta set infractor_id = idPersonaNew where infractor_id = idPersonaOld;

        delete from pad_persona where id = idPersonaOld;
       
        RETURN 0;
    END;
   $$;


ALTER FUNCTION sch_gaj.actualizar_persona_ids(idpersonaold bigint, idpersonanew bigint) OWNER TO gaj_owner;

--
-- Name: insert_apelacion(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_apelacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
    	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
        SEQ_NAME varchar := 'juz_apelacion_numero_' || YEAR_NOW || '_seq';
        _kind char 		 := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
        sql_seq text := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
	BEGIN
		IF _kind IS NULL THEN
            EXECUTE sql_seq;
        END IF;
		NEW.numero := CAST ( (CAST (nextval(SEQ_NAME) as varchar) || substring(YEAR_NOW from 3 for 4) ) as integer);
    	RETURN NEW;
	END;
	$$;


ALTER FUNCTION sch_gaj.insert_apelacion() OWNER TO gaj_owner;

--
-- Name: insert_clausura(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_clausura() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
    DECLARE
    	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
        SEQ_NAME varchar := 'cla_clausura_numero_' || YEAR_NOW || '_seq';
        _kind char 		 := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
        sql_seq text := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
	BEGIN
		      
        --raise notice 'Ejecutando clausura: %', NEW.id;
		--raise notice 'YEAR: %', YEAR_NOW;
        --raise notice 'Verificando si existe la secuencia';

		IF _kind IS NULL THEN
        	
            -- creo la sequence para el año actual
            --raise notice 'Secuencia no existe, creando...';
            
            EXECUTE sql_seq;

            --raise notice 'secuencia del año % creada', YEAR_NOW;
        
        END IF;
									
		NEW.numero := CAST ( (CAST (nextval(SEQ_NAME) as varchar) || substring(YEAR_NOW from 3 for 4) ) as integer);
        
        --raise notice 'Nro Clausura: %', NEW.numero;
        --raise notice 'Fin:';
	
    	RETURN NEW;
        
	END;
	$$;


ALTER FUNCTION sch_gaj.insert_clausura() OWNER TO gaj_owner;

--
-- Name: insert_com_liberacion(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_com_liberacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
BEGIN
    NEW.nro_liberacion := CAST (nextval('com_libera_numero_liberacion_seq') as integer );
    RETURN NEW;
END;
$$;


ALTER FUNCTION sch_gaj.insert_com_liberacion() OWNER TO gaj_owner;

--
-- Name: insert_inventario(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_inventario() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
    DECLARE
    	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
        SEQ_NAME varchar := 'cor_inventario_nro_inventario_' || YEAR_NOW || '_seq';
        _kind char 		 := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
        sql_seq text := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
	BEGIN
		      
        --raise notice 'Ejecutando inventario: %', NEW.id;
		--raise notice 'YEAR: %', YEAR_NOW;
        --raise notice 'Verificando si existe la secuencia';

		IF _kind IS NULL THEN
        	
            -- creo la sequence para el año actual
            --raise notice 'Secuencia no existe, creando...';
            
            EXECUTE sql_seq;

            --raise notice 'secuencia del año % creada', YEAR_NOW;
        
        END IF;
									
		NEW.nro_inventario := CAST ( (CAST (nextval(SEQ_NAME) as varchar) || substring(YEAR_NOW from 3 for 4) ) as integer);
        
        --raise notice 'Nro Inventario: %', NEW.nro_inventario;
        --raise notice 'Fin:';
	
    	RETURN NEW;
        
	END;
	$$;


ALTER FUNCTION sch_gaj.insert_inventario() OWNER TO gaj_owner;

--
-- Name: insert_libremulta(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_libremulta() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
DECLARE
	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
	TIPO varchar;
    SEQ_NAME varchar;
    _kind char;
    sql_seq text;
BEGIN
    
	TIPO := NEW.tipo;
    SEQ_NAME := 'tra_libremulta_numero_' || TIPO || YEAR_NOW || '_seq';
    _kind := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
    sql_seq := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
   
	--raise notice 'YEAR: %', YEAR_NOW;
	--raise notice 'SEQ: %', SEQ_NAME;

	IF _kind IS NULL THEN
    	
        -- creo la sequence
        --raise notice 'Secuencia no existe, creando...';
        
        EXECUTE sql_seq;

        --raise notice 'secuencia creada';
    
    END IF;
								
	NEW.numero_tramite := CAST ( (CAST (nextval(SEQ_NAME) as varchar) ) as integer);
    
    --raise notice 'Nro tramite: %', NEW.numero_tramite;
    --raise notice 'Fin:';

	RETURN NEW;
    
END;
$$;


ALTER FUNCTION sch_gaj.insert_libremulta() OWNER TO gaj_owner;

--
-- Name: insert_notificacion(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_notificacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
   
    DECLARE
    	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;
        SEQ_NAME varchar := 'not_notificacion_codigo_' || YEAR_NOW || '_seq';
        _kind char := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
        sql_seq text := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
	BEGIN
     
        --raise notice 'Ejecutando insert: %', NEW.id;
		--raise notice 'YEAR: %', YEAR_NOW;
        --raise notice 'Verificando si existe la secuencia';

		IF _kind IS NULL THEN
       
        -- creo la sequence para el año actual
        --raise notice 'Secuencia no existe, creando...';
           
        EXECUTE sql_seq;

        --raise notice 'secuencia del año % creada', YEAR_NOW;
       
    	END IF;

		-- origen
		NEW.codigo :=
		(SELECT CASE WHEN r.codigo IS NULL THEN '1' ELSE '3' END FROM def_usuario_permiso_notificacion upn
		INNER JOIN def_usuario u ON u.usuario LIKE NEW.creation_user
	  	INNER JOIN def_reparticion r ON upn.reparticion_id = r.id AND r.codigo LIKE '76'  LIMIT 1);
		--

		NEW.codigo := COALESCE(NEW.codigo,'1') || LPAD(nextval(SEQ_NAME)::text, 6, '0') || substring(YEAR_NOW from 3 for 4) AS INTEGER;
       
        --raise notice 'Codigo: %', NEW.codigo;
        --raise notice 'Fin:';

    	RETURN NEW;
       
	END;
$$;


ALTER FUNCTION sch_gaj.insert_notificacion() OWNER TO gaj_owner;

--
-- Name: insert_oficio(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_oficio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
    DECLARE
    	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
        SEQ_NAME varchar := 'com_oficio_numero_' || YEAR_NOW || '_seq';
        _kind char 		 := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
        sql_seq text := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
	BEGIN
		      
        --raise notice 'Ejecutando oficio: %', NEW.id;
		--raise notice 'YEAR: %', YEAR_NOW;
        --raise notice 'Verificando si existe la secuencia';

		IF _kind IS NULL THEN
        	
            -- creo la sequence para el año actual
            --raise notice 'Secuencia no existe, creando...';
            
            EXECUTE sql_seq;

            --raise notice 'secuencia del año % creada', YEAR_NOW;
        
        END IF;
									
		NEW.numero := CAST ( (CAST (nextval(SEQ_NAME) as varchar) || substring(YEAR_NOW from 3 for 4) ) as integer);
        
        --raise notice 'Nro Oficio: %', NEW.numero;
        --raise notice 'Fin:';
	
    	RETURN NEW;
        
	END;
	$$;


ALTER FUNCTION sch_gaj.insert_oficio() OWNER TO gaj_owner;

--
-- Name: insert_pad_vehiculo_hist(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_pad_vehiculo_hist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 INSERT INTO pad_vehiculo_hist (creation_timestamp, 
				creation_user, deleted, 
				modification_timestamp, 
				modification_user, version_number, 
				color, marca, modelo, nro_chasis, 
				nro_motor, patente, 
				patente_ficticia_migracion, 
				tiene_patente, usuario_operacion, 
				tipo_vehiculo_id, vehiculo_id)

 	VALUES(OLD.creation_timestamp, 
			OLD.creation_user, 
			OLD.deleted, 
			OLD.modification_timestamp, 
			OLD.modification_user, 
			OLD.version_number, 
			OLD.color, 
			OLD.marca, 
			OLD.modelo, 
			OLD.nro_chasis, 
			OLD.nro_motor, 
			OLD.patente, 
			OLD.patente_ficticia_migracion, 
			OLD.tiene_patente, 
			OLD.usuario_operacion, 
			OLD.tipo_vehiculo_id,
			OLD.id);
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION sch_gaj.insert_pad_vehiculo_hist() OWNER TO gaj_owner;

--
-- Name: insert_sentencia(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_sentencia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
DECLARE
	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
    COD_JUEZ varchar;
    SEQ_NAME varchar;
    _kind char;
    sql_seq text;
BEGIN
    
	COD_JUEZ := NEW.cod_juez;
    SEQ_NAME := 'juz_sentencia_numero_' || COD_JUEZ || YEAR_NOW || '_seq';
    _kind := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
    sql_seq := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
   
    raise notice 'Ejecutando sentencia: %', NEW.id;
    raise notice 'COD_JUEZ: %', COD_JUEZ;
	raise notice 'YEAR: %', YEAR_NOW;
	raise notice 'SEQ: %', SEQ_NAME;
    raise notice 'Verificando si existe la secuencia';
	
   	IF NEW.estado_sentencia = 1 AND NEW.instancia < 3 THEN
		IF _kind IS NULL THEN
	    	
	        -- creo la sequence para el año actual y el juez
	        raise notice 'Secuencia no existe, creando...';
	        
	        EXECUTE sql_seq;
	
	        raise notice 'secuencia del año % creada', YEAR_NOW;
	    
	    END IF;
									
		NEW.nro_sentencia := CAST ( (CAST (nextval(SEQ_NAME) as varchar) ) as integer);
		NEW.anio_sentencia := CAST ( substring(YEAR_NOW from 3 for 4) as integer);
	    
	    raise notice 'Nro sentencia: %', NEW.nro_sentencia;
	    raise notice 'Fin:';	
	END IF;

    RETURN NEW;	
END;
$$;


ALTER FUNCTION sch_gaj.insert_sentencia() OWNER TO gaj_owner;

--
-- Name: insert_traslado(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_traslado() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
    DECLARE
    	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
        SEQ_NAME varchar := 'cor_traslado_nro_traslado_' || YEAR_NOW || '_seq';
        _kind char 		 := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
        sql_seq text := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
	BEGIN
		      
        --raise notice 'YEAR: %', YEAR_NOW;
        --raise notice 'Verificando si existe la secuencia';

		IF _kind IS NULL THEN
        	
            -- creo la sequence para el año actual
            --raise notice 'Secuencia no existe, creando...';
            
            EXECUTE sql_seq;

            --raise notice 'secuencia del año % creada', YEAR_NOW;
        
        END IF;
									
		NEW.nro_traslado := CAST ( (CAST (nextval(SEQ_NAME) as varchar) || substring(YEAR_NOW from 3 for 4) ) as integer);
        
        --raise notice 'Nro traslado: %', NEW.nro_traslado;
        --raise notice 'Fin:';
	
    	RETURN NEW;
        
	END;
	$$;


ALTER FUNCTION sch_gaj.insert_traslado() OWNER TO gaj_owner;

--
-- Name: insert_verificaciontecnica(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.insert_verificaciontecnica() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
    DECLARE
    	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
        SEQ_NAME varchar := 'cor_verificaciontecnica_numero_' || YEAR_NOW || '_seq';
        _kind char 		 := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
        sql_seq text := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
	BEGIN
		      
        --raise notice 'YEAR: %', YEAR_NOW;
        --raise notice 'Verificando si existe la secuencia';

		IF _kind IS NULL THEN
        	
            -- creo la sequence para el año actual
            --raise notice 'Secuencia no existe, creando...';
            
            EXECUTE sql_seq;

            --raise notice 'secuencia del año % creada', YEAR_NOW;
        
        END IF;
									
		NEW.numero := CAST ( (CAST (nextval(SEQ_NAME) as varchar) || substring(YEAR_NOW from 3 for 4) ) as integer);
        
        --raise notice 'Nro verificacion: %', NEW.numero;
        --raise notice 'Fin:';
	
    	RETURN NEW;
        
	END;
	$$;


ALTER FUNCTION sch_gaj.insert_verificaciontecnica() OWNER TO gaj_owner;

--
-- Name: populate_agente_reparticion_table(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.populate_agente_reparticion_table() RETURNS void
    LANGUAGE plpgsql
    AS $$ DECLARE
      temprecord RECORD;
      codigo_agente_param INT;
      default_codigo_agente INT := 9901;
   BEGIN
	FOR temprecord IN SELECT id, reparticion_id, codigo_agente FROM pad_agente
	LOOP
		codigo_agente_param := temprecord.codigo_agente;
		CASE WHEN codigo_agente_param IS NULL THEN
			codigo_agente_param := default_codigo_agente;
			default_codigo_agente := default_codigo_agente + 1;
		ELSE
		END CASE;
		
		INSERT INTO pad_agente_reparticion(creation_timestamp,creation_user,deleted,modification_timestamp,modification_user,version_number,agente_id,reparticion_id,codigo_agente) 
		VALUES ('2018-04-26 13:24:24.290', 'admin', false, '2018-04-26 13:24:24.290', 'admin', 0, temprecord.id, temprecord.reparticion_id, codigo_agente_param);
	END LOOP;
   END;$$;


ALTER FUNCTION sch_gaj.populate_agente_reparticion_table() OWNER TO gaj_owner;

--
-- Name: populate_clave_objeto(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.populate_clave_objeto() RETURNS void
    LANGUAGE plpgsql
    AS $$ DECLARE
	temp_record RECORD;
	clave_encontrada VARCHAR;

BEGIN
	FOR temp_record IN SELECT obj.id, obj.valores, obj.tipo_id, tipo_obj.codigo FROM com_detalle_objeto obj INNER JOIN com_tipo_objeto tipo_obj on obj.tipo_id=tipo_obj.id
	LOOP
		CASE WHEN temp_record.codigo = 'VEHICULO' THEN
				clave_encontrada := temp_record.valores::json->>'DOMINIO';
		WHEN temp_record.codigo = 'COMERCIO' THEN
				clave_encontrada := temp_record.valores::json->>'NUMERO';
		WHEN temp_record.codigo = 'PARCELA' THEN
				clave_encontrada := temp_record.valores::json->>'CATASTRAL';
		ELSE
		END CASE;
		UPDATE com_detalle_objeto SET clave = clave_encontrada WHERE id = temp_record.id;
	END LOOP;
END;$$;


ALTER FUNCTION sch_gaj.populate_clave_objeto() OWNER TO gaj_owner;

--
-- Name: update_cla_detalle_clausura_hist(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.update_cla_detalle_clausura_hist() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
 INSERT INTO cla_detalle_clausura_hist (creation_timestamp, 
				creation_user, deleted, 
				modification_timestamp, 
				modification_user, version_number, 
				numero_faja, numero_precinto,
				motivo, oficio_id,
				duracion, fecha_vencimiento,
				clausura_id, verificar_levantamiento)

 	VALUES(OLD.creation_timestamp, 
			OLD.creation_user, 
			OLD.deleted, 
			OLD.modification_timestamp, 
			OLD.modification_user, 
			OLD.version_number, 
			OLD.numero_faja, 
			OLD.numero_precinto, 
			OLD.motivo, 
			OLD.oficio_id, 
			OLD.duracion, 
			OLD.fecha_vencimiento, 
			OLD.clausura_id, 
			OLD.verificar_levantamiento);
 
 RETURN NEW;
END;
$$;


ALTER FUNCTION sch_gaj.update_cla_detalle_clausura_hist() OWNER TO gaj_owner;

--
-- Name: update_sentencia(); Type: FUNCTION; Schema: sch_gaj; Owner: gaj_owner
--

CREATE FUNCTION sch_gaj.update_sentencia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    
DECLARE
	YEAR_NOW varchar := EXTRACT(YEAR FROM now())::varchar;	
    COD_JUEZ varchar;
    SEQ_NAME varchar;
    _kind char;
    sql_seq text;
BEGIN
    
	COD_JUEZ := NEW.cod_juez;
    SEQ_NAME := 'juz_sentencia_numero_' || COD_JUEZ || YEAR_NOW || '_seq';
    _kind := (SELECT relkind FROM pg_class where relname = SEQ_NAME);
    sql_seq := 'CREATE SEQUENCE ' || SEQ_NAME ||' START 1;';
   
    raise notice 'Ejecutando sentencia: %', NEW.id;
    raise notice 'COD_JUEZ: %', COD_JUEZ;
	raise notice 'YEAR: %', YEAR_NOW;
	raise notice 'SEQ: %', SEQ_NAME;
    raise notice 'Verificando si existe la secuencia';

    IF NEW.estado_sentencia = 1 AND OLD.nro_sentencia IS NULL AND NEW.instancia < 3 THEN
		IF _kind IS NULL THEN
	    	
	        -- creo la sequence para el año actual y el juez
	        raise notice 'Secuencia no existe, creando...';
	        
	        EXECUTE sql_seq;
	
	        raise notice 'secuencia del año % creada', YEAR_NOW;
	    
	    END IF;
									
		NEW.nro_sentencia := CAST ( (CAST (nextval(SEQ_NAME) as varchar) ) as integer);
		NEW.anio_sentencia := CAST ( substring(YEAR_NOW from 3 for 4) as integer);
	    
	    raise notice 'Nro sentencia: %', NEW.nro_sentencia;
	    raise notice 'Fin:';
   	END IF;

	RETURN NEW;
    
END;
$$;


ALTER FUNCTION sch_gaj.update_sentencia() OWNER TO gaj_owner;

SET default_tablespace = '';

--
-- Name: cla_clausura; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_clausura (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero bigint NOT NULL,
    tipo_clausura character varying(30) NOT NULL,
    estado character varying(20) NOT NULL,
    fecha_inicio timestamp without time zone,
    domicilio_id bigint,
    nro_comercio character varying(10),
    posee_desprecintamiento boolean NOT NULL,
    marca_revision character varying(50)
);


ALTER TABLE sch_gaj.cla_clausura OWNER TO gaj_owner;

--
-- Name: cla_clausura_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_clausura_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    orden integer NOT NULL,
    tipo character varying(30) NOT NULL,
    acta_id bigint NOT NULL,
    clausura_id bigint NOT NULL
);


ALTER TABLE sch_gaj.cla_clausura_acta OWNER TO gaj_owner;

--
-- Name: cla_clausura_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_acta_id_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_clausura_acta_id_seq OWNED BY sch_gaj.cla_clausura_acta.id;


--
-- Name: cla_clausura_definitiva; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_clausura_definitiva (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    oficio_id bigint,
    tiene_oficio boolean NOT NULL,
    clausura_id bigint NOT NULL
);


ALTER TABLE sch_gaj.cla_clausura_definitiva OWNER TO gaj_owner;

--
-- Name: cla_clausura_definitiva_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_definitiva_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_definitiva_id_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_definitiva_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_clausura_definitiva_id_seq OWNED BY sch_gaj.cla_clausura_definitiva.id;


--
-- Name: cla_clausura_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_id_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_clausura_id_seq OWNED BY sch_gaj.cla_clausura.id;


--
-- Name: cla_clausura_numero_2000_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2000_seq
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2000_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2003_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2003_seq
    START WITH 3
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2003_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2004_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2004_seq
    START WITH 79
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2004_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2005_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2005_seq
    START WITH 723
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2005_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2006_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2006_seq
    START WITH 499
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2006_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2007_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2007_seq
    START WITH 530
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2007_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2008_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2008_seq
    START WITH 421
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2008_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2009_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2009_seq
    START WITH 330
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2009_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2010_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2010_seq
    START WITH 461
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2010_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2011_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2011_seq
    START WITH 690
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2011_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2012_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2012_seq
    START WITH 435
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2012_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2013_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2013_seq
    START WITH 924
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2013_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2014_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2014_seq
    START WITH 567
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2014_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2015_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2015_seq
    START WITH 644
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2015_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2016_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2016_seq
    START WITH 870
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2016_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2017_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2017_seq
    START WITH 860
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2017_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2018_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2018_seq
    START WITH 367
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2018_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2019_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2019_seq
    START WITH 67
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2019_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_numero_2020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_numero_2020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_numero_2020_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_status; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_clausura_status (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone,
    estado character varying(20),
    tipo character varying(30),
    nota character varying(255),
    clausura_id bigint NOT NULL
);


ALTER TABLE sch_gaj.cla_clausura_status OWNER TO gaj_owner;

--
-- Name: cla_clausura_status_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_clausura_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_clausura_status_id_seq OWNER TO gaj_owner;

--
-- Name: cla_clausura_status_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_clausura_status_id_seq OWNED BY sch_gaj.cla_clausura_status.id;


--
-- Name: cla_detalle_clausura; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_detalle_clausura (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero_faja integer,
    numero_precinto integer,
    motivo character varying(255),
    oficio_id bigint,
    duracion integer,
    fecha_vencimiento timestamp without time zone,
    clausura_id bigint NOT NULL,
    verificar_levantamiento boolean,
    oficio_desprecintamiento_id bigint
);


ALTER TABLE sch_gaj.cla_detalle_clausura OWNER TO gaj_owner;

--
-- Name: cla_detalle_clausura_hist; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_detalle_clausura_hist (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero_faja integer,
    numero_precinto integer,
    motivo character varying(255),
    oficio_id bigint,
    duracion integer,
    fecha_vencimiento timestamp without time zone,
    clausura_id bigint NOT NULL,
    verificar_levantamiento boolean
);


ALTER TABLE sch_gaj.cla_detalle_clausura_hist OWNER TO gaj_owner;

--
-- Name: cla_detalle_clausura_hist_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_detalle_clausura_hist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_detalle_clausura_hist_id_seq OWNER TO gaj_owner;

--
-- Name: cla_detalle_clausura_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_detalle_clausura_hist_id_seq OWNED BY sch_gaj.cla_detalle_clausura_hist.id;


--
-- Name: cla_detalle_clausura_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_detalle_clausura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_detalle_clausura_id_seq OWNER TO gaj_owner;

--
-- Name: cla_detalle_clausura_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_detalle_clausura_id_seq OWNED BY sch_gaj.cla_detalle_clausura.id;


--
-- Name: cla_levantamiento_clausura; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_levantamiento_clausura (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    permiso character varying(20),
    libre_multa character varying(20),
    oficio_habilitacion character varying(10),
    necesita_confirmacion boolean,
    oficio_id bigint,
    clausura_id bigint NOT NULL,
    nota character varying(255),
    fecha_confirmacion timestamp without time zone,
    nota_confirmacion character varying(255)
);


ALTER TABLE sch_gaj.cla_levantamiento_clausura OWNER TO gaj_owner;

--
-- Name: cla_levantamiento_clausura_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_levantamiento_clausura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_levantamiento_clausura_id_seq OWNER TO gaj_owner;

--
-- Name: cla_levantamiento_clausura_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_levantamiento_clausura_id_seq OWNED BY sch_gaj.cla_levantamiento_clausura.id;


--
-- Name: cla_oficio_desprecintamiento; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_oficio_desprecintamiento (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone,
    notas character varying(255),
    oficio_id bigint
);


ALTER TABLE sch_gaj.cla_oficio_desprecintamiento OWNER TO gaj_owner;

--
-- Name: cla_oficio_desprecintamiento_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_oficio_desprecintamiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_oficio_desprecintamiento_id_seq OWNER TO gaj_owner;

--
-- Name: cla_oficio_desprecintamiento_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_oficio_desprecintamiento_id_seq OWNED BY sch_gaj.cla_oficio_desprecintamiento.id;


--
-- Name: cla_reanudacion_clausura; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_reanudacion_clausura (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    oficio_id bigint NOT NULL,
    duracion integer,
    fecha_vencimiento timestamp without time zone,
    clausura_id bigint NOT NULL
);


ALTER TABLE sch_gaj.cla_reanudacion_clausura OWNER TO gaj_owner;

--
-- Name: cla_reanudacion_clausura_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_reanudacion_clausura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_reanudacion_clausura_id_seq OWNER TO gaj_owner;

--
-- Name: cla_reanudacion_clausura_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_reanudacion_clausura_id_seq OWNED BY sch_gaj.cla_reanudacion_clausura.id;


--
-- Name: cla_suspencion_clausura; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cla_suspencion_clausura (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    oficio_id bigint NOT NULL,
    dias_restantes integer,
    clausura_id bigint NOT NULL
);


ALTER TABLE sch_gaj.cla_suspencion_clausura OWNER TO gaj_owner;

--
-- Name: cla_suspencion_clausura_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cla_suspencion_clausura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cla_suspencion_clausura_id_seq OWNER TO gaj_owner;

--
-- Name: cla_suspencion_clausura_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cla_suspencion_clausura_id_seq OWNED BY sch_gaj.cla_suspencion_clausura.id;


--
-- Name: com_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_acta timestamp without time zone,
    fecha_alta timestamp without time zone,
    numero bigint,
    serie character varying(2),
    agente_id bigint,
    inventario_id bigint,
    tipo_acta_id bigint,
    observaciones character varying(2000),
    infractor_id bigint,
    objetos_secuestrados character varying(255),
    lugar_acta_id bigint,
    codigo_motivo_estado character varying(50),
    estado_envio_acta_tmf integer,
    mensaje_envio_acta_tmf character varying(500),
    codigo_envio_acta_tmf character varying(50),
    reparticion_id bigint,
    existe_remision boolean,
    retiene_licencia boolean,
    estado_acta_id bigint,
    proposito_acta_id bigint,
    domicilio_declarado_id bigint,
    es_intimacion boolean,
    firma_digital character varying(500),
    estado_acta_notificacion integer,
    zona_notificacion_id bigint,
    apta_proceso_masivo_rebeldia boolean,
    seccion character varying(30),
    manzana character varying(30)
);


ALTER TABLE sch_gaj.com_acta OWNER TO gaj_owner;

--
-- Name: com_acta_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    fecha_acta timestamp without time zone,
    fecha_alta timestamp without time zone,
    numero bigint,
    serie character varying(2),
    agente_id bigint,
    inventario_id bigint,
    tipo_acta_id bigint,
    observaciones character varying(2000),
    infractor_id bigint,
    objetos_secuestrados character varying(255),
    lugar_acta_id bigint,
    domicilio_declarado_id bigint,
    estado_acta_notificacion integer,
    codigo_motivo_estado character varying(50),
    estado_envio_acta_tmf integer,
    mensaje_envio_acta_tmf character varying(500),
    codigo_envio_acta_tmf character varying(50),
    existe_remision boolean,
    retiene_licencia boolean,
    estado_acta_id bigint,
    proposito_acta_id bigint,
    es_intimacion boolean,
    reparticion_id bigint,
    zona_notificacion_id bigint,
    firma_digital character varying(500),
    seccion character varying(30),
    manzana character varying(30)
);


ALTER TABLE sch_gaj.com_acta_audit OWNER TO gaj_owner;

--
-- Name: com_acta_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    fecha_acta timestamp without time zone,
    fecha_alta timestamp without time zone,
    numero bigint,
    serie character varying(2),
    agente_id bigint,
    inventario_id bigint,
    tipo_acta_id bigint,
    observaciones character varying(2000),
    infractor_id bigint,
    objetos_secuestrados character varying(255),
    lugar_acta_id bigint,
    codigo_motivo_estado character varying(50),
    estado_envio_acta_tmf integer,
    mensaje_envio_acta_tmf character varying(500),
    codigo_envio_acta_tmf character varying(50),
    reparticion_id bigint,
    existe_remision boolean,
    retiene_licencia boolean,
    estado_acta_id bigint,
    proposito_acta_id bigint,
    domicilio_declarado_id bigint,
    es_intimacion boolean,
    firma_digital character varying(500),
    estado_acta_notificacion integer,
    zona_notificacion_id bigint,
    apta_proceso_masivo_rebeldia boolean,
    seccion character varying(30),
    manzana character varying(30)
);


ALTER TABLE sch_gaj.com_acta_backup OWNER TO gaj_owner;

--
-- Name: com_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_acta_id_seq OWNER TO gaj_owner;

--
-- Name: com_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_acta_id_seq OWNED BY sch_gaj.com_acta.id;


--
-- Name: com_acta_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    acta_id bigint NOT NULL,
    infraccion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.com_acta_infraccion OWNER TO gaj_owner;

--
-- Name: com_acta_infraccion_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta_infraccion_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    acta_id bigint,
    infraccion_id bigint
);


ALTER TABLE sch_gaj.com_acta_infraccion_audit OWNER TO gaj_owner;

--
-- Name: com_acta_infraccion_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta_infraccion_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    acta_id bigint,
    infraccion_id bigint
);


ALTER TABLE sch_gaj.com_acta_infraccion_backup OWNER TO gaj_owner;

--
-- Name: com_acta_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_acta_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_acta_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: com_acta_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_acta_infraccion_id_seq OWNED BY sch_gaj.com_acta_infraccion.id;


--
-- Name: com_acta_inspeccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta_inspeccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    rubro_desar character varying(150),
    obs_com character varying(150),
    nro_higiene integer,
    sup_estimada integer,
    drei boolean,
    botiquin boolean,
    matafuego integer,
    vto_mataf timestamp without time zone,
    carteles boolean,
    permiso_cartel boolean,
    nro_comprob integer,
    desc_infrac character varying(150),
    clausura boolean,
    fecha_claus timestamp without time zone
);


ALTER TABLE sch_gaj.com_acta_inspeccion OWNER TO gaj_owner;

--
-- Name: com_acta_inspeccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_acta_inspeccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_acta_inspeccion_id_seq OWNER TO gaj_owner;

--
-- Name: com_acta_inspeccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_acta_inspeccion_id_seq OWNED BY sch_gaj.com_acta_inspeccion.id;


--
-- Name: com_acta_recepcion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_acta_recepcion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    json_acta_recibida jsonb,
    acta_id bigint NOT NULL,
    estado_transicion character varying(50)
);


ALTER TABLE sch_gaj.com_acta_recepcion OWNER TO gaj_owner;

--
-- Name: com_acta_recepcion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_acta_recepcion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_acta_recepcion_id_seq OWNER TO gaj_owner;

--
-- Name: com_acta_recepcion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_acta_recepcion_id_seq OWNED BY sch_gaj.com_acta_recepcion.id;


--
-- Name: com_actaimagen; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_actaimagen (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    acta_id bigint NOT NULL,
    imagen_id bigint NOT NULL
);


ALTER TABLE sch_gaj.com_actaimagen OWNER TO gaj_owner;

--
-- Name: com_actaimagen_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_actaimagen_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    acta_id bigint,
    imagen_id bigint
);


ALTER TABLE sch_gaj.com_actaimagen_audit OWNER TO gaj_owner;

--
-- Name: com_actaimagen_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_actaimagen_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    acta_id bigint,
    imagen_id bigint
);


ALTER TABLE sch_gaj.com_actaimagen_backup OWNER TO gaj_owner;

--
-- Name: com_actaimagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_actaimagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_actaimagen_id_seq OWNER TO gaj_owner;

--
-- Name: com_actaimagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_actaimagen_id_seq OWNED BY sch_gaj.com_actaimagen.id;


--
-- Name: com_actatransitoprovisoria; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_actatransitoprovisoria (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    apellido character varying(100),
    cod_postal character varying(100),
    codigo_vehiculo character varying(4),
    color_vehiculo character varying(50),
    cuit character varying(20),
    detalle_inspector character varying(100),
    documento character varying(100),
    domicilio character varying(100),
    marca_vehiculo character varying(20),
    nombre character varying(100),
    nro_motor character varying(20),
    nro_planilla character varying(100),
    patente character varying(10),
    remitido character varying(1),
    tipo_vehiculo character varying(50),
    acta_id bigint NOT NULL,
    fecha_acta timestamp without time zone,
    fecha_alta timestamp without time zone,
    numero bigint,
    serie character varying(2),
    agente_id bigint,
    inventario_id bigint,
    tipo_acta_id bigint
);


ALTER TABLE sch_gaj.com_actatransitoprovisoria OWNER TO gaj_owner;

--
-- Name: com_actatransitoprovisoria_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_actatransitoprovisoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_actatransitoprovisoria_id_seq OWNER TO gaj_owner;

--
-- Name: com_actatransitoprovisoria_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_actatransitoprovisoria_id_seq OWNED BY sch_gaj.com_actatransitoprovisoria.id;


--
-- Name: com_audiencia_imagen; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_audiencia_imagen (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    imagen_id bigint NOT NULL,
    audiencia_id bigint NOT NULL
);


ALTER TABLE sch_gaj.com_audiencia_imagen OWNER TO gaj_owner;

--
-- Name: com_audiencia_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_audiencia_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_audiencia_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: com_audiencia_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_audiencia_imagen_id_seq OWNED BY sch_gaj.com_audiencia_imagen.id;


--
-- Name: com_background_run; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_background_run (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    corrida_id bigint,
    background_task_id bigint NOT NULL,
    input_value jsonb NOT NULL,
    response jsonb
);


ALTER TABLE sch_gaj.com_background_run OWNER TO gaj_owner;

--
-- Name: com_background_run_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_background_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_background_run_id_seq OWNER TO gaj_owner;

--
-- Name: com_background_run_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_background_run_id_seq OWNED BY sch_gaj.com_background_run.id;


--
-- Name: com_background_task; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_background_task (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(30) NOT NULL,
    descripcion character varying(100) NOT NULL,
    class_name character varying(200) NOT NULL,
    method_name character varying(200) NOT NULL,
    swe_action character varying(25),
    swe_method character varying(25)
);


ALTER TABLE sch_gaj.com_background_task OWNER TO gaj_owner;

--
-- Name: com_background_task_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_background_task_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_background_task_id_seq OWNER TO gaj_owner;

--
-- Name: com_background_task_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_background_task_id_seq OWNED BY sch_gaj.com_background_task.id;


--
-- Name: com_detalle_objeto; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_detalle_objeto (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tipo_id bigint NOT NULL,
    valores jsonb,
    detalles jsonb,
    acta_id bigint NOT NULL,
    domicilio_id bigint,
    observaciones character varying(500),
    clave character varying(500),
    clave_secundaria character varying(500),
    entidad_id bigint
);


ALTER TABLE sch_gaj.com_detalle_objeto OWNER TO gaj_owner;

--
-- Name: com_detalle_objeto_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_detalle_objeto_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    tipo_id bigint,
    valores jsonb,
    detalles jsonb,
    acta_id bigint,
    domicilio_id bigint,
    observaciones character varying(500),
    clave character varying(500),
    clave_secundaria character varying(500),
    entidad_id bigint
);


ALTER TABLE sch_gaj.com_detalle_objeto_audit OWNER TO gaj_owner;

--
-- Name: com_detalle_objeto_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_detalle_objeto_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    tipo_id bigint,
    valores jsonb,
    detalles jsonb,
    acta_id bigint,
    domicilio_id bigint,
    observaciones character varying(500),
    clave character varying(500),
    clave_secundaria character varying(500),
    entidad_id bigint
);


ALTER TABLE sch_gaj.com_detalle_objeto_backup OWNER TO gaj_owner;

--
-- Name: com_detalle_objeto_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_detalle_objeto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_detalle_objeto_id_seq OWNER TO gaj_owner;

--
-- Name: com_detalle_objeto_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_detalle_objeto_id_seq OWNED BY sch_gaj.com_detalle_objeto.id;


--
-- Name: com_detalle_oficio; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_detalle_oficio (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    parrafo1 character varying(255),
    parrafo2 character varying(255),
    parrafo3 character varying(255)
);


ALTER TABLE sch_gaj.com_detalle_oficio OWNER TO gaj_owner;

--
-- Name: com_detalle_oficio_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_detalle_oficio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_detalle_oficio_id_seq OWNER TO gaj_owner;

--
-- Name: com_detalle_oficio_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_detalle_oficio_id_seq OWNED BY sch_gaj.com_detalle_oficio.id;


--
-- Name: com_detalle_pena_clausura; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_detalle_pena_clausura (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    dias_clausura integer NOT NULL
);


ALTER TABLE sch_gaj.com_detalle_pena_clausura OWNER TO gaj_owner;

--
-- Name: com_detalle_pena_clausura_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_detalle_pena_clausura_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_detalle_pena_clausura_id_seq OWNER TO gaj_owner;

--
-- Name: com_detalle_pena_clausura_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_detalle_pena_clausura_id_seq OWNED BY sch_gaj.com_detalle_pena_clausura.id;


--
-- Name: com_domicilio; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_domicilio (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    id_calle bigint,
    id_calle_int bigint,
    nombre_calle character varying(50),
    altura bigint,
    letra_calle character varying(5),
    monoblock character varying(16),
    piso bigint,
    depto character varying(16),
    bis boolean,
    cod_postal bigint,
    sub_postal bigint,
    id_provincia character varying(30),
    id_pais bigint,
    ref_geografica character varying(255),
    letra_altura character varying(5),
    oficina_local character varying(60),
    str_domicilio character varying(500),
    nombre_calle_int character varying(50),
    punto_id bigint
);


ALTER TABLE sch_gaj.com_domicilio OWNER TO gaj_owner;

--
-- Name: com_domicilio_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_domicilio_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    id_calle bigint,
    id_calle_int bigint,
    nombre_calle character varying(50),
    altura bigint,
    letra_calle character varying(5),
    monoblock character varying(16),
    piso bigint,
    depto character varying(16),
    bis boolean,
    cod_postal bigint,
    sub_postal bigint,
    id_provincia character varying(30),
    id_pais bigint,
    ref_geografica character varying(255),
    letra_altura character varying(5),
    oficina_local character varying(60),
    str_domicilio character varying(500),
    nombre_calle_int character varying(50),
    punto_id bigint
);


ALTER TABLE sch_gaj.com_domicilio_backup OWNER TO gaj_owner;

--
-- Name: com_domicilio_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_domicilio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_domicilio_id_seq OWNER TO gaj_owner;

--
-- Name: com_domicilio_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_domicilio_id_seq OWNED BY sch_gaj.com_domicilio.id;


--
-- Name: com_estado_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_estado_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(250),
    codigo character varying(50)
);


ALTER TABLE sch_gaj.com_estado_acta OWNER TO gaj_owner;

--
-- Name: com_estado_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_estado_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_estado_acta_id_seq OWNER TO gaj_owner;

--
-- Name: com_estado_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_estado_acta_id_seq OWNED BY sch_gaj.com_estado_acta.id;


--
-- Name: com_imagen; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_imagen (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    id_imagen character varying(250) NOT NULL,
    ubicacion_online character varying(250),
    ubicacion_offline character varying(250),
    tipo_imagen_id bigint NOT NULL,
    tipo_repositorio character varying(10) NOT NULL,
    year_bucket integer,
    image_name character varying(100)
);


ALTER TABLE sch_gaj.com_imagen OWNER TO gaj_owner;

--
-- Name: com_imagen_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_imagen_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    fecha_hora timestamp without time zone,
    id_imagen character varying(250),
    ubicacion_online character varying(250),
    ubicacion_offline character varying(250),
    tipo_imagen_id bigint,
    tipo_repositorio character varying(10),
    year_bucket integer,
    image_name character varying(100)
);


ALTER TABLE sch_gaj.com_imagen_backup OWNER TO gaj_owner;

--
-- Name: com_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: com_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_imagen_id_seq OWNED BY sch_gaj.com_imagen.id;


--
-- Name: com_imagen_vieja; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_imagen_vieja (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    id_imagen character varying(250) NOT NULL,
    ubicacion_online character varying(250),
    ubicacion_offline character varying(250),
    tipo_imagen_id bigint NOT NULL,
    tipo_repositorio character varying(10) NOT NULL,
    year_bucket integer,
    image_name character varying(100)
);


ALTER TABLE sch_gaj.com_imagen_vieja OWNER TO gaj_owner;

--
-- Name: com_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(255) NOT NULL,
    nivel character varying(10) NOT NULL,
    breve_descripcion character varying(255),
    cod1 character varying(3) NOT NULL,
    cod2 character varying(2) NOT NULL,
    cod3 character varying(2) NOT NULL,
    cod4 character varying(3),
    subespecie_infraccion_id bigint DEFAULT 0,
    normativa_infraccion_id bigint DEFAULT 0 NOT NULL,
    requiere_dictamen_fiscal boolean DEFAULT false NOT NULL,
    fecha_desde timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    fecha_hasta timestamp without time zone,
    causal_infraccion_id bigint,
    infraccion_relacionada_id bigint,
    concepto_infraccion_id bigint,
    tiempo_rebeldia integer,
    unidad_tiempo_rebeldia integer
);


ALTER TABLE sch_gaj.com_infraccion OWNER TO gaj_owner;

--
-- Name: com_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: com_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_infraccion_id_seq OWNED BY sch_gaj.com_infraccion.id;


--
-- Name: com_infraccionprovisoria; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_infraccionprovisoria (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    cod_infraccion character varying(11),
    descripcion character varying(250),
    acta_transito_provisoria_id bigint
);


ALTER TABLE sch_gaj.com_infraccionprovisoria OWNER TO gaj_owner;

--
-- Name: com_infraccionprovisoria_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_infraccionprovisoria_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_infraccionprovisoria_id_seq OWNER TO gaj_owner;

--
-- Name: com_infraccionprovisoria_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_infraccionprovisoria_id_seq OWNED BY sch_gaj.com_infraccionprovisoria.id;


--
-- Name: com_libera_numero_liberacion_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_libera_numero_liberacion_seq
    START WITH 2019
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_libera_numero_liberacion_seq OWNER TO gaj_owner;

--
-- Name: com_libera_requisito; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_libera_requisito (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    liberacion_id bigint,
    requisito_lib_veh_id bigint,
    imagen_id bigint,
    estado boolean,
    notas character varying(300)
);


ALTER TABLE sch_gaj.com_libera_requisito OWNER TO gaj_owner;

--
-- Name: com_libera_requisito_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_libera_requisito_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_libera_requisito_id_seq OWNER TO gaj_owner;

--
-- Name: com_libera_requisito_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_libera_requisito_id_seq OWNED BY sch_gaj.com_libera_requisito.id;


--
-- Name: com_liberacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_liberacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora timestamp without time zone,
    juez_migracion character varying(30),
    nro_liberacion bigint,
    patente_migracion character varying(10),
    juez_id bigint,
    tipo_destino_id bigint,
    persona_libera_id bigint,
    inventario_id bigint,
    notas character varying(300),
    comprobante character varying(20) DEFAULT NULL::character varying,
    forma_egreso character varying(20) DEFAULT NULL::character varying
);


ALTER TABLE sch_gaj.com_liberacion OWNER TO gaj_owner;

--
-- Name: com_liberacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_liberacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_liberacion_id_seq OWNER TO gaj_owner;

--
-- Name: com_liberacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_liberacion_id_seq OWNED BY sch_gaj.com_liberacion.id;


--
-- Name: com_lote; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_lote (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    directorio_trabajo character varying(255),
    nombre character varying(255),
    fecha timestamp without time zone,
    cantidad_lineas bigint,
    usuario character varying(255),
    estado character varying(15),
    id_corrida bigint NOT NULL
);


ALTER TABLE sch_gaj.com_lote OWNER TO gaj_owner;

--
-- Name: com_lote_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_lote_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_lote_id_seq OWNER TO gaj_owner;

--
-- Name: com_lote_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_lote_id_seq OWNED BY sch_gaj.com_lote.id;


--
-- Name: com_loteitem; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_loteitem (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    archivo_img character varying(255),
    estado character varying(15),
    codigo_error character varying(128),
    fecha timestamp without time zone,
    id_tipo_doc character varying(30),
    nro_cedula character varying(30),
    tipo_acta integer,
    numero_acta bigint,
    serie_acta character varying(30),
    detalle text,
    lote_id bigint
);


ALTER TABLE sch_gaj.com_loteitem OWNER TO gaj_owner;

--
-- Name: com_loteitem_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_loteitem_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_loteitem_id_seq OWNER TO gaj_owner;

--
-- Name: com_loteitem_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_loteitem_id_seq OWNED BY sch_gaj.com_loteitem.id;


--
-- Name: com_oficio; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_oficio (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero bigint NOT NULL,
    tipo_oficio_id bigint NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    juez_id bigint NOT NULL,
    destino character varying(150),
    observaciones character varying(255),
    acta_id bigint,
    clausura_id bigint,
    detalle_id bigint,
    detalle_clausura_id bigint,
    estado character varying(10) NOT NULL,
    nro_migracion integer,
    anio_migracion integer,
    utilizado boolean
);


ALTER TABLE sch_gaj.com_oficio OWNER TO gaj_owner;

--
-- Name: com_oficio_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_id_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_oficio_id_seq OWNED BY sch_gaj.com_oficio.id;


--
-- Name: com_oficio_numero_19_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_19_seq
    START WITH 14
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_19_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2003_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2003_seq
    START WITH 4
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2003_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2004_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2004_seq
    START WITH 8
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2004_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2005_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2005_seq
    START WITH 2906
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2005_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2006_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2006_seq
    START WITH 200107
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2006_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2007_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2007_seq
    START WITH 12275
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2007_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2008_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2008_seq
    START WITH 1080
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2008_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2009_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2009_seq
    START WITH 6420
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2009_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2010_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2010_seq
    START WITH 1490
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2010_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2011_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2011_seq
    START WITH 31120
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2011_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2012_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2012_seq
    START WITH 2087
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2012_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2013_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2013_seq
    START WITH 3250
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2013_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2014_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2014_seq
    START WITH 5920
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2014_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2015_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2015_seq
    START WITH 2937
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2015_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2016_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2016_seq
    START WITH 17120
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2016_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2017_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2017_seq
    START WITH 5518
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2017_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2018_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2018_seq
    START WITH 3913
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2018_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2019_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2019_seq
    START WITH 3947
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2019_seq OWNER TO gaj_owner;

--
-- Name: com_oficio_numero_2020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_oficio_numero_2020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_oficio_numero_2020_seq OWNER TO gaj_owner;

--
-- Name: com_presunto_infractor; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_presunto_infractor (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    acta_id bigint NOT NULL,
    persona_id bigint NOT NULL,
    es_principal boolean NOT NULL
);


ALTER TABLE sch_gaj.com_presunto_infractor OWNER TO gaj_owner;

--
-- Name: com_presunto_infractor_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_presunto_infractor_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    acta_id bigint,
    persona_id bigint,
    es_principal boolean
);


ALTER TABLE sch_gaj.com_presunto_infractor_audit OWNER TO gaj_owner;

--
-- Name: com_presunto_infractor_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_presunto_infractor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_presunto_infractor_id_seq OWNER TO gaj_owner;

--
-- Name: com_presunto_infractor_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_presunto_infractor_id_seq OWNED BY sch_gaj.com_presunto_infractor.id;


--
-- Name: com_proposito_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_proposito_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(250),
    codigo character varying(50)
);


ALTER TABLE sch_gaj.com_proposito_acta OWNER TO gaj_owner;

--
-- Name: com_proposito_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_proposito_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_proposito_acta_id_seq OWNER TO gaj_owner;

--
-- Name: com_proposito_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_proposito_acta_id_seq OWNED BY sch_gaj.com_proposito_acta.id;


--
-- Name: com_punto_domicilio_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_punto_domicilio_id_seq
    START WITH 65348
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_punto_domicilio_id_seq OWNER TO gaj_owner;

--
-- Name: com_punto_domicilio; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_punto_domicilio (
    id bigint DEFAULT nextval('sch_gaj.com_punto_domicilio_id_seq'::regclass) NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    x double precision NOT NULL,
    y double precision NOT NULL,
    domicilio_id bigint NOT NULL
);


ALTER TABLE sch_gaj.com_punto_domicilio OWNER TO gaj_owner;

--
-- Name: com_punto_domicilio_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_punto_domicilio_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    x double precision,
    y double precision,
    domicilio_id bigint
);


ALTER TABLE sch_gaj.com_punto_domicilio_backup OWNER TO gaj_owner;

--
-- Name: com_punto_domicilio_vieja; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_punto_domicilio_vieja (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    x double precision NOT NULL,
    y double precision NOT NULL,
    domicilio_id bigint NOT NULL
);


ALTER TABLE sch_gaj.com_punto_domicilio_vieja OWNER TO gaj_owner;

--
-- Name: com_revision_info; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_revision_info (
    id integer NOT NULL,
    "timestamp" bigint,
    username character varying(100)
);


ALTER TABLE sch_gaj.com_revision_info OWNER TO gaj_owner;

--
-- Name: com_sugerencia_destino; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_sugerencia_destino (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero integer,
    descripcion character varying(150)
);


ALTER TABLE sch_gaj.com_sugerencia_destino OWNER TO gaj_owner;

--
-- Name: com_sugerencia_destino_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_sugerencia_destino_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_sugerencia_destino_id_seq OWNER TO gaj_owner;

--
-- Name: com_sugerencia_destino_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_sugerencia_destino_id_seq OWNED BY sch_gaj.com_sugerencia_destino.id;


--
-- Name: com_tipo_imagen; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_tipo_imagen (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero integer NOT NULL,
    descripcion character varying(50) NOT NULL
);


ALTER TABLE sch_gaj.com_tipo_imagen OWNER TO gaj_owner;

--
-- Name: com_tipo_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_tipo_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_tipo_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: com_tipo_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_tipo_imagen_id_seq OWNED BY sch_gaj.com_tipo_imagen.id;


--
-- Name: com_tipo_objeto; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_tipo_objeto (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(20) NOT NULL,
    descripcion character varying(50),
    labels jsonb NOT NULL,
    tipo_infraccion character varying(20),
    clave character varying(30)
);


ALTER TABLE sch_gaj.com_tipo_objeto OWNER TO gaj_owner;

--
-- Name: com_tipo_objeto_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_tipo_objeto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_tipo_objeto_id_seq OWNER TO gaj_owner;

--
-- Name: com_tipo_objeto_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_tipo_objeto_id_seq OWNED BY sch_gaj.com_tipo_objeto.id;


--
-- Name: com_tipo_oficio; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_tipo_oficio (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(30) NOT NULL,
    descripcion character varying(100) NOT NULL,
    template character varying(50) NOT NULL,
    tiene_destino boolean,
    tiene_observaciones boolean,
    tiene_acta boolean,
    tiene_clausura boolean,
    tiene_detalle_pena boolean,
    tiene_detalle boolean,
    activo boolean NOT NULL
);


ALTER TABLE sch_gaj.com_tipo_oficio OWNER TO gaj_owner;

--
-- Name: com_tipo_oficio_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_tipo_oficio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_tipo_oficio_id_seq OWNER TO gaj_owner;

--
-- Name: com_tipo_oficio_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_tipo_oficio_id_seq OWNED BY sch_gaj.com_tipo_oficio.id;


--
-- Name: com_tipoacta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_tipoacta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(250),
    numero integer,
    metodo character varying(20),
    tasa_fotografica boolean DEFAULT false NOT NULL
);


ALTER TABLE sch_gaj.com_tipoacta OWNER TO gaj_owner;

--
-- Name: com_tipoacta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_tipoacta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_tipoacta_id_seq OWNER TO gaj_owner;

--
-- Name: com_tipoacta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_tipoacta_id_seq OWNED BY sch_gaj.com_tipoacta.id;


--
-- Name: com_tipoacta_reparticion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.com_tipoacta_reparticion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tipo_acta_id bigint NOT NULL,
    reparticion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.com_tipoacta_reparticion OWNER TO gaj_owner;

--
-- Name: com_tipoacta_reparticion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.com_tipoacta_reparticion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.com_tipoacta_reparticion_id_seq OWNER TO gaj_owner;

--
-- Name: com_tipoacta_reparticion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.com_tipoacta_reparticion_id_seq OWNED BY sch_gaj.com_tipoacta_reparticion.id;


--
-- Name: cor_actaestado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_actaestado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone,
    image_url character varying(100),
    numero character varying(20),
    tipo_acta character varying(255) NOT NULL,
    inventario_id bigint
);


ALTER TABLE sch_gaj.cor_actaestado OWNER TO gaj_owner;

--
-- Name: cor_actaestado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_actaestado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_actaestado_id_seq OWNER TO gaj_owner;

--
-- Name: cor_actaestado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_actaestado_id_seq OWNED BY sch_gaj.cor_actaestado.id;


--
-- Name: cor_egreso; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_egreso (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora_egreso timestamp without time zone NOT NULL,
    observaciones character varying(300),
    tipo_egreso character varying(255) NOT NULL,
    agente_id bigint NOT NULL,
    liberacion_id bigint,
    persona_retira_id bigint,
    tipo_destino_id bigint,
    comprobante character varying(20),
    aplica_extra_estadia boolean,
    comprobante_extra_estadia character varying(20),
    forma_egreso character varying(20)
);


ALTER TABLE sch_gaj.cor_egreso OWNER TO gaj_owner;

--
-- Name: cor_egreso_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_egreso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_egreso_id_seq OWNER TO gaj_owner;

--
-- Name: cor_egreso_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_egreso_id_seq OWNED BY sch_gaj.cor_egreso.id;


--
-- Name: cor_finalizartraslado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_finalizartraslado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora timestamp without time zone,
    observaciones character varying(100),
    agente_id bigint
);


ALTER TABLE sch_gaj.cor_finalizartraslado OWNER TO gaj_owner;

--
-- Name: cor_finalizartraslado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_finalizartraslado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_finalizartraslado_id_seq OWNER TO gaj_owner;

--
-- Name: cor_finalizartraslado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_finalizartraslado_id_seq OWNED BY sch_gaj.cor_finalizartraslado.id;


--
-- Name: cor_ingreso; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_ingreso (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora_entrada timestamp without time zone NOT NULL,
    observaciones character varying(100),
    tiene_acarreo boolean NOT NULL,
    acarreo_id bigint,
    agente_id bigint NOT NULL
);


ALTER TABLE sch_gaj.cor_ingreso OWNER TO gaj_owner;

--
-- Name: cor_ingreso_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_ingreso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_ingreso_id_seq OWNER TO gaj_owner;

--
-- Name: cor_ingreso_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_ingreso_id_seq OWNED BY sch_gaj.cor_ingreso.id;


--
-- Name: cor_iniciotraslado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_iniciotraslado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora timestamp without time zone,
    observaciones character varying(100),
    agente_id bigint
);


ALTER TABLE sch_gaj.cor_iniciotraslado OWNER TO gaj_owner;

--
-- Name: cor_iniciotraslado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_iniciotraslado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_iniciotraslado_id_seq OWNER TO gaj_owner;

--
-- Name: cor_iniciotraslado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_iniciotraslado_id_seq OWNED BY sch_gaj.cor_iniciotraslado.id;


--
-- Name: cor_inventario; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_inventario (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    estado character varying(255),
    nro_box integer,
    nro_inventario bigint NOT NULL,
    tipo_inventario character varying(255) NOT NULL,
    egreso_id bigint,
    ingreso_id bigint,
    sector_id bigint,
    tipo_corralon_id bigint,
    vehiculo_id bigint,
    en_traslado boolean DEFAULT false NOT NULL,
    notas character varying(255)
);


ALTER TABLE sch_gaj.cor_inventario OWNER TO gaj_owner;

--
-- Name: cor_inventario_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_inventario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_inventario_id_seq OWNER TO gaj_owner;

--
-- Name: cor_inventario_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_inventario_id_seq OWNED BY sch_gaj.cor_inventario.id;


--
-- Name: cor_inventario_nro_inventario_2018_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_inventario_nro_inventario_2018_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_inventario_nro_inventario_2018_seq OWNER TO gaj_owner;

--
-- Name: cor_inventario_nro_inventario_2019_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_inventario_nro_inventario_2019_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_inventario_nro_inventario_2019_seq OWNER TO gaj_owner;

--
-- Name: cor_inventario_nro_inventario_2020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_inventario_nro_inventario_2020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_inventario_nro_inventario_2020_seq OWNER TO gaj_owner;

--
-- Name: cor_novedad; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_novedad (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora timestamp without time zone NOT NULL,
    novedad character varying(300) NOT NULL,
    agente_id bigint NOT NULL,
    inventario_id bigint,
    persona_notificada_id bigint,
    tipo_relacion character varying(255) NOT NULL
);


ALTER TABLE sch_gaj.cor_novedad OWNER TO gaj_owner;

--
-- Name: cor_novedad_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_novedad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_novedad_id_seq OWNER TO gaj_owner;

--
-- Name: cor_novedad_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_novedad_id_seq OWNED BY sch_gaj.cor_novedad.id;


--
-- Name: cor_recepciontraslado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_recepciontraslado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha timestamp without time zone,
    observaciones character varying(100),
    agente_id bigint
);


ALTER TABLE sch_gaj.cor_recepciontraslado OWNER TO gaj_owner;

--
-- Name: cor_recepciontraslado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_recepciontraslado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_recepciontraslado_id_seq OWNER TO gaj_owner;

--
-- Name: cor_recepciontraslado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_recepciontraslado_id_seq OWNED BY sch_gaj.cor_recepciontraslado.id;


--
-- Name: cor_sector; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_sector (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(60),
    tipo_corralon_id bigint
);


ALTER TABLE sch_gaj.cor_sector OWNER TO gaj_owner;

--
-- Name: cor_sector_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_sector_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_sector_id_seq OWNER TO gaj_owner;

--
-- Name: cor_sector_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_sector_id_seq OWNED BY sch_gaj.cor_sector.id;


--
-- Name: cor_tipocorralon; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_tipocorralon (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(60),
    nombre character varying(60)
);


ALTER TABLE sch_gaj.cor_tipocorralon OWNER TO gaj_owner;

--
-- Name: cor_tipocorralon_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_tipocorralon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_tipocorralon_id_seq OWNER TO gaj_owner;

--
-- Name: cor_tipocorralon_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_tipocorralon_id_seq OWNED BY sch_gaj.cor_tipocorralon.id;


--
-- Name: cor_tipodestino; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_tipodestino (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(35),
    persona_retira boolean,
    requiere_liberacion boolean
);


ALTER TABLE sch_gaj.cor_tipodestino OWNER TO gaj_owner;

--
-- Name: cor_tipodestino_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_tipodestino_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_tipodestino_id_seq OWNER TO gaj_owner;

--
-- Name: cor_tipodestino_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_tipodestino_id_seq OWNED BY sch_gaj.cor_tipodestino.id;


--
-- Name: cor_tipoegreso; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_tipoegreso (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(60),
    persona_retira boolean,
    requiere_liberacion boolean
);


ALTER TABLE sch_gaj.cor_tipoegreso OWNER TO gaj_owner;

--
-- Name: cor_tipoegreso_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_tipoegreso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_tipoegreso_id_seq OWNER TO gaj_owner;

--
-- Name: cor_tipoegreso_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_tipoegreso_id_seq OWNED BY sch_gaj.cor_tipoegreso.id;


--
-- Name: cor_tipovehiculoacarreo; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_tipovehiculoacarreo (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    acarreo_individual boolean,
    descripcion character varying(255)
);


ALTER TABLE sch_gaj.cor_tipovehiculoacarreo OWNER TO gaj_owner;

--
-- Name: cor_tipovehiculoacarreo_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_tipovehiculoacarreo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_tipovehiculoacarreo_id_seq OWNER TO gaj_owner;

--
-- Name: cor_tipovehiculoacarreo_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_tipovehiculoacarreo_id_seq OWNED BY sch_gaj.cor_tipovehiculoacarreo.id;


--
-- Name: cor_traslado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_traslado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    nro_traslado bigint,
    vehiculo_acarreo_id bigint NOT NULL,
    corralon_origen_id bigint,
    corralon_destino_id bigint,
    inicio_traslado_id bigint,
    recepcion_traslado_id bigint,
    estado_traslado character varying(255),
    finalizar_traslado_id bigint
);


ALTER TABLE sch_gaj.cor_traslado OWNER TO gaj_owner;

--
-- Name: cor_traslado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_traslado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_traslado_id_seq OWNER TO gaj_owner;

--
-- Name: cor_traslado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_traslado_id_seq OWNED BY sch_gaj.cor_traslado.id;


--
-- Name: cor_traslado_nro_traslado_2018_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_traslado_nro_traslado_2018_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_traslado_nro_traslado_2018_seq OWNER TO gaj_owner;

--
-- Name: cor_traslado_nro_traslado_2019_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_traslado_nro_traslado_2019_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_traslado_nro_traslado_2019_seq OWNER TO gaj_owner;

--
-- Name: cor_traslado_nro_traslado_2020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_traslado_nro_traslado_2020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_traslado_nro_traslado_2020_seq OWNER TO gaj_owner;

--
-- Name: cor_traslado_traslado_inventarios; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_traslado_traslado_inventarios (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    traslado_id bigint NOT NULL,
    inventario_id bigint NOT NULL,
    aceptado_en_recepcion_traslado boolean,
    fecha_hora_recupero timestamp without time zone,
    observacion_recupero character varying(100),
    agregado_en_recepcion_traslado boolean,
    actaestado_creacion_id bigint,
    actaestado_recepcion_id bigint
);


ALTER TABLE sch_gaj.cor_traslado_traslado_inventarios OWNER TO gaj_owner;

--
-- Name: cor_traslado_traslado_inventarios_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_traslado_traslado_inventarios_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_traslado_traslado_inventarios_id_seq OWNER TO gaj_owner;

--
-- Name: cor_traslado_traslado_inventarios_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_traslado_traslado_inventarios_id_seq OWNED BY sch_gaj.cor_traslado_traslado_inventarios.id;


--
-- Name: cor_vehiculoacarreo; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_vehiculoacarreo (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(255),
    patente character varying(255),
    tipo_vehiculo_acarreo_id bigint
);


ALTER TABLE sch_gaj.cor_vehiculoacarreo OWNER TO gaj_owner;

--
-- Name: cor_vehiculoacarreo_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_vehiculoacarreo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_vehiculoacarreo_id_seq OWNER TO gaj_owner;

--
-- Name: cor_vehiculoacarreo_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_vehiculoacarreo_id_seq OWNED BY sch_gaj.cor_vehiculoacarreo.id;


--
-- Name: pad_persona; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_persona (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    id_persona bigint NOT NULL
);


ALTER TABLE sch_gaj.pad_persona OWNER TO gaj_owner;

--
-- Name: pad_vehiculo; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    color character varying(10),
    marca character varying(50),
    modelo character varying(10),
    nro_chasis character varying(20),
    nro_motor character varying(20),
    patente character varying(10),
    patente_ficticia_migracion character varying(10),
    tiene_patente boolean,
    usuario_operacion character varying(20),
    tipo_vehiculo_id bigint NOT NULL,
    habilitado boolean,
    fuente character varying(25) DEFAULT 'ACTA'::character varying,
    confiabilidad character varying(25),
    modelo_anio integer
);


ALTER TABLE sch_gaj.pad_vehiculo OWNER TO gaj_owner;

--
-- Name: COLUMN pad_vehiculo.modelo_anio; Type: COMMENT; Schema: sch_gaj; Owner: gaj_owner
--

COMMENT ON COLUMN sch_gaj.pad_vehiculo.modelo_anio IS 'Modelo Año';


--
-- Name: cor_vehiculos_egresados; Type: VIEW; Schema: sch_gaj; Owner: gaj_owner
--

CREATE VIEW sch_gaj.cor_vehiculos_egresados AS
 SELECT i.id,
    i.estado,
    i.nro_inventario,
    i.tipo_inventario,
    i.egreso_id,
    i.ingreso_id,
    v.patente,
    i.vehiculo_id,
    i.tipo_corralon_id,
    e.fecha_hora_egreso,
    e.tipo_egreso,
    e.agente_id,
    e.liberacion_id,
    e.persona_retira_id,
    p.id_persona,
    e.tipo_destino_id,
    e.comprobante,
    e.aplica_extra_estadia,
    e.comprobante_extra_estadia,
    e.forma_egreso,
    e.observaciones
   FROM sch_gaj.pad_vehiculo v,
    sch_gaj.cor_inventario i,
    sch_gaj.cor_egreso e,
    sch_gaj.pad_persona p
  WHERE ((v.id = i.vehiculo_id) AND (i.egreso_id = e.id) AND (e.persona_retira_id = p.id) AND (i.egreso_id IS NOT NULL));


ALTER TABLE sch_gaj.cor_vehiculos_egresados OWNER TO gaj_owner;

--
-- Name: cor_vehiculos_en_existencia; Type: VIEW; Schema: sch_gaj; Owner: gaj_owner
--

CREATE VIEW sch_gaj.cor_vehiculos_en_existencia AS
 SELECT i.id,
    i.estado,
    i.nro_inventario,
    i.tipo_inventario,
    i.egreso_id,
    i.ingreso_id,
    v.patente,
    i.vehiculo_id,
    i.tipo_corralon_id,
    tc.nombre,
    tc.descripcion,
    i.sector_id,
    s.descripcion AS desc_sector,
    i.nro_box,
    i.en_traslado,
    g.fecha_hora_entrada
   FROM sch_gaj.pad_vehiculo v,
    sch_gaj.cor_inventario i,
    sch_gaj.cor_ingreso g,
    sch_gaj.cor_tipocorralon tc,
    sch_gaj.cor_sector s
  WHERE ((v.id = i.vehiculo_id) AND (i.ingreso_id = g.id) AND (i.tipo_corralon_id = tc.id) AND (i.egreso_id IS NULL) AND (s.id = i.sector_id) AND ((i.estado)::text <> ALL (ARRAY[('ANULADO'::character varying)::text, ('PERDIDO'::character varying)::text])));


ALTER TABLE sch_gaj.cor_vehiculos_en_existencia OWNER TO gaj_owner;

--
-- Name: cor_verificaciontecnica; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.cor_verificaciontecnica (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_hora_verificacion timestamp without time zone NOT NULL,
    numero bigint NOT NULL,
    observaciones character varying(300),
    tipovt character varying(255) NOT NULL,
    agente_id bigint NOT NULL,
    persona_verifica_id bigint,
    tipo_relacion character varying(255) NOT NULL,
    inventario_id bigint NOT NULL
);


ALTER TABLE sch_gaj.cor_verificaciontecnica OWNER TO gaj_owner;

--
-- Name: cor_verificaciontecnica_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_verificaciontecnica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_verificaciontecnica_id_seq OWNER TO gaj_owner;

--
-- Name: cor_verificaciontecnica_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.cor_verificaciontecnica_id_seq OWNED BY sch_gaj.cor_verificaciontecnica.id;


--
-- Name: cor_verificaciontecnica_numero_2018_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2018_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_verificaciontecnica_numero_2018_seq OWNER TO gaj_owner;

--
-- Name: cor_verificaciontecnica_numero_2019_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2019_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_verificaciontecnica_numero_2019_seq OWNER TO gaj_owner;

--
-- Name: cor_verificaciontecnica_numero_2020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.cor_verificaciontecnica_numero_2020_seq OWNER TO gaj_owner;

--
-- Name: def_alternativalib; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_alternativalib (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(512) NOT NULL
);


ALTER TABLE sch_gaj.def_alternativalib OWNER TO gaj_owner;

--
-- Name: def_alternativalib_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_alternativalib_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_alternativalib_id_seq OWNER TO gaj_owner;

--
-- Name: def_alternativalib_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_alternativalib_id_seq OWNED BY sch_gaj.def_alternativalib.id;


--
-- Name: def_causal_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_causal_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(250) NOT NULL
);


ALTER TABLE sch_gaj.def_causal_infraccion OWNER TO gaj_owner;

--
-- Name: def_causal_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_causal_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_causal_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_causal_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_causal_infraccion_id_seq OWNED BY sch_gaj.def_causal_infraccion.id;


--
-- Name: def_concepto_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_concepto_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(100)
);


ALTER TABLE sch_gaj.def_concepto_infraccion OWNER TO gaj_owner;

--
-- Name: def_concepto_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_concepto_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_concepto_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_concepto_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_concepto_infraccion_id_seq OWNED BY sch_gaj.def_concepto_infraccion.id;


--
-- Name: def_especie_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_especie_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(255) NOT NULL
);


ALTER TABLE sch_gaj.def_especie_infraccion OWNER TO gaj_owner;

--
-- Name: def_especie_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_especie_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_especie_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_especie_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_especie_infraccion_id_seq OWNED BY sch_gaj.def_especie_infraccion.id;


--
-- Name: def_excluida_sugit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_excluida_sugit (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint NOT NULL,
    fecha_desde timestamp without time zone,
    fecha_hasta timestamp without time zone
);


ALTER TABLE sch_gaj.def_excluida_sugit OWNER TO gaj_owner;

--
-- Name: def_excluida_sugit_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_excluida_sugit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_excluida_sugit_id_seq OWNER TO gaj_owner;

--
-- Name: def_excluida_sugit_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_excluida_sugit_id_seq OWNED BY sch_gaj.def_excluida_sugit.id;


--
-- Name: def_normativa_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_normativa_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(255) NOT NULL
);


ALTER TABLE sch_gaj.def_normativa_infraccion OWNER TO gaj_owner;

--
-- Name: def_normativa_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_normativa_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_normativa_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_normativa_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_normativa_infraccion_id_seq OWNED BY sch_gaj.def_normativa_infraccion.id;


--
-- Name: def_parametro; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_parametro (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codparam character varying(40),
    desparam character varying(255),
    valor character varying(255)
);


ALTER TABLE sch_gaj.def_parametro OWNER TO gaj_owner;

--
-- Name: def_parametro_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_parametro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_parametro_id_seq OWNER TO gaj_owner;

--
-- Name: def_parametro_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_parametro_id_seq OWNED BY sch_gaj.def_parametro.id;


--
-- Name: def_particularidadlib; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_particularidadlib (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(255) NOT NULL
);


ALTER TABLE sch_gaj.def_particularidadlib OWNER TO gaj_owner;

--
-- Name: def_particularidadlib_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_particularidadlib_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_particularidadlib_id_seq OWNER TO gaj_owner;

--
-- Name: def_particularidadlib_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_particularidadlib_id_seq OWNED BY sch_gaj.def_particularidadlib.id;


--
-- Name: def_pena_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_pena_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint NOT NULL,
    tipo_pena_id bigint NOT NULL,
    fecha_desde timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    fecha_hasta timestamp without time zone,
    caracter_pena integer,
    obligatoria_sentencia boolean DEFAULT false NOT NULL,
    es_definitiva boolean DEFAULT false NOT NULL
);


ALTER TABLE sch_gaj.def_pena_infraccion OWNER TO gaj_owner;

--
-- Name: def_pena_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_pena_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_pena_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_pena_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_pena_infraccion_id_seq OWNED BY sch_gaj.def_pena_infraccion.id;


--
-- Name: def_pena_regla_reincidencia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_pena_regla_reincidencia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    valor_reincidencia_id bigint NOT NULL,
    caracter_pena integer,
    tipo_pena_id bigint NOT NULL,
    es_definitiva boolean DEFAULT false NOT NULL,
    obligatoria_sentencia boolean DEFAULT false NOT NULL,
    con_tope_superior boolean DEFAULT false NOT NULL,
    modificador_reincidencia double precision,
    porcentaje_recargo double precision
);


ALTER TABLE sch_gaj.def_pena_regla_reincidencia OWNER TO gaj_owner;

--
-- Name: def_pena_regla_reincidencia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_pena_regla_reincidencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_pena_regla_reincidencia_id_seq OWNER TO gaj_owner;

--
-- Name: def_pena_regla_reincidencia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_pena_regla_reincidencia_id_seq OWNED BY sch_gaj.def_pena_regla_reincidencia.id;


--
-- Name: def_penalidad_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_penalidad_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint NOT NULL,
    tipo integer,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone,
    valor double precision
);


ALTER TABLE sch_gaj.def_penalidad_infraccion OWNER TO gaj_owner;

--
-- Name: def_penalidad_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_penalidad_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_penalidad_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_penalidad_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_penalidad_infraccion_id_seq OWNED BY sch_gaj.def_penalidad_infraccion.id;


--
-- Name: def_penalidad_infraccion_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_penalidad_infraccion_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_penalidad_infraccion_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_penalidad_infraccion_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_penalidad_infraccion_infraccion_id_seq OWNED BY sch_gaj.def_penalidad_infraccion.infraccion_id;


--
-- Name: def_permiso_funcional; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_permiso_funcional (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    cod_funcionalidad character varying(60) NOT NULL,
    des_funcionalidad character varying(255),
    control character varying(60) NOT NULL,
    opcion character varying(60) NOT NULL
);


ALTER TABLE sch_gaj.def_permiso_funcional OWNER TO gaj_owner;

--
-- Name: def_permiso_funcional_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_permiso_funcional_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_permiso_funcional_id_seq OWNER TO gaj_owner;

--
-- Name: def_permiso_funcional_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_permiso_funcional_id_seq OWNED BY sch_gaj.def_permiso_funcional.id;


--
-- Name: def_permiso_funcional_usuario; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_permiso_funcional_usuario (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuario_id bigint NOT NULL,
    permiso_funcional_id bigint NOT NULL,
    valor boolean NOT NULL
);


ALTER TABLE sch_gaj.def_permiso_funcional_usuario OWNER TO gaj_owner;

--
-- Name: def_permiso_funcional_usuario_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_permiso_funcional_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_permiso_funcional_usuario_id_seq OWNER TO gaj_owner;

--
-- Name: def_permiso_funcional_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_permiso_funcional_usuario_id_seq OWNED BY sch_gaj.def_permiso_funcional_usuario.id;


--
-- Name: def_regimen_juzgamiento; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_regimen_juzgamiento (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint NOT NULL,
    tipo integer NOT NULL,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone
);


ALTER TABLE sch_gaj.def_regimen_juzgamiento OWNER TO gaj_owner;

--
-- Name: def_regimen_juzgamiento_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_regimen_juzgamiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_regimen_juzgamiento_id_seq OWNER TO gaj_owner;

--
-- Name: def_regimen_juzgamiento_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_regimen_juzgamiento_id_seq OWNED BY sch_gaj.def_regimen_juzgamiento.id;


--
-- Name: def_regimen_juzgamiento_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_regimen_juzgamiento_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_regimen_juzgamiento_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_regimen_juzgamiento_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_regimen_juzgamiento_infraccion_id_seq OWNED BY sch_gaj.def_regimen_juzgamiento.infraccion_id;


--
-- Name: def_regla_reincidencia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_regla_reincidencia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(50),
    descripcion character varying(250),
    tipo_valor_sugerido integer,
    unidad_tiempo_reincidencia integer,
    tiempo_reincidencia integer,
    regla_reincidencia_alternativa_id bigint
);


ALTER TABLE sch_gaj.def_regla_reincidencia OWNER TO gaj_owner;

--
-- Name: def_regla_reincidencia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_regla_reincidencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_regla_reincidencia_id_seq OWNER TO gaj_owner;

--
-- Name: def_regla_reincidencia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_regla_reincidencia_id_seq OWNED BY sch_gaj.def_regla_reincidencia.id;


--
-- Name: def_regla_reincidencia_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_regla_reincidencia_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint NOT NULL,
    regla_reincidencia_id bigint NOT NULL,
    valor_sugerido double precision,
    tipo integer,
    valor_minimo double precision,
    valor_maximo double precision,
    porcentaje_variacion_min_max double precision
);


ALTER TABLE sch_gaj.def_regla_reincidencia_infraccion OWNER TO gaj_owner;

--
-- Name: def_regla_reincidencia_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_regla_reincidencia_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_regla_reincidencia_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_regla_reincidencia_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_regla_reincidencia_infraccion_id_seq OWNED BY sch_gaj.def_regla_reincidencia_infraccion.id;


--
-- Name: def_reparticion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_reparticion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(60),
    codigo character varying(60)
);


ALTER TABLE sch_gaj.def_reparticion OWNER TO gaj_owner;

--
-- Name: def_reparticion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_reparticion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_reparticion_id_seq OWNER TO gaj_owner;

--
-- Name: def_reparticion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_reparticion_id_seq OWNED BY sch_gaj.def_reparticion.id;


--
-- Name: def_requisitolib; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_requisitolib (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(128) NOT NULL
);


ALTER TABLE sch_gaj.def_requisitolib OWNER TO gaj_owner;

--
-- Name: def_requisitolib_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_requisitolib_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_requisitolib_id_seq OWNER TO gaj_owner;

--
-- Name: def_requisitolib_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_requisitolib_id_seq OWNED BY sch_gaj.def_requisitolib.id;


--
-- Name: def_requisitoslibveh; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_requisitoslibveh (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    id_tipovehiculolibera bigint NOT NULL,
    id_requisitolib bigint NOT NULL,
    id_alternativalib bigint NOT NULL,
    id_particularidadlib bigint NOT NULL
);


ALTER TABLE sch_gaj.def_requisitoslibveh OWNER TO gaj_owner;

--
-- Name: def_requisitoslibveh_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_requisitoslibveh_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_requisitoslibveh_id_seq OWNER TO gaj_owner;

--
-- Name: def_requisitoslibveh_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_requisitoslibveh_id_seq OWNED BY sch_gaj.def_requisitoslibveh.id;


--
-- Name: def_subespecie_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_subespecie_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(255) NOT NULL,
    especie_id bigint NOT NULL
);


ALTER TABLE sch_gaj.def_subespecie_infraccion OWNER TO gaj_owner;

--
-- Name: def_subespecie_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_subespecie_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_subespecie_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_subespecie_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_subespecie_infraccion_id_seq OWNED BY sch_gaj.def_subespecie_infraccion.id;


--
-- Name: def_tipo_pago_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_tipo_pago_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint NOT NULL,
    tipo integer NOT NULL,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone
);


ALTER TABLE sch_gaj.def_tipo_pago_infraccion OWNER TO gaj_owner;

--
-- Name: def_tipo_pago_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_tipo_pago_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_tipo_pago_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_tipo_pago_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_tipo_pago_infraccion_id_seq OWNED BY sch_gaj.def_tipo_pago_infraccion.id;


--
-- Name: def_tipo_pago_infraccion_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_tipo_pago_infraccion_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_tipo_pago_infraccion_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_tipo_pago_infraccion_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_tipo_pago_infraccion_infraccion_id_seq OWNED BY sch_gaj.def_tipo_pago_infraccion.infraccion_id;


--
-- Name: def_tipo_pena; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_tipo_pena (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(50) NOT NULL,
    codigo character varying(50) NOT NULL,
    es_pecunaria boolean DEFAULT false NOT NULL,
    orden integer,
    es_periodo boolean,
    como_principal boolean,
    como_accesoria boolean,
    excluir_si_rebeldia boolean,
    aplica_sobre_objeto boolean
);


ALTER TABLE sch_gaj.def_tipo_pena OWNER TO gaj_owner;

--
-- Name: def_tipo_pena_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_tipo_pena_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_tipo_pena_id_seq OWNER TO gaj_owner;

--
-- Name: def_tipo_pena_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_tipo_pena_id_seq OWNED BY sch_gaj.def_tipo_pena.id;


--
-- Name: def_tipovehiculolibera; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_tipovehiculolibera (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(64) NOT NULL
);


ALTER TABLE sch_gaj.def_tipovehiculolibera OWNER TO gaj_owner;

--
-- Name: def_tipovehiculolibera_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_tipovehiculolibera_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_tipovehiculolibera_id_seq OWNER TO gaj_owner;

--
-- Name: def_tipovehiculolibera_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_tipovehiculolibera_id_seq OWNED BY sch_gaj.def_tipovehiculolibera.id;


--
-- Name: def_usuario; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_usuario (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuario character varying(255),
    tipo_corralon_id bigint
);


ALTER TABLE sch_gaj.def_usuario OWNER TO gaj_owner;

--
-- Name: def_usuario_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_usuario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_usuario_id_seq OWNER TO gaj_owner;

--
-- Name: def_usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_usuario_id_seq OWNED BY sch_gaj.def_usuario.id;


--
-- Name: def_usuario_permiso_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_usuario_permiso_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuario_id bigint NOT NULL,
    reparticion_id bigint NOT NULL,
    proposito_acta_id bigint NOT NULL,
    tipo_acta_id bigint NOT NULL,
    tipo_objeto_id bigint NOT NULL
);


ALTER TABLE sch_gaj.def_usuario_permiso_acta OWNER TO gaj_owner;

--
-- Name: def_usuario_permiso_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_usuario_permiso_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_usuario_permiso_acta_id_seq OWNER TO gaj_owner;

--
-- Name: def_usuario_permiso_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_usuario_permiso_acta_id_seq OWNED BY sch_gaj.def_usuario_permiso_acta.id;


--
-- Name: def_usuario_permiso_notificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_usuario_permiso_notificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuario_id bigint NOT NULL,
    reparticion_id bigint NOT NULL,
    tipo_objeto_id bigint NOT NULL,
    tipo_notificacion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.def_usuario_permiso_notificacion OWNER TO gaj_owner;

--
-- Name: def_usuario_permiso_notificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_usuario_permiso_notificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_usuario_permiso_notificacion_id_seq OWNER TO gaj_owner;

--
-- Name: def_usuario_permiso_notificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_usuario_permiso_notificacion_id_seq OWNED BY sch_gaj.def_usuario_permiso_notificacion.id;


--
-- Name: def_usuario_reparticion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_usuario_reparticion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuario_id bigint NOT NULL,
    reparticion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.def_usuario_reparticion OWNER TO gaj_owner;

--
-- Name: def_usuario_reparticion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_usuario_reparticion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_usuario_reparticion_id_seq OWNER TO gaj_owner;

--
-- Name: def_usuario_reparticion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_usuario_reparticion_id_seq OWNED BY sch_gaj.def_usuario_reparticion.id;


--
-- Name: def_usuariofuncion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_usuariofuncion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tipo_corralon_id bigint,
    usuario_id bigint
);


ALTER TABLE sch_gaj.def_usuariofuncion OWNER TO gaj_owner;

--
-- Name: def_usuariofuncion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_usuariofuncion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_usuariofuncion_id_seq OWNER TO gaj_owner;

--
-- Name: def_usuariofuncion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_usuariofuncion_id_seq OWNED BY sch_gaj.def_usuariofuncion.id;


--
-- Name: def_valor_reincidencia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_valor_reincidencia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    valor_reincidencia integer NOT NULL,
    regla_reincidencia_id bigint NOT NULL
);


ALTER TABLE sch_gaj.def_valor_reincidencia OWNER TO gaj_owner;

--
-- Name: def_valor_reincidencia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_valor_reincidencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_valor_reincidencia_id_seq OWNER TO gaj_owner;

--
-- Name: def_valor_reincidencia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_valor_reincidencia_id_seq OWNED BY sch_gaj.def_valor_reincidencia.id;


--
-- Name: def_valuacion_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.def_valuacion_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    pena_infraccion_id bigint NOT NULL,
    tipo integer,
    valor_minimo double precision,
    valor_maximo double precision,
    valor_sugerido double precision,
    porc_descuento_pago_voluntario double precision,
    tope_recurrencia_pago_voluntario integer,
    tope_reincidencia_suspenso integer,
    porc_recargo_rebeldia double precision,
    unidad_tiempo_pago_voluntario integer,
    unidad_tiempo_allanamiento integer,
    unidad_tiempo_en_suspenso integer,
    tiempo_pago_voluntario integer,
    tiempo_allanamiento integer,
    tiempo_en_suspenso integer,
    tope_reincidencia_pago_voluntario integer
);


ALTER TABLE sch_gaj.def_valuacion_infraccion OWNER TO gaj_owner;

--
-- Name: def_valuacion_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.def_valuacion_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.def_valuacion_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: def_valuacion_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.def_valuacion_infraccion_id_seq OWNED BY sch_gaj.def_valuacion_infraccion.id;


--
-- Name: ext_consulta_sugit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.ext_consulta_sugit (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuid bigint,
    ingid bigint,
    dominios character varying(200) NOT NULL,
    rspid character varying NOT NULL
);


ALTER TABLE sch_gaj.ext_consulta_sugit OWNER TO gaj_owner;

--
-- Name: ext_consulta_sugit_det; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.ext_consulta_sugit_det (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    consulta_sugit_id bigint NOT NULL,
    inf_dominio character varying(8) NOT NULL,
    infacta character varying(12) NOT NULL,
    acta_id bigint NOT NULL,
    infta character(1) NOT NULL,
    cifid character varying(11) NOT NULL,
    infraccion_id bigint NOT NULL,
    inffecproc timestamp without time zone NOT NULL,
    inffecinf date NOT NULL,
    inffechora timestamp without time zone NOT NULL,
    infimportebonif double precision NOT NULL,
    infimportevenc double precision NOT NULL,
    tiporegistro integer NOT NULL,
    infreservado character varying(100),
    inffecvenc timestamp without time zone NOT NULL,
    imp_foto double precision NOT NULL,
    aplica_maximo integer DEFAULT 0 NOT NULL,
    descuento double precision DEFAULT 0 NOT NULL
);


ALTER TABLE sch_gaj.ext_consulta_sugit_det OWNER TO gaj_owner;

--
-- Name: ext_consulta_sugit_det_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.ext_consulta_sugit_det_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.ext_consulta_sugit_det_id_seq OWNER TO gaj_owner;

--
-- Name: ext_consulta_sugit_det_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.ext_consulta_sugit_det_id_seq OWNED BY sch_gaj.ext_consulta_sugit_det.id;


--
-- Name: ext_consulta_sugit_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.ext_consulta_sugit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.ext_consulta_sugit_id_seq OWNER TO gaj_owner;

--
-- Name: ext_consulta_sugit_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.ext_consulta_sugit_id_seq OWNED BY sch_gaj.ext_consulta_sugit.id;


--
-- Name: ext_pagos_sugit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.ext_pagos_sugit (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    traid bigint NOT NULL,
    frmid bigint NOT NULL,
    tradominio character varying(8) NOT NULL,
    topid bigint NOT NULL,
    topdescrip character varying(50) NOT NULL,
    regid bigint NOT NULL,
    oprid bigint NOT NULL,
    trafecreg date,
    infacta character varying(12) NOT NULL,
    cifid character varying(11) NOT NULL,
    infimporte double precision NOT NULL,
    trafecbaj character varying(255),
    consulta_sugit_det_id bigint,
    infreservado character varying(100),
    estado smallint,
    fechaconciliado character varying(255),
    fechaobtenido character varying(255),
    nro_recibo character varying(255),
    zz character varying(255)
);


ALTER TABLE sch_gaj.ext_pagos_sugit OWNER TO gaj_owner;

--
-- Name: ext_pagos_sugit_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.ext_pagos_sugit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.ext_pagos_sugit_id_seq OWNER TO gaj_owner;

--
-- Name: ext_pagos_sugit_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.ext_pagos_sugit_id_seq OWNED BY sch_gaj.ext_pagos_sugit.id;


--
-- Name: fecha; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.fecha (
    max timestamp without time zone
);


ALTER TABLE sch_gaj.fecha OWNER TO gaj_owner;

--
-- Name: for_formulario; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.for_formulario (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    codigo character varying(50) NOT NULL,
    descripcion character varying(150) NOT NULL,
    es_stamp boolean NOT NULL,
    template_path character varying(255) NOT NULL
);


ALTER TABLE sch_gaj.for_formulario OWNER TO gaj_owner;

--
-- Name: for_formulario_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.for_formulario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.for_formulario_id_seq OWNER TO gaj_owner;

--
-- Name: for_formulario_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.for_formulario_id_seq OWNED BY sch_gaj.for_formulario.id;


--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.hibernate_sequence OWNER TO gaj_owner;

--
-- Name: juz_accion_juzgamiento; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_accion_juzgamiento (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint NOT NULL,
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    descripcion character varying(150) NOT NULL,
    es_final boolean NOT NULL,
    es_inicial boolean NOT NULL,
    acciones_previas character varying(50),
    transiciones character varying(50),
    es_sancionatoria boolean NOT NULL,
    texto_generico_sentencia character varying(255),
    fecha_hasta timestamp without time zone,
    aplica_acta boolean,
    orden integer,
    codigo character varying(150),
    descripcion_for_view character varying(150)
);


ALTER TABLE sch_gaj.juz_accion_juzgamiento OWNER TO gaj_owner;

--
-- Name: juz_accion_juzgamiento_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_accion_juzgamiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_accion_juzgamiento_id_seq OWNER TO gaj_owner;

--
-- Name: juz_accion_juzgamiento_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_accion_juzgamiento_id_seq OWNED BY sch_gaj.juz_accion_juzgamiento.id;


--
-- Name: juz_acta_juez; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_acta_juez (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    juez_id bigint,
    fecha_desde timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    fecha_hasta timestamp without time zone,
    instancia integer,
    motivo_cambio_juez character varying(255),
    juzgamiento_sin_juez boolean,
    sentencia_acta_id bigint NOT NULL
);


ALTER TABLE sch_gaj.juz_acta_juez OWNER TO gaj_owner;

--
-- Name: juz_acta_juez_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_acta_juez_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_acta_juez_id_seq OWNER TO gaj_owner;

--
-- Name: juz_acta_juez_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_acta_juez_id_seq OWNED BY sch_gaj.juz_acta_juez.id;


--
-- Name: juz_agravio_apelacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_agravio_apelacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    apelacion_id bigint NOT NULL,
    imagen_id bigint,
    texto_agravio text,
    persona_id bigint
);


ALTER TABLE sch_gaj.juz_agravio_apelacion OWNER TO gaj_owner;

--
-- Name: juz_agravio_apelacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_agravio_apelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_agravio_apelacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_agravio_apelacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_agravio_apelacion_id_seq OWNED BY sch_gaj.juz_agravio_apelacion.id;


--
-- Name: juz_apelacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_apelacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint NOT NULL,
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    fecha_presentacion timestamp without time zone NOT NULL,
    fundamentacion character varying(255),
    sellado_pagado boolean NOT NULL,
    estado_apelacion_id bigint NOT NULL,
    sentencia_id bigint NOT NULL,
    domicilio_id bigint,
    anio bigint NOT NULL,
    numero bigint NOT NULL,
    expediente_nro bigint,
    expediente_anio bigint,
    sentencia_generada_id bigint,
    queja boolean,
    cuij character varying(20),
    fecha_corte timestamp without time zone
);


ALTER TABLE sch_gaj.juz_apelacion OWNER TO gaj_owner;

--
-- Name: juz_apelacion_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_apelacion_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint NOT NULL,
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    observacion character varying(200) NOT NULL,
    estado_apelacion character varying(50) NOT NULL,
    apelacion_id bigint NOT NULL,
    sentencia_acta_id bigint NOT NULL,
    imagen_id bigint
);


ALTER TABLE sch_gaj.juz_apelacion_acta OWNER TO gaj_owner;

--
-- Name: juz_apelacion_acta_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_apelacion_acta_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint,
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    observacion character varying(200),
    estado_apelacion character varying(50),
    apelacion_id bigint,
    sentencia_acta_id bigint,
    imagen_id bigint
);


ALTER TABLE sch_gaj.juz_apelacion_acta_backup OWNER TO gaj_owner;

--
-- Name: juz_apelacion_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_acta_id_seq OWNER TO gaj_owner;

--
-- Name: juz_apelacion_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_apelacion_acta_id_seq OWNED BY sch_gaj.juz_apelacion_acta.id;


--
-- Name: juz_apelacion_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_apelacion_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint,
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    fecha_presentacion timestamp without time zone,
    fundamentacion character varying(255),
    sellado_pagado boolean,
    estado_apelacion_id bigint,
    sentencia_id bigint,
    domicilio_id bigint,
    anio bigint,
    numero bigint,
    expediente_nro bigint,
    expediente_anio bigint,
    sentencia_generada_id bigint,
    queja boolean,
    cuij character varying(20),
    fecha_corte timestamp without time zone
);


ALTER TABLE sch_gaj.juz_apelacion_backup OWNER TO gaj_owner;

--
-- Name: juz_apelacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_apelacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_apelacion_id_seq OWNED BY sch_gaj.juz_apelacion.id;


--
-- Name: juz_apelacion_imagen; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_apelacion_imagen (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    apelacion_id bigint NOT NULL,
    imagen_id bigint NOT NULL
);


ALTER TABLE sch_gaj.juz_apelacion_imagen OWNER TO gaj_owner;

--
-- Name: juz_apelacion_imagen_apelacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_imagen_apelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_imagen_apelacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_apelacion_imagen_apelacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_apelacion_imagen_apelacion_id_seq OWNED BY sch_gaj.juz_apelacion_imagen.apelacion_id;


--
-- Name: juz_apelacion_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: juz_apelacion_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_apelacion_imagen_id_seq OWNED BY sch_gaj.juz_apelacion_imagen.id;


--
-- Name: juz_apelacion_imagen_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_imagen_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_imagen_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: juz_apelacion_imagen_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_apelacion_imagen_imagen_id_seq OWNED BY sch_gaj.juz_apelacion_imagen.imagen_id;


--
-- Name: juz_apelacion_numero_2020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_numero_2020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_numero_2020_seq OWNER TO gaj_owner;

--
-- Name: juz_apelacion_numero_2021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_numero_2021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_numero_2021_seq OWNER TO gaj_owner;

--
-- Name: juz_apelacion_numero_2022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_apelacion_numero_2022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_apelacion_numero_2022_seq OWNER TO gaj_owner;

--
-- Name: juz_audiencia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_audiencia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    acta_juez_id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    motivo character varying(255)
);


ALTER TABLE sch_gaj.juz_audiencia OWNER TO gaj_owner;

--
-- Name: juz_audiencia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_audiencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_audiencia_id_seq OWNER TO gaj_owner;

--
-- Name: juz_audiencia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_audiencia_id_seq OWNED BY sch_gaj.juz_audiencia.id;


--
-- Name: juz_borrador_juzgamiento; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_borrador_juzgamiento (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    juez_id bigint,
    infractor_id bigint NOT NULL,
    fecha timestamp without time zone NOT NULL,
    juzgamiento jsonb NOT NULL
);


ALTER TABLE sch_gaj.juz_borrador_juzgamiento OWNER TO gaj_owner;

--
-- Name: juz_borrador_juzgamiento_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_borrador_juzgamiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_borrador_juzgamiento_id_seq OWNER TO gaj_owner;

--
-- Name: juz_borrador_juzgamiento_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_borrador_juzgamiento_id_seq OWNED BY sch_gaj.juz_borrador_juzgamiento.id;


--
-- Name: juz_camara; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_camara (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(100) NOT NULL,
    codigo character varying(50) NOT NULL
);


ALTER TABLE sch_gaj.juz_camara OWNER TO gaj_owner;

--
-- Name: juz_camara_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_camara_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_camara_id_seq OWNER TO gaj_owner;

--
-- Name: juz_camara_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_camara_id_seq OWNED BY sch_gaj.juz_camara.id;


--
-- Name: juz_cambio_infractor; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_cambio_infractor (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    acta_id bigint NOT NULL,
    persona_id bigint NOT NULL,
    fecha timestamp without time zone
);


ALTER TABLE sch_gaj.juz_cambio_infractor OWNER TO gaj_owner;

--
-- Name: juz_cambio_infractor_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_cambio_infractor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_cambio_infractor_id_seq OWNER TO gaj_owner;

--
-- Name: juz_cambio_infractor_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_cambio_infractor_id_seq OWNED BY sch_gaj.juz_cambio_infractor.id;


--
-- Name: juz_descargo_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_descargo_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    acta_id bigint NOT NULL,
    imagen_id bigint,
    texto_descargo text,
    sentencia_acta_id bigint,
    persona_id bigint
);


ALTER TABLE sch_gaj.juz_descargo_acta OWNER TO gaj_owner;

--
-- Name: juz_descargo_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_descargo_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_descargo_acta_id_seq OWNER TO gaj_owner;

--
-- Name: juz_descargo_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_descargo_acta_id_seq OWNED BY sch_gaj.juz_descargo_acta.id;


--
-- Name: juz_desistencia_apelacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_desistencia_apelacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint NOT NULL,
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    apelacion_id bigint NOT NULL,
    imagen_id bigint,
    justificacion character varying(200) NOT NULL
);


ALTER TABLE sch_gaj.juz_desistencia_apelacion OWNER TO gaj_owner;

--
-- Name: juz_desistencia_apelacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_desistencia_apelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_desistencia_apelacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_desistencia_apelacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_desistencia_apelacion_id_seq OWNED BY sch_gaj.juz_desistencia_apelacion.id;


--
-- Name: juz_deuda_siat; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_deuda_siat (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    id_deuda_siat bigint,
    id_cuenta bigint,
    nro_cuenta character varying(100),
    fecha_pago timestamp without time zone,
    cod_recurso character varying(50),
    recibo_siat_id bigint,
    sentencia_acta_id bigint,
    fecha_vencimiento timestamp without time zone,
    pena_sentencia_id bigint
);


ALTER TABLE sch_gaj.juz_deuda_siat OWNER TO gaj_owner;

--
-- Name: juz_deuda_siat_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_deuda_siat_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    id_deuda_siat bigint,
    id_cuenta bigint,
    nro_cuenta character varying(100),
    fecha_pago timestamp without time zone,
    cod_recurso character varying(50),
    recibo_siat_id bigint,
    sentencia_acta_id bigint,
    fecha_vencimiento timestamp without time zone,
    pena_sentencia_id bigint
);


ALTER TABLE sch_gaj.juz_deuda_siat_backup OWNER TO gaj_owner;

--
-- Name: juz_deuda_siat_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_deuda_siat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_deuda_siat_id_seq OWNER TO gaj_owner;

--
-- Name: juz_deuda_siat_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_deuda_siat_id_seq OWNED BY sch_gaj.juz_deuda_siat.id;


--
-- Name: juz_envio_siat; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_envio_siat (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tipo_envio integer NOT NULL,
    mensaje_error character varying(500),
    estado_envio integer,
    fecha_ultimo_envio timestamp without time zone,
    id_deuda_siat bigint,
    ids_pena_sentencia character varying(100),
    sentencia_acta_id bigint,
    apelacion_id bigint,
    sentencia_id bigint
);


ALTER TABLE sch_gaj.juz_envio_siat OWNER TO gaj_owner;

--
-- Name: juz_envio_siat_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_envio_siat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_envio_siat_id_seq OWNER TO gaj_owner;

--
-- Name: juz_envio_siat_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_envio_siat_id_seq OWNED BY sch_gaj.juz_envio_siat.id;


--
-- Name: juz_estado_apelacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_estado_apelacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint NOT NULL,
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    descripcion character varying(100) NOT NULL,
    codigo character varying(50) NOT NULL
);


ALTER TABLE sch_gaj.juz_estado_apelacion OWNER TO gaj_owner;

--
-- Name: juz_estado_apelacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_estado_apelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_estado_apelacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_estado_apelacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_estado_apelacion_id_seq OWNED BY sch_gaj.juz_estado_apelacion.id;


--
-- Name: juz_histestape; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_histestape (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    estado_apelacion_id bigint NOT NULL,
    apelacion_id bigint NOT NULL,
    log_cambio character varying(255)
);


ALTER TABLE sch_gaj.juz_histestape OWNER TO gaj_owner;

--
-- Name: juz_histestape_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_histestape_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_histestape_id_seq OWNER TO gaj_owner;

--
-- Name: juz_histestape_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_histestape_id_seq OWNED BY sch_gaj.juz_histestape.id;


--
-- Name: juz_histestsenact; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_histestsenact (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    estado_juzgamiento integer NOT NULL,
    sentencia_acta_id bigint NOT NULL,
    log_cambio character varying(255)
);


ALTER TABLE sch_gaj.juz_histestsenact OWNER TO gaj_owner;

--
-- Name: juz_histestsenact_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_histestsenact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_histestsenact_id_seq OWNER TO gaj_owner;

--
-- Name: juz_histestsenact_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_histestsenact_id_seq OWNED BY sch_gaj.juz_histestsenact.id;


--
-- Name: juz_juez_apelacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_juez_apelacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    juez_id bigint NOT NULL,
    apelacion_id bigint NOT NULL,
    fecha_asignacion timestamp without time zone,
    fecha_baja timestamp without time zone,
    sentencia_nueva_id bigint,
    sentencia_acuerda_id bigint,
    fecha_fallo timestamp without time zone,
    tipo_voto integer,
    es_juez_tramite boolean,
    justificacion character varying(500)
);


ALTER TABLE sch_gaj.juz_juez_apelacion OWNER TO gaj_owner;

--
-- Name: juz_juez_apelacion_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_juez_apelacion_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    juez_id bigint,
    apelacion_id bigint,
    fecha_asignacion timestamp without time zone,
    fecha_baja timestamp without time zone,
    sentencia_nueva_id bigint,
    sentencia_acuerda_id bigint,
    fecha_fallo timestamp without time zone,
    tipo_voto integer,
    es_juez_tramite boolean,
    justificacion character varying(500)
);


ALTER TABLE sch_gaj.juz_juez_apelacion_backup OWNER TO gaj_owner;

--
-- Name: juz_juez_apelacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_juez_apelacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_juez_apelacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_juez_apelacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_juez_apelacion_id_seq OWNED BY sch_gaj.juz_juez_apelacion.id;


--
-- Name: juz_novedad_siat; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_novedad_siat (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tipo_novedad character varying(16) NOT NULL,
    deuda_siat_id bigint NOT NULL,
    recibo_siat_id bigint,
    fecha_pago timestamp without time zone,
    fecha_novedad timestamp without time zone,
    fecha_proceso timestamp without time zone,
    estado integer,
    mensaje character varying(255) DEFAULT NULL::character varying,
    corrida_id bigint
);


ALTER TABLE sch_gaj.juz_novedad_siat OWNER TO gaj_owner;

--
-- Name: juz_novedad_siat_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_novedad_siat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_novedad_siat_id_seq OWNER TO gaj_owner;

--
-- Name: juz_novedad_siat_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_novedad_siat_id_seq OWNED BY sch_gaj.juz_novedad_siat.id;


--
-- Name: juz_pago_sugit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_pago_sugit (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tra_id bigint NOT NULL,
    frm_id bigint NOT NULL,
    tra_dominio character varying(255) NOT NULL,
    top_id integer NOT NULL,
    top_descrip character varying(255),
    reg_id bigint NOT NULL,
    opr_id bigint NOT NULL,
    tra_fec_reg timestamp without time zone NOT NULL,
    tra_fec_baj timestamp without time zone,
    inf_acta character varying(255) NOT NULL,
    cif_id character varying(255) NOT NULL,
    inf_importe double precision NOT NULL,
    inf_reservado character varying(255) NOT NULL,
    recibo_siat_id bigint,
    deuda_siat_id bigint,
    acta_id bigint NOT NULL
);


ALTER TABLE sch_gaj.juz_pago_sugit OWNER TO gaj_owner;

--
-- Name: juz_pago_sugit_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_pago_sugit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_pago_sugit_id_seq OWNER TO gaj_owner;

--
-- Name: juz_pago_sugit_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_pago_sugit_id_seq OWNED BY sch_gaj.juz_pago_sugit.id;


--
-- Name: juz_pena_sentencia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_pena_sentencia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    sentencia_infraccion_id bigint,
    tipo_pena_id bigint NOT NULL,
    fecha_cumplimiento_pena timestamp without time zone,
    accion_juzgamiento_id bigint,
    es_definitiva boolean NOT NULL,
    estado_pena_sentencia integer NOT NULL,
    unidad_tiempo integer,
    original_en_suspenso boolean,
    unidad_valuacion integer,
    valor_original double precision,
    porcentaje_descuento double precision,
    valor_conversion double precision,
    menor_al_minimo boolean,
    mayor_al_maximo boolean
);


ALTER TABLE sch_gaj.juz_pena_sentencia OWNER TO gaj_owner;

--
-- Name: juz_pena_sentencia_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_pena_sentencia_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    sentencia_infraccion_id bigint,
    tipo_pena_id bigint,
    fecha_cumplimiento_pena timestamp without time zone,
    accion_juzgamiento_id bigint,
    es_definitiva boolean,
    estado_pena_sentencia integer,
    unidad_tiempo integer,
    original_en_suspenso boolean,
    unidad_valuacion integer,
    valor_original double precision,
    porcentaje_descuento double precision,
    valor_conversion double precision,
    menor_al_minimo boolean,
    mayor_al_maximo boolean
);


ALTER TABLE sch_gaj.juz_pena_sentencia_backup OWNER TO gaj_owner;

--
-- Name: juz_pena_sentencia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_pena_sentencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_pena_sentencia_id_seq OWNER TO gaj_owner;

--
-- Name: juz_pena_sentencia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_pena_sentencia_id_seq OWNED BY sch_gaj.juz_pena_sentencia.id;


--
-- Name: juz_periodo_cumplimiento_pena; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_periodo_cumplimiento_pena (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    pena_sentencia_id bigint,
    sentencia_activadora_id bigint,
    fecha_inicio timestamp without time zone NOT NULL,
    fecha_fin timestamp without time zone,
    fecha_actualizacion timestamp without time zone,
    motivo_suspenso character varying(255),
    fecha_cumplimiento timestamp without time zone,
    tipo integer NOT NULL
);


ALTER TABLE sch_gaj.juz_periodo_cumplimiento_pena OWNER TO gaj_owner;

--
-- Name: juz_periodo_cumplimiento_pena_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_periodo_cumplimiento_pena_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    pena_sentencia_id bigint,
    sentencia_activadora_id bigint,
    fecha_inicio timestamp without time zone,
    fecha_fin timestamp without time zone,
    fecha_actualizacion timestamp without time zone,
    motivo_suspenso character varying(255),
    fecha_cumplimiento timestamp without time zone,
    tipo integer
);


ALTER TABLE sch_gaj.juz_periodo_cumplimiento_pena_backup OWNER TO gaj_owner;

--
-- Name: juz_periodo_cumplimiento_pena_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_periodo_cumplimiento_pena_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_periodo_cumplimiento_pena_id_seq OWNER TO gaj_owner;

--
-- Name: juz_periodo_cumplimiento_pena_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_periodo_cumplimiento_pena_id_seq OWNED BY sch_gaj.juz_periodo_cumplimiento_pena.id;


--
-- Name: juz_proceso_rebeldia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_proceso_rebeldia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    id_corrida bigint,
    observacion character varying(200),
    cantidad_maxima integer,
    impreso boolean DEFAULT false,
    id_file_detalle character varying(255),
    id_file_errores character varying(255),
    cantidad_de_errores bigint,
    year_bucket character varying(255),
    juez_id bigint,
    result_file character varying(255)
);


ALTER TABLE sch_gaj.juz_proceso_rebeldia OWNER TO gaj_owner;

--
-- Name: juz_proceso_rebeldia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_proceso_rebeldia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_proceso_rebeldia_id_seq OWNER TO gaj_owner;

--
-- Name: juz_proceso_rebeldia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_proceso_rebeldia_id_seq OWNED BY sch_gaj.juz_proceso_rebeldia.id;


--
-- Name: juz_recibo_siat; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_recibo_siat (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    id_recibo_siat bigint,
    nro_recibo bigint,
    codrefpag bigint,
    fecha_vencimiento timestamp without time zone,
    codbarra character varying(255),
    importe_recibo double precision,
    vigente boolean,
    fecha_segundo_vencimiento timestamp without time zone,
    porcentaje_descuento double precision,
    importe_sin_descuento double precision,
    cod_pago_electronico character varying(255)
);


ALTER TABLE sch_gaj.juz_recibo_siat OWNER TO gaj_owner;

--
-- Name: juz_recibo_siat_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_recibo_siat_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    id_recibo_siat bigint,
    nro_recibo bigint,
    codrefpag bigint,
    fecha_vencimiento timestamp without time zone,
    codbarra character varying(255),
    importe_recibo double precision,
    vigente boolean,
    fecha_segundo_vencimiento timestamp without time zone,
    porcentaje_descuento double precision,
    importe_sin_descuento double precision,
    cod_pago_electronico character varying(255)
);


ALTER TABLE sch_gaj.juz_recibo_siat_backup OWNER TO gaj_owner;

--
-- Name: juz_recibo_siat_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_recibo_siat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_recibo_siat_id_seq OWNER TO gaj_owner;

--
-- Name: juz_recibo_siat_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_recibo_siat_id_seq OWNED BY sch_gaj.juz_recibo_siat.id;


--
-- Name: juz_recusacion_excusacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_recusacion_excusacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    juez_apelacion_id bigint NOT NULL,
    fecha_solicitud timestamp without time zone,
    fecha_resolucion timestamp without time zone,
    motivo_solicitud character varying(255),
    tipo integer,
    estado integer,
    imagen_id bigint,
    motivo_resolucion character varying(255),
    imagen_resolucion_id bigint
);


ALTER TABLE sch_gaj.juz_recusacion_excusacion OWNER TO gaj_owner;

--
-- Name: juz_recusacion_excusacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_recusacion_excusacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_recusacion_excusacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_recusacion_excusacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_recusacion_excusacion_id_seq OWNED BY sch_gaj.juz_recusacion_excusacion.id;


--
-- Name: juz_sentencia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(100),
    fecha_sentencia timestamp without time zone,
    justificacion character varying,
    nro_sentencia integer,
    cod_juez integer,
    anio_sentencia integer,
    tipo_juz integer,
    instancia integer,
    estado_sentencia integer,
    juez_id bigint,
    cod_fallo_tmf character varying(20),
    expediente character varying(50),
    norma character varying(100),
    cuij character varying(20),
    sentencia_prov character varying(100)
);


ALTER TABLE sch_gaj.juz_sentencia OWNER TO gaj_owner;

--
-- Name: juz_sentencia_acta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_acta (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    sentencia_id bigint,
    persona_id bigint,
    justificacion character varying(255),
    estado_juzgamiento integer,
    tipo_juzgamiento_id bigint,
    acta_id bigint,
    revision_id bigint,
    instancia integer,
    tasa_fotografica double precision DEFAULT (0)::double precision
);


ALTER TABLE sch_gaj.juz_sentencia_acta OWNER TO gaj_owner;

--
-- Name: juz_sentencia_acta_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_acta_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    sentencia_id bigint,
    persona_id bigint,
    justificacion character varying(255),
    estado_juzgamiento integer,
    tipo_juzgamiento_id bigint,
    acta_id bigint,
    revision_id bigint,
    instancia integer,
    tasa_fotografica double precision
);


ALTER TABLE sch_gaj.juz_sentencia_acta_backup OWNER TO gaj_owner;

--
-- Name: juz_sentencia_acta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_acta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_acta_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_acta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_acta_id_seq OWNED BY sch_gaj.juz_sentencia_acta.id;


--
-- Name: juz_sentencia_anulacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_anulacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    sentencia_id bigint NOT NULL,
    motivo_anulacion character varying(500)
);


ALTER TABLE sch_gaj.juz_sentencia_anulacion OWNER TO gaj_owner;

--
-- Name: juz_sentencia_anulacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_anulacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_anulacion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_anulacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_anulacion_id_seq OWNED BY sch_gaj.juz_sentencia_anulacion.id;


--
-- Name: juz_sentencia_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    descripcion character varying(100),
    fecha_sentencia timestamp without time zone,
    justificacion character varying,
    nro_sentencia integer,
    cod_juez integer,
    anio_sentencia integer,
    tipo_juz integer,
    instancia integer,
    estado_sentencia integer,
    juez_id bigint,
    cod_fallo_tmf character varying(20),
    expediente character varying(50),
    norma character varying(100),
    cuij character varying(20),
    sentencia_prov character varying(100)
);


ALTER TABLE sch_gaj.juz_sentencia_backup OWNER TO gaj_owner;

--
-- Name: juz_sentencia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_id_seq OWNED BY sch_gaj.juz_sentencia.id;


--
-- Name: juz_sentencia_imagen; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_imagen (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    sentencia_id bigint NOT NULL,
    imagen_id bigint NOT NULL
);


ALTER TABLE sch_gaj.juz_sentencia_imagen OWNER TO gaj_owner;

--
-- Name: juz_sentencia_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_imagen_id_seq OWNED BY sch_gaj.juz_sentencia_imagen.id;


--
-- Name: juz_sentencia_imagen_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_imagen_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_imagen_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_imagen_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_imagen_imagen_id_seq OWNED BY sch_gaj.juz_sentencia_imagen.imagen_id;


--
-- Name: juz_sentencia_imagen_sentencia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_imagen_sentencia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_imagen_sentencia_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_imagen_sentencia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_imagen_sentencia_id_seq OWNED BY sch_gaj.juz_sentencia_imagen.sentencia_id;


--
-- Name: juz_sentencia_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint,
    juzgamiento_id bigint,
    accion_juzgamiento_id bigint,
    justificacion character varying(255),
    muerte boolean
);


ALTER TABLE sch_gaj.juz_sentencia_infraccion OWNER TO gaj_owner;

--
-- Name: juz_sentencia_infraccion_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_infraccion_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    infraccion_id bigint,
    juzgamiento_id bigint,
    accion_juzgamiento_id bigint,
    justificacion character varying(255),
    muerte boolean
);


ALTER TABLE sch_gaj.juz_sentencia_infraccion_backup OWNER TO gaj_owner;

--
-- Name: juz_sentencia_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_infraccion_id_seq OWNED BY sch_gaj.juz_sentencia_infraccion.id;


--
-- Name: juz_sentencia_numero_02021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_02021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_02021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_02022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_02022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_02022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_1002021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_1002021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_1002021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_102021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_102021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_102021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_102022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_102022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_102022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_112021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_112021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_112021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_112022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_112022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_112022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_12021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_12021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_12021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_12022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_12022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_12022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_122021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_122021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_122021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_122022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_122022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_122022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_132021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_132021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_132021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_132022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_132022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_132022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_142021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_142021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_142021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_142022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_142022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_142022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_152021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_152021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_152021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_152022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_152022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_152022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_162021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_162021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_162021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_162022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_162022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_162022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_182021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_182021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_182021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_182022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_182022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_182022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_192021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_192021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_192021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_192022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_192022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_192022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_212021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_212021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_212021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_212022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_212022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_212022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_22021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_22021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_22021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_22022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_22022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_22022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_222021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_222021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_222021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_222022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_222022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_222022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_232021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_232021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_232021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_232022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_232022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_232022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_242021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_242021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_242021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_242022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_242022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_242022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_252021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_252021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_252021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_252022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_252022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_252022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_262021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_262021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_262021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_262022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_262022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_262022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_272021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_272021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_272021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_272022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_272022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_272022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_282021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_282021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_282021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_282022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_282022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_282022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_292021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_292021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_292021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_292022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_292022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_292022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_302021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_302021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_302021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_302022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_302022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_302022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_312021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_312021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_312021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_312022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_312022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_312022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_32021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_32021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_32021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_32022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_32022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_32022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_322021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_322021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_322021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_322022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_322022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_322022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_342021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_342021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_342021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_342022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_342022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_342022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_352021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_352021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_352021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_352022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_352022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_352022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_362021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_362021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_362021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_362022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_362022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_362022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_372021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_372021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_372021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_372022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_372022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_372022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_382021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_382021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_382021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_382022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_382022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_382022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_392021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_392021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_392021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_392022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_392022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_392022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_402021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_402021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_402021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_402022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_402022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_402022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_412021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_412021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_412021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_412022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_412022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_412022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_42021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_42021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_42021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_42022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_42022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_42022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_422021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_422021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_422021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_422022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_422022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_422022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_432021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_432021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_432021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_432022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_432022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_432022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_442021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_442021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_442021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_442022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_442022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_442022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_452021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_452021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_452021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_452022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_452022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_452022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_462021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_462021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_462021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_462022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_462022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_462022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_472021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_472021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_472021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_472022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_472022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_472022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_482021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_482021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_482021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_482022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_482022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_482022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_52021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_52021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_52021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_52022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_52022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_52022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_602021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_602021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_602021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_602022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_602022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_602022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_612021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_612021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_612021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_62021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_62021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_62021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_62022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_62022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_62022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_622021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_622021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_622021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_622022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_622022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_622022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_632021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_632021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_632021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_652021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_652021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_652021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_662021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_662021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_662021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_72021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_72021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_72021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_72022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_72022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_72022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_82021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_82021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_82021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_82022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_82022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_82022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_92021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_92021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_92021_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_numero_92022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_numero_92022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_numero_92022_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_proceso_rebeldia; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_proceso_rebeldia (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    proceso_rebeldia_id bigint NOT NULL,
    sentencia_id bigint NOT NULL
);


ALTER TABLE sch_gaj.juz_sentencia_proceso_rebeldia OWNER TO gaj_owner;

--
-- Name: juz_sentencia_proceso_rebeldia_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_proceso_rebeldia_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_proceso_rebeldia_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_proceso_rebeldia_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_proceso_rebeldia_id_seq OWNED BY sch_gaj.juz_sentencia_proceso_rebeldia.id;


--
-- Name: juz_sentencia_tramite; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_sentencia_tramite (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_generacion timestamp without time zone,
    print_data jsonb,
    uuid character varying(40),
    extra_data jsonb,
    sentencia_id bigint,
    persona_id bigint
);


ALTER TABLE sch_gaj.juz_sentencia_tramite OWNER TO gaj_owner;

--
-- Name: juz_sentencia_tramite_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_sentencia_tramite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_sentencia_tramite_id_seq OWNER TO gaj_owner;

--
-- Name: juz_sentencia_tramite_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_sentencia_tramite_id_seq OWNED BY sch_gaj.juz_sentencia_tramite.id;


--
-- Name: juz_tasa_fotografica; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_tasa_fotografica (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone,
    cotizacion real NOT NULL,
    CONSTRAINT juz_tasa_fotografica_cotizacion_check CHECK ((cotizacion > (0)::double precision))
);


ALTER TABLE sch_gaj.juz_tasa_fotografica OWNER TO gaj_owner;

--
-- Name: juz_tasa_fotografica_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_tasa_fotografica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_tasa_fotografica_id_seq OWNER TO gaj_owner;

--
-- Name: juz_tasa_fotografica_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_tasa_fotografica_id_seq OWNED BY sch_gaj.juz_tasa_fotografica.id;


--
-- Name: juz_tipo_juzgamiento; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_tipo_juzgamiento (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(50),
    descripcion character varying(250)
);


ALTER TABLE sch_gaj.juz_tipo_juzgamiento OWNER TO gaj_owner;

--
-- Name: juz_tipo_juzgamiento_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_tipo_juzgamiento_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_tipo_juzgamiento_id_seq OWNER TO gaj_owner;

--
-- Name: juz_tipo_juzgamiento_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_tipo_juzgamiento_id_seq OWNED BY sch_gaj.juz_tipo_juzgamiento.id;


--
-- Name: juz_tribunal_automatico; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_tribunal_automatico (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    juez1_id bigint,
    juez2_id bigint,
    juez3_id bigint,
    juez4_id bigint
);


ALTER TABLE sch_gaj.juz_tribunal_automatico OWNER TO gaj_owner;

--
-- Name: juz_tribunal_automatico_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_tribunal_automatico_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_tribunal_automatico_id_seq OWNER TO gaj_owner;

--
-- Name: juz_tribunal_automatico_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_tribunal_automatico_id_seq OWNED BY sch_gaj.juz_tribunal_automatico.id;


--
-- Name: juz_unidad_fija; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.juz_unidad_fija (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_desde timestamp without time zone,
    fecha_hasta timestamp without time zone,
    cotizacion real NOT NULL,
    CONSTRAINT juz_unidad_fija_cotizacion_check CHECK ((cotizacion > (0)::double precision))
);


ALTER TABLE sch_gaj.juz_unidad_fija OWNER TO gaj_owner;

--
-- Name: juz_unidad_fija_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.juz_unidad_fija_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.juz_unidad_fija_id_seq OWNER TO gaj_owner;

--
-- Name: juz_unidad_fija_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.juz_unidad_fija_id_seq OWNED BY sch_gaj.juz_unidad_fija.id;


--
-- Name: listado_acarreo_view; Type: VIEW; Schema: sch_gaj; Owner: gaj_owner
--

CREATE VIEW sch_gaj.listado_acarreo_view AS
 SELECT row_number() OVER (ORDER BY acarreos.fecha) AS id,
    acarreos.patente,
    acarreos.descripcion,
    acarreos.cantidad,
    acarreos.fecha
   FROM ( SELECT va.patente,
            va.descripcion,
            to_timestamp(to_char(i.fecha_hora_entrada, 'YYYY-MM'::text), 'YYYY-MM'::text) AS fecha,
            count(va.patente) AS cantidad
           FROM (sch_gaj.cor_ingreso i
             JOIN sch_gaj.cor_vehiculoacarreo va ON ((va.id = i.acarreo_id)))
          GROUP BY va.patente, va.descripcion, (to_char(i.fecha_hora_entrada, 'YYYY-MM'::text))) acarreos
  ORDER BY acarreos.cantidad DESC;


ALTER TABLE sch_gaj.listado_acarreo_view OWNER TO gaj_owner;

--
-- Name: listado_tipo_acarreo_view; Type: VIEW; Schema: sch_gaj; Owner: gaj_owner
--

CREATE VIEW sch_gaj.listado_tipo_acarreo_view AS
 SELECT row_number() OVER (ORDER BY tipoacarreos.fecha) AS id,
    tipoacarreos.tipo,
    tipoacarreos.cantidad,
    tipoacarreos.fecha
   FROM ( SELECT
                CASE
                    WHEN (tva.id IS NULL) THEN 'SIN ACARREO'::character varying
                    ELSE tva.descripcion
                END AS tipo,
            to_timestamp(to_char(i.fecha_hora_entrada, 'YYYY-MM'::text), 'YYYY-MM'::text) AS fecha,
            count(i.id) AS cantidad
           FROM ((sch_gaj.cor_ingreso i
             LEFT JOIN sch_gaj.cor_vehiculoacarreo va ON ((va.id = i.acarreo_id)))
             LEFT JOIN sch_gaj.cor_tipovehiculoacarreo tva ON ((tva.id = va.tipo_vehiculo_acarreo_id)))
          GROUP BY tva.id, tva.descripcion, (to_char(i.fecha_hora_entrada, 'YYYY-MM'::text))) tipoacarreos
  ORDER BY tipoacarreos.cantidad DESC;


ALTER TABLE sch_gaj.listado_tipo_acarreo_view OWNER TO gaj_owner;

--
-- Name: pad_tipovehiculo; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_tipovehiculo (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(4),
    descripcion character varying(60)
);


ALTER TABLE sch_gaj.pad_tipovehiculo OWNER TO gaj_owner;

--
-- Name: listado_vehiculo_view; Type: VIEW; Schema: sch_gaj; Owner: gaj_owner
--

CREATE VIEW sch_gaj.listado_vehiculo_view AS
 SELECT row_number() OVER (ORDER BY vista.fecha) AS id,
    vista.descripcion,
    vista.tipo,
    vista.cantidad,
    to_timestamp(vista.fecha, 'YYYY-MM'::text) AS fecha
   FROM ( SELECT tv.descripcion,
            to_char(i.fecha_hora_entrada, 'YYYY-MM'::text) AS fecha,
            count(i.id) AS cantidad,
            'INGRESO'::text AS tipo
           FROM (((sch_gaj.cor_ingreso i
             JOIN sch_gaj.cor_inventario inv ON ((i.id = inv.ingreso_id)))
             JOIN sch_gaj.pad_vehiculo v ON ((v.id = inv.vehiculo_id)))
             JOIN sch_gaj.pad_tipovehiculo tv ON ((tv.id = v.tipo_vehiculo_id)))
          GROUP BY tv.descripcion, (to_char(i.fecha_hora_entrada, 'YYYY-MM'::text))
        UNION
         SELECT tv.descripcion,
            to_char(e.fecha_hora_egreso, 'YYYY-MM'::text) AS fecha,
            count(e.id) AS cantidad,
            'EGRESO'::text AS tipo
           FROM (((sch_gaj.cor_egreso e
             JOIN sch_gaj.cor_inventario inv ON ((e.id = inv.egreso_id)))
             JOIN sch_gaj.pad_vehiculo v ON ((v.id = inv.vehiculo_id)))
             JOIN sch_gaj.pad_tipovehiculo tv ON ((tv.id = v.tipo_vehiculo_id)))
          GROUP BY tv.descripcion, (to_char(e.fecha_hora_egreso, 'YYYY-MM'::text))
        UNION
         SELECT tv.descripcion,
            to_char(i.fecha_hora_entrada, 'YYYY-MM'::text) AS fecha,
            count(inv.id) AS count,
            'INGRESO/EGRESO'::text AS tipo
           FROM ((((sch_gaj.cor_inventario inv
             JOIN sch_gaj.pad_vehiculo v ON ((v.id = inv.vehiculo_id)))
             JOIN sch_gaj.pad_tipovehiculo tv ON ((tv.id = v.tipo_vehiculo_id)))
             JOIN sch_gaj.cor_ingreso i ON ((i.id = inv.ingreso_id)))
             JOIN sch_gaj.cor_egreso e ON ((e.id = inv.egreso_id)))
          WHERE ((inv.ingreso_id IS NOT NULL) AND (inv.egreso_id IS NOT NULL) AND (date_part('month'::text, i.fecha_hora_entrada) = date_part('month'::text, e.fecha_hora_egreso)) AND (date_part('year'::text, i.fecha_hora_entrada) = date_part('year'::text, e.fecha_hora_egreso)))
          GROUP BY tv.descripcion, (to_char(i.fecha_hora_entrada, 'YYYY-MM'::text))) vista
  ORDER BY vista.cantidad DESC;


ALTER TABLE sch_gaj.listado_vehiculo_view OWNER TO gaj_owner;

--
-- Name: mig_rel_siat; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.mig_rel_siat (
    id_deuda integer,
    id_cuenta integer,
    nro_cuenta character(20),
    fecha_pago date,
    cod_recurso character(10),
    recibo_siat_id integer,
    fecha_vto date,
    idcontribuyente integer
);


ALTER TABLE sch_gaj.mig_rel_siat OWNER TO gaj_owner;

--
-- Name: not_areanotificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_areanotificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(100) NOT NULL
);


ALTER TABLE sch_gaj.not_areanotificacion OWNER TO gaj_owner;

--
-- Name: not_areanotificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_areanotificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_areanotificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_areanotificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_areanotificacion_id_seq OWNED BY sch_gaj.not_areanotificacion.id;


--
-- Name: not_auxnotificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_auxnotificacion (
    id bigint NOT NULL,
    version_number bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    tipo_notificacion_id bigint NOT NULL,
    lote_notificacion_id bigint NOT NULL,
    proceso_notificacion_id bigint NOT NULL,
    json_data jsonb NOT NULL,
    domicilio_id bigint,
    persona_id bigint,
    monto_total double precision DEFAULT 0 NOT NULL
);


ALTER TABLE sch_gaj.not_auxnotificacion OWNER TO gaj_owner;

--
-- Name: not_auxnotificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_auxnotificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_auxnotificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_auxnotificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_auxnotificacion_id_seq OWNED BY sch_gaj.not_auxnotificacion.id;


--
-- Name: not_auxnotificaciondetalle; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_auxnotificaciondetalle (
    id bigint NOT NULL,
    version_number bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    tip_obj_not_id bigint NOT NULL,
    auxnotificacion_id bigint,
    entidad_ref_id bigint NOT NULL,
    pago_voluntario boolean DEFAULT false NOT NULL,
    monto double precision DEFAULT 0 NOT NULL,
    porcentaje_descuento double precision DEFAULT 0 NOT NULL
);


ALTER TABLE sch_gaj.not_auxnotificaciondetalle OWNER TO gaj_owner;

--
-- Name: not_auxnotificaciondetalle_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_auxnotificaciondetalle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_auxnotificaciondetalle_id_seq OWNER TO gaj_owner;

--
-- Name: not_auxnotificaciondetalle_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_auxnotificaciondetalle_id_seq OWNED BY sch_gaj.not_auxnotificaciondetalle.id;


--
-- Name: not_estadonotificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_estadonotificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    version_number bigint NOT NULL,
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    descripcion character varying(150) NOT NULL,
    es_final boolean NOT NULL,
    es_inicial boolean NOT NULL,
    estados_previos character varying(50),
    transiciones character varying(50)
);


ALTER TABLE sch_gaj.not_estadonotificacion OWNER TO gaj_owner;

--
-- Name: not_estadonotificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_estadonotificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_estadonotificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_estadonotificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_estadonotificacion_id_seq OWNED BY sch_gaj.not_estadonotificacion.id;


--
-- Name: not_grupo_notificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_grupo_notificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    descripcion character varying(150)
);


ALTER TABLE sch_gaj.not_grupo_notificacion OWNER TO gaj_owner;

--
-- Name: not_grupo_notificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_grupo_notificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_grupo_notificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_grupo_notificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_grupo_notificacion_id_seq OWNED BY sch_gaj.not_grupo_notificacion.id;


--
-- Name: not_grupo_notificacion_localidad; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_grupo_notificacion_localidad (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    localidad character varying(150),
    grupo_notificacion_id bigint,
    cod_postal bigint,
    sub_postal integer
);


ALTER TABLE sch_gaj.not_grupo_notificacion_localidad OWNER TO gaj_owner;

--
-- Name: not_grupo_notificacion_localidad_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_grupo_notificacion_localidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_grupo_notificacion_localidad_id_seq OWNER TO gaj_owner;

--
-- Name: not_grupo_notificacion_localidad_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_grupo_notificacion_localidad_id_seq OWNED BY sch_gaj.not_grupo_notificacion_localidad.id;


--
-- Name: not_hisestnot; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_hisestnot (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    deleted boolean NOT NULL,
    creation_user character varying(255),
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    log_cambio character varying(255),
    estado_actual_id bigint NOT NULL,
    notificacion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.not_hisestnot OWNER TO gaj_owner;

--
-- Name: not_hisestnot_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_hisestnot_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    deleted boolean,
    creation_user character varying(255),
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    log_cambio character varying(255),
    estado_actual_id bigint,
    notificacion_id bigint
);


ALTER TABLE sch_gaj.not_hisestnot_backup OWNER TO gaj_owner;

--
-- Name: not_hisestnot_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_hisestnot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_hisestnot_id_seq OWNER TO gaj_owner;

--
-- Name: not_hisestnot_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_hisestnot_id_seq OWNED BY sch_gaj.not_hisestnot.id;


--
-- Name: not_lotenotificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_lotenotificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    deleted boolean NOT NULL,
    creation_user character varying(255),
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    proceso_notificacion_id bigint NOT NULL,
    zona_notificacion_id bigint,
    observacion character varying(200),
    impreso boolean DEFAULT false,
    total_notificacion bigint,
    monto_total double precision,
    id_file character varying(255),
    total_notificacion_aux bigint,
    monto_total_aux double precision,
    impreso_el_dia timestamp without time zone,
    impreso_por character varying(50)
);


ALTER TABLE sch_gaj.not_lotenotificacion OWNER TO gaj_owner;

--
-- Name: not_lotenotificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_lotenotificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_lotenotificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_lotenotificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_lotenotificacion_id_seq OWNED BY sch_gaj.not_lotenotificacion.id;


--
-- Name: not_notificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_notificacion (
    id bigint NOT NULL,
    codigo bigint NOT NULL,
    version_number bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    tipo_notificacion_id bigint NOT NULL,
    estado_notificacion_id bigint NOT NULL,
    lote_notificacion_id bigint,
    observacion character varying(250),
    persona_id bigint,
    domicilio_id bigint,
    notificador_id bigint,
    json_data jsonb NOT NULL,
    electronica boolean DEFAULT false,
    fechafehaciente timestamp without time zone,
    email character varying(100),
    fecha_fehaciente timestamp without time zone,
    origen_notificacion integer,
    numero_asig_notificador bigint,
    codigo_oblea_correo character varying(32) DEFAULT NULL::character varying
);


ALTER TABLE sch_gaj.not_notificacion OWNER TO gaj_owner;

--
-- Name: not_notificacion_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_notificacion_backup (
    id bigint,
    codigo bigint,
    version_number bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    tipo_notificacion_id bigint,
    estado_notificacion_id bigint,
    lote_notificacion_id bigint,
    observacion character varying(250),
    persona_id bigint,
    domicilio_id bigint,
    notificador_id bigint,
    json_data jsonb,
    electronica boolean,
    fechafehaciente timestamp without time zone,
    email character varying(100),
    fecha_fehaciente timestamp without time zone,
    origen_notificacion integer,
    numero_asig_notificador bigint,
    codigo_oblea_correo character varying(32)
);


ALTER TABLE sch_gaj.not_notificacion_backup OWNER TO gaj_owner;

--
-- Name: not_notificacion_codigo_2020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_notificacion_codigo_2020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_notificacion_codigo_2020_seq OWNER TO gaj_owner;

--
-- Name: not_notificacion_codigo_2021_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_notificacion_codigo_2021_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_notificacion_codigo_2021_seq OWNER TO gaj_owner;

--
-- Name: not_notificacion_codigo_2022_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_notificacion_codigo_2022_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_notificacion_codigo_2022_seq OWNER TO gaj_owner;

--
-- Name: not_notificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_notificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_notificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_notificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_notificacion_id_seq OWNED BY sch_gaj.not_notificacion.id;


--
-- Name: not_notificacion_imagen; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_notificacion_imagen (
    id bigint NOT NULL,
    version_number bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    notificacion_id bigint NOT NULL,
    imagen_id bigint NOT NULL,
    descripcion character varying(255)
);


ALTER TABLE sch_gaj.not_notificacion_imagen OWNER TO gaj_owner;

--
-- Name: not_notificacion_imagen_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_notificacion_imagen_backup (
    id bigint,
    version_number bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    notificacion_id bigint,
    imagen_id bigint,
    descripcion character varying(255)
);


ALTER TABLE sch_gaj.not_notificacion_imagen_backup OWNER TO gaj_owner;

--
-- Name: not_notificacion_imagen_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_notificacion_imagen_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_notificacion_imagen_id_seq OWNER TO gaj_owner;

--
-- Name: not_notificacion_imagen_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_notificacion_imagen_id_seq OWNED BY sch_gaj.not_notificacion_imagen.id;


--
-- Name: not_notificaciondetalle; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_notificaciondetalle (
    id bigint NOT NULL,
    version_number bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    tip_obj_not_id bigint NOT NULL,
    notificacion_id bigint,
    entidad_ref_id bigint NOT NULL,
    anulada boolean DEFAULT false NOT NULL
);


ALTER TABLE sch_gaj.not_notificaciondetalle OWNER TO gaj_owner;

--
-- Name: not_notificaciondetalle_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_notificaciondetalle_backup (
    id bigint,
    version_number bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    tip_obj_not_id bigint,
    notificacion_id bigint,
    entidad_ref_id bigint,
    anulada boolean
);


ALTER TABLE sch_gaj.not_notificaciondetalle_backup OWNER TO gaj_owner;

--
-- Name: not_notificaciondetalle_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_notificaciondetalle_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_notificaciondetalle_id_seq OWNER TO gaj_owner;

--
-- Name: not_notificaciondetalle_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_notificaciondetalle_id_seq OWNED BY sch_gaj.not_notificaciondetalle.id;


--
-- Name: not_notificador; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_notificador (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero_legajo character varying(100) NOT NULL,
    persona_id bigint NOT NULL,
    area_notificacion_id bigint NOT NULL,
    nombre_y_apellido character varying(150),
    notifica_fuera_rosario boolean DEFAULT false
);


ALTER TABLE sch_gaj.not_notificador OWNER TO gaj_owner;

--
-- Name: not_notificador_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_notificador_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_notificador_id_seq OWNER TO gaj_owner;

--
-- Name: not_notificador_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_notificador_id_seq OWNED BY sch_gaj.not_notificador.id;


--
-- Name: not_procesonotificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_procesonotificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tipo_notificacion_id bigint NOT NULL,
    id_corrida bigint,
    observacion character varying(200),
    cantidad_maxima integer,
    fecha_desde date,
    fecha_hasta date,
    codigo_postal integer,
    is_cedula boolean DEFAULT false NOT NULL,
    impreso boolean DEFAULT false,
    total_notificacion bigint,
    monto_total double precision,
    id_file_detalle character varying(255),
    id_file_errores character varying(255),
    monto_de_errores double precision,
    cantidad_de_errores bigint,
    alcance_notificacion integer,
    grupo_notificacion_id bigint,
    codigo_sub_postal integer
);


ALTER TABLE sch_gaj.not_procesonotificacion OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_procesonotificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_procesonotificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_procesonotificacion_id_seq OWNED BY sch_gaj.not_procesonotificacion.id;


--
-- Name: not_procesonotificacion_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_procesonotificacion_infraccion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    proceso_notificacion_id bigint NOT NULL,
    infraccion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.not_procesonotificacion_infraccion OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_infraccion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_procesonotificacion_infraccion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_procesonotificacion_infraccion_id_seq OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_infraccion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_procesonotificacion_infraccion_id_seq OWNED BY sch_gaj.not_procesonotificacion_infraccion.id;


--
-- Name: not_procesonotificacion_objeto; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_procesonotificacion_objeto (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    proceso_notificacion_id bigint NOT NULL,
    tipo_objeto_id bigint NOT NULL
);


ALTER TABLE sch_gaj.not_procesonotificacion_objeto OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_objeto_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_procesonotificacion_objeto_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_procesonotificacion_objeto_id_seq OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_objeto_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_procesonotificacion_objeto_id_seq OWNED BY sch_gaj.not_procesonotificacion_objeto.id;


--
-- Name: not_procesonotificacion_reparticion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_procesonotificacion_reparticion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    proceso_notificacion_id bigint NOT NULL,
    reparticion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.not_procesonotificacion_reparticion OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_reparticion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_procesonotificacion_reparticion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_procesonotificacion_reparticion_id_seq OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_reparticion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_procesonotificacion_reparticion_id_seq OWNED BY sch_gaj.not_procesonotificacion_reparticion.id;


--
-- Name: not_procesonotificacion_zona; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_procesonotificacion_zona (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    proceso_notificacion_id bigint NOT NULL,
    zona_notificacion_id bigint NOT NULL
);


ALTER TABLE sch_gaj.not_procesonotificacion_zona OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_zona_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_procesonotificacion_zona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_procesonotificacion_zona_id_seq OWNER TO gaj_owner;

--
-- Name: not_procesonotificacion_zona_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_procesonotificacion_zona_id_seq OWNED BY sch_gaj.not_procesonotificacion_zona.id;


--
-- Name: not_registro_servicios_publicos; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_registro_servicios_publicos (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone,
    clave_objeto character varying(50) NOT NULL,
    tipo_objeto_id bigint,
    cuit_notificar character varying(20),
    persona_id_notificar bigint NOT NULL,
    domicilio_id bigint
);


ALTER TABLE sch_gaj.not_registro_servicios_publicos OWNER TO gaj_owner;

--
-- Name: not_registro_servicios_publicos_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_registro_servicios_publicos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_registro_servicios_publicos_id_seq OWNER TO gaj_owner;

--
-- Name: not_registro_servicios_publicos_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_registro_servicios_publicos_id_seq OWNED BY sch_gaj.not_registro_servicios_publicos.id;


--
-- Name: not_tipobjnot; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_tipobjnot (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    tabla character varying(100) NOT NULL,
    descripcion character varying(150) NOT NULL
);


ALTER TABLE sch_gaj.not_tipobjnot OWNER TO gaj_owner;

--
-- Name: not_tipobjnot_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_tipobjnot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_tipobjnot_id_seq OWNER TO gaj_owner;

--
-- Name: not_tipobjnot_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_tipobjnot_id_seq OWNED BY sch_gaj.not_tipobjnot.id;


--
-- Name: not_tiponotificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_tiponotificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    version_number bigint NOT NULL,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    codigo character varying(50) NOT NULL,
    tip_obj_not_id bigint NOT NULL,
    formulario_id bigint NOT NULL,
    descripcion character varying(150) NOT NULL,
    electronica boolean DEFAULT false NOT NULL
);


ALTER TABLE sch_gaj.not_tiponotificacion OWNER TO gaj_owner;

--
-- Name: not_tiponotificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_tiponotificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_tiponotificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_tiponotificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_tiponotificacion_id_seq OWNED BY sch_gaj.not_tiponotificacion.id;


--
-- Name: not_zonanotificacion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.not_zonanotificacion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    modification_timestamp timestamp without time zone,
    creation_user character varying(255),
    modification_user character varying(255),
    deleted boolean NOT NULL,
    version_number bigint NOT NULL,
    mslink integer,
    dato character varying(3),
    observacio character varying(1),
    type character varying(31),
    geom public.geometry(MultiPolygon)
);


ALTER TABLE sch_gaj.not_zonanotificacion OWNER TO gaj_owner;

--
-- Name: not_zonanotificacion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.not_zonanotificacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.not_zonanotificacion_id_seq OWNER TO gaj_owner;

--
-- Name: not_zonanotificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.not_zonanotificacion_id_seq OWNED BY sch_gaj.not_zonanotificacion.id;


--
-- Name: pad_agente; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_agente (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuario_id bigint,
    persona_id bigint,
    nombre_y_apellido character varying(150)
);


ALTER TABLE sch_gaj.pad_agente OWNER TO gaj_owner;

--
-- Name: novedad_libro_view; Type: VIEW; Schema: sch_gaj; Owner: gaj_owner
--

CREATE VIEW sch_gaj.novedad_libro_view AS
 SELECT row_number() OVER (ORDER BY ien.fecha) AS id,
    ien.tipo,
    inventario.nro_inventario AS nroinventario,
    ien.idage AS idagente,
    persona.id_persona AS idpersonaagente,
    vehiculo.patente,
    ien.fecha,
    ien.obs,
    tc.nombre AS tipocorralon
   FROM (((((( SELECT 'INGRESO'::text AS tipo,
            inv.id AS idinv,
            i.fecha_hora_entrada AS fecha,
            i.agente_id AS idage,
            i.observaciones AS obs,
            inv.tipo_corralon_id AS idcorralon
           FROM (sch_gaj.cor_ingreso i
             JOIN sch_gaj.cor_inventario inv ON ((i.id = inv.ingreso_id)))
        UNION
         SELECT 'EGRESO'::text AS tipo,
            inv.id AS idinv,
            e.fecha_hora_egreso AS fecha,
            e.agente_id AS idage,
            e.observaciones AS obs,
            inv.tipo_corralon_id AS idcorralon
           FROM (sch_gaj.cor_egreso e
             JOIN sch_gaj.cor_inventario inv ON ((e.id = inv.egreso_id)))
        UNION
         SELECT 'NOVEDAD'::text AS tipo,
            n.inventario_id AS idinv,
            n.fecha_hora AS fecha,
            n.agente_id AS idage,
            n.novedad AS obs,
            inv.tipo_corralon_id AS idcorralon
           FROM (sch_gaj.cor_novedad n
             JOIN sch_gaj.cor_inventario inv ON ((n.inventario_id = inv.id)))
        UNION
         SELECT 'TRASLADOINI'::text AS tipo,
            inv.id AS idinv,
            ti.fecha_hora AS fecha,
            ti.agente_id AS idage,
            ti.observaciones AS obs,
            t.corralon_origen_id AS idcorralon
           FROM (((sch_gaj.cor_iniciotraslado ti
             JOIN sch_gaj.cor_traslado t ON ((ti.id = t.inicio_traslado_id)))
             JOIN sch_gaj.cor_traslado_traslado_inventarios tinv ON ((t.id = tinv.traslado_id)))
             JOIN sch_gaj.cor_inventario inv ON ((tinv.inventario_id = inv.id)))
          WHERE ((tinv.aceptado_en_recepcion_traslado = true) OR (tinv.aceptado_en_recepcion_traslado IS NULL))
        UNION
         SELECT 'TRASLADOFIN'::text AS tipo,
            inv.id AS idinv,
            tr.fecha,
            tr.agente_id AS idage,
            tr.observaciones AS obs,
            t.corralon_destino_id AS idcorralon
           FROM (((sch_gaj.cor_recepciontraslado tr
             JOIN sch_gaj.cor_traslado t ON ((tr.id = t.recepcion_traslado_id)))
             JOIN sch_gaj.cor_traslado_traslado_inventarios tinv ON ((t.id = tinv.traslado_id)))
             JOIN sch_gaj.cor_inventario inv ON ((tinv.inventario_id = inv.id)))
          WHERE ((tinv.aceptado_en_recepcion_traslado = true) OR (tinv.aceptado_en_recepcion_traslado IS NULL))) ien
     JOIN sch_gaj.cor_inventario inventario ON ((inventario.id = ien.idinv)))
     JOIN sch_gaj.pad_vehiculo vehiculo ON ((vehiculo.id = inventario.vehiculo_id)))
     JOIN sch_gaj.pad_agente agente ON ((agente.id = ien.idage)))
     JOIN sch_gaj.cor_tipocorralon tc ON ((tc.id = ien.idcorralon)))
     JOIN sch_gaj.pad_persona persona ON ((persona.id = agente.persona_id)))
  ORDER BY ien.fecha DESC;


ALTER TABLE sch_gaj.novedad_libro_view OWNER TO gaj_owner;

--
-- Name: pad_agente_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_agente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_agente_id_seq OWNER TO gaj_owner;

--
-- Name: pad_agente_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_agente_id_seq OWNED BY sch_gaj.pad_agente.id;


--
-- Name: pad_agente_reparticion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_agente_reparticion (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    agente_id bigint NOT NULL,
    reparticion_id bigint NOT NULL,
    codigo_agente bigint NOT NULL,
    tipo_agente character varying(255)
);


ALTER TABLE sch_gaj.pad_agente_reparticion OWNER TO gaj_owner;

--
-- Name: pad_agente_reparticion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_agente_reparticion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_agente_reparticion_id_seq OWNER TO gaj_owner;

--
-- Name: pad_agente_reparticion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_agente_reparticion_id_seq OWNED BY sch_gaj.pad_agente_reparticion.id;


--
-- Name: pad_autorizado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_autorizado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    persona_id bigint
);


ALTER TABLE sch_gaj.pad_autorizado OWNER TO gaj_owner;

--
-- Name: pad_autorizado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_autorizado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_autorizado_id_seq OWNER TO gaj_owner;

--
-- Name: pad_autorizado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_autorizado_id_seq OWNED BY sch_gaj.pad_autorizado.id;


--
-- Name: pad_juez; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_juez (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo bigint,
    usuario_id bigint,
    persona_id bigint,
    prefijo character varying(10),
    juzgado_id bigint,
    nombre_y_apellido character varying(150),
    fecha_baja date
);


ALTER TABLE sch_gaj.pad_juez OWNER TO gaj_owner;

--
-- Name: pad_juez_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_juez_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_juez_id_seq OWNER TO gaj_owner;

--
-- Name: pad_juez_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_juez_id_seq OWNED BY sch_gaj.pad_juez.id;


--
-- Name: pad_juzgado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_juzgado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero integer NOT NULL,
    descripcion character varying(255) NOT NULL
);


ALTER TABLE sch_gaj.pad_juzgado OWNER TO gaj_owner;

--
-- Name: pad_juzgado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_juzgado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_juzgado_id_seq OWNER TO gaj_owner;

--
-- Name: pad_juzgado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_juzgado_id_seq OWNED BY sch_gaj.pad_juzgado.id;


--
-- Name: pad_persona_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_persona_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    id_persona bigint
);


ALTER TABLE sch_gaj.pad_persona_backup OWNER TO gaj_owner;

--
-- Name: pad_persona_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_persona_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_persona_id_seq OWNER TO gaj_owner;

--
-- Name: pad_persona_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_persona_id_seq OWNED BY sch_gaj.pad_persona.id;


--
-- Name: pad_tipovehiculo_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_tipovehiculo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_tipovehiculo_id_seq OWNER TO gaj_owner;

--
-- Name: pad_tipovehiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_tipovehiculo_id_seq OWNED BY sch_gaj.pad_tipovehiculo.id;


--
-- Name: pad_titular; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_titular (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    persona_id bigint
);


ALTER TABLE sch_gaj.pad_titular OWNER TO gaj_owner;

--
-- Name: pad_titular_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_titular_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_titular_id_seq OWNER TO gaj_owner;

--
-- Name: pad_titular_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_titular_id_seq OWNED BY sch_gaj.pad_titular.id;


--
-- Name: pad_vehiculo_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    color character varying(10),
    marca character varying(50),
    modelo character varying(10),
    nro_chasis character varying(20),
    nro_motor character varying(20),
    patente character varying(10),
    patente_ficticia_migracion character varying(10),
    tiene_patente boolean,
    usuario_operacion character varying(20),
    habilitado boolean,
    fuente character varying(25),
    confiabilidad character varying(25),
    modelo_anio integer,
    tipo_vehiculo_id bigint NOT NULL
);


ALTER TABLE sch_gaj.pad_vehiculo_audit OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_audit_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_vehiculo_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_vehiculo_audit_id_seq OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_vehiculo_audit_id_seq OWNED BY sch_gaj.pad_vehiculo_audit.id;


--
-- Name: pad_vehiculo_autorizado; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_autorizado (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    vehiculo_id bigint NOT NULL,
    autorizado_id bigint NOT NULL,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone,
    nro_tarjeta_azul character varying(255)
);


ALTER TABLE sch_gaj.pad_vehiculo_autorizado OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_autorizado_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_autorizado_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    vehiculo_id bigint NOT NULL,
    autorizado_id bigint NOT NULL,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone,
    nro_tarjeta_azul character varying(255)
);


ALTER TABLE sch_gaj.pad_vehiculo_autorizado_audit OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_autorizado_audit_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_vehiculo_autorizado_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_vehiculo_autorizado_audit_id_seq OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_autorizado_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_vehiculo_autorizado_audit_id_seq OWNED BY sch_gaj.pad_vehiculo_autorizado_audit.id;


--
-- Name: pad_vehiculo_autorizado_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_vehiculo_autorizado_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_vehiculo_autorizado_id_seq OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_autorizado_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_vehiculo_autorizado_id_seq OWNED BY sch_gaj.pad_vehiculo_autorizado.id;


--
-- Name: pad_vehiculo_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    color character varying(10),
    marca character varying(50),
    modelo character varying(10),
    nro_chasis character varying(20),
    nro_motor character varying(20),
    patente character varying(10),
    patente_ficticia_migracion character varying(10),
    tiene_patente boolean,
    usuario_operacion character varying(20),
    tipo_vehiculo_id bigint,
    habilitado boolean,
    fuente character varying(25),
    confiabilidad character varying(25),
    modelo_anio integer
);


ALTER TABLE sch_gaj.pad_vehiculo_backup OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_hist; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_hist (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    color character varying(10),
    marca character varying(20),
    modelo character varying(10),
    nro_chasis character varying(20),
    nro_motor character varying(20),
    patente character varying(10),
    patente_ficticia_migracion character varying(10),
    tiene_patente boolean,
    usuario_operacion character varying(20),
    tipo_vehiculo_id bigint NOT NULL,
    vehiculo_id bigint
);


ALTER TABLE sch_gaj.pad_vehiculo_hist OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_hist_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_vehiculo_hist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_vehiculo_hist_id_seq OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_hist_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_vehiculo_hist_id_seq OWNED BY sch_gaj.pad_vehiculo_hist.id;


--
-- Name: pad_vehiculo_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_vehiculo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_vehiculo_id_seq OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_vehiculo_id_seq OWNED BY sch_gaj.pad_vehiculo.id;


--
-- Name: pad_vehiculo_titular; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_titular (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    vehiculo_id bigint NOT NULL,
    titular_id bigint NOT NULL,
    domicilio_id bigint,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone,
    es_principal boolean,
    es_poseedor boolean,
    nro_tarjeta_verde character varying(255),
    denuncia_venta boolean,
    fecha_denuncia_venta timestamp without time zone
);


ALTER TABLE sch_gaj.pad_vehiculo_titular OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_titular_audit; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_titular_audit (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    vehiculo_id bigint NOT NULL,
    titular_id bigint NOT NULL,
    fecha_desde timestamp without time zone NOT NULL,
    fecha_hasta timestamp without time zone,
    es_principal boolean,
    es_poseedor boolean,
    nro_tarjeta_verde character varying(255),
    denuncia_venta boolean,
    fecha_denuncia_venta timestamp without time zone
);


ALTER TABLE sch_gaj.pad_vehiculo_titular_audit OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_titular_audit_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_vehiculo_titular_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_vehiculo_titular_audit_id_seq OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_titular_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_vehiculo_titular_audit_id_seq OWNED BY sch_gaj.pad_vehiculo_titular_audit.id;


--
-- Name: pad_vehiculo_titular_backup; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pad_vehiculo_titular_backup (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    vehiculo_id bigint,
    titular_id bigint,
    domicilio_id bigint,
    fecha_desde timestamp without time zone,
    fecha_hasta timestamp without time zone,
    es_principal boolean,
    es_poseedor boolean,
    nro_tarjeta_verde character varying(255),
    denuncia_venta boolean,
    fecha_denuncia_venta timestamp without time zone
);


ALTER TABLE sch_gaj.pad_vehiculo_titular_backup OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_titular_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pad_vehiculo_titular_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pad_vehiculo_titular_id_seq OWNER TO gaj_owner;

--
-- Name: pad_vehiculo_titular_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pad_vehiculo_titular_id_seq OWNED BY sch_gaj.pad_vehiculo_titular.id;


--
-- Name: pro_corrida; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_corrida (
    id bigint NOT NULL,
    descorrida character varying(255) NOT NULL,
    idproceso bigint NOT NULL,
    fechainicio timestamp without time zone,
    fechafin timestamp without time zone,
    fechaultresume timestamp without time zone,
    idestadocorrida bigint NOT NULL,
    mensajeestado character varying(4000),
    observacion character varying(255),
    pasoactual smallint NOT NULL,
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL,
    nodoowner character varying(120)
);


ALTER TABLE sch_gaj.pro_corrida OWNER TO gaj_owner;

--
-- Name: pro_corrida_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_corrida_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_corrida_id_seq OWNER TO gaj_owner;

--
-- Name: pro_corrida_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_corrida_id_seq OWNED BY sch_gaj.pro_corrida.id;


--
-- Name: pro_estadocorrida; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_estadocorrida (
    id bigint NOT NULL,
    desestadocorrida character varying(100) NOT NULL,
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL
);


ALTER TABLE sch_gaj.pro_estadocorrida OWNER TO gaj_owner;

--
-- Name: pro_estadocorrida_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_estadocorrida_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_estadocorrida_id_seq OWNER TO gaj_owner;

--
-- Name: pro_estadocorrida_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_estadocorrida_id_seq OWNED BY sch_gaj.pro_estadocorrida.id;


--
-- Name: pro_filecorrida; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_filecorrida (
    id bigint NOT NULL,
    idcorrida bigint NOT NULL,
    paso smallint NOT NULL,
    filename character varying(255),
    nombre character varying(100),
    observacion character varying(255),
    orden integer,
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL,
    ctdregistros integer
);


ALTER TABLE sch_gaj.pro_filecorrida OWNER TO gaj_owner;

--
-- Name: pro_filecorrida_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_filecorrida_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_filecorrida_id_seq OWNER TO gaj_owner;

--
-- Name: pro_filecorrida_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_filecorrida_id_seq OWNED BY sch_gaj.pro_filecorrida.id;


--
-- Name: pro_logcorrida; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_logcorrida (
    id bigint NOT NULL,
    idcorrida bigint NOT NULL,
    paso integer NOT NULL,
    fecha timestamp without time zone NOT NULL,
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone,
    estado smallint NOT NULL,
    log character varying(32000)
);


ALTER TABLE sch_gaj.pro_logcorrida OWNER TO gaj_owner;

--
-- Name: pro_logcorrida_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_logcorrida_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_logcorrida_id_seq OWNER TO gaj_owner;

--
-- Name: pro_logcorrida_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_logcorrida_id_seq OWNED BY sch_gaj.pro_logcorrida.id;


--
-- Name: pro_pasocorrida; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_pasocorrida (
    id bigint NOT NULL,
    idcorrida bigint NOT NULL,
    paso smallint NOT NULL,
    fechacorrida timestamp without time zone,
    idestadocorrida bigint NOT NULL,
    observacion character varying(4000),
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL
);


ALTER TABLE sch_gaj.pro_pasocorrida OWNER TO gaj_owner;

--
-- Name: pro_pasocorrida_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_pasocorrida_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_pasocorrida_id_seq OWNER TO gaj_owner;

--
-- Name: pro_pasocorrida_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_pasocorrida_id_seq OWNED BY sch_gaj.pro_pasocorrida.id;


--
-- Name: pro_proceso; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_proceso (
    id bigint NOT NULL,
    codproceso character varying(100),
    desproceso character varying(100) NOT NULL,
    esasincronico smallint NOT NULL,
    idtipoejecucion bigint NOT NULL,
    directorioinput character varying(255),
    cantpasos integer NOT NULL,
    idtipoprogejec bigint NOT NULL,
    classforname character varying(255),
    spvalidate character varying(255),
    spexecute character varying(255),
    spresume character varying(255),
    spcancel character varying(255),
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL,
    ejecnodo character varying(255),
    locked smallint,
    cronexpression character varying(100),
    cantcorridasperm smallint,
    period smallint
);


ALTER TABLE sch_gaj.pro_proceso OWNER TO gaj_owner;

--
-- Name: pro_proceso_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_proceso_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_proceso_id_seq OWNER TO gaj_owner;

--
-- Name: pro_proceso_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_proceso_id_seq OWNED BY sch_gaj.pro_proceso.id;


--
-- Name: pro_procesoatrval; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_procesoatrval (
    id bigint NOT NULL,
    idproceso bigint NOT NULL,
    idatributo bigint NOT NULL,
    strvalor character varying(255),
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL
);


ALTER TABLE sch_gaj.pro_procesoatrval OWNER TO gaj_owner;

--
-- Name: pro_procesoatrval_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_procesoatrval_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_procesoatrval_id_seq OWNER TO gaj_owner;

--
-- Name: pro_procesoatrval_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_procesoatrval_id_seq OWNED BY sch_gaj.pro_procesoatrval.id;


--
-- Name: pro_procesoparval; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_procesoparval (
    id bigint NOT NULL,
    idcorrida bigint NOT NULL,
    strvalor character varying(12000),
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL,
    codparval character varying(60),
    estemporal smallint
);


ALTER TABLE sch_gaj.pro_procesoparval OWNER TO gaj_owner;

--
-- Name: pro_procesoparval_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_procesoparval_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_procesoparval_id_seq OWNER TO gaj_owner;

--
-- Name: pro_procesoparval_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_procesoparval_id_seq OWNED BY sch_gaj.pro_procesoparval.id;


--
-- Name: pro_procesotablas; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_procesotablas (
    proceso character varying(20),
    nom_tabla character varying(20),
    nom_campo character varying(20),
    accion character varying(10),
    orden_leer smallint,
    usuario character varying(10),
    fecha_hora timestamp without time zone
);


ALTER TABLE sch_gaj.pro_procesotablas OWNER TO gaj_owner;

--
-- Name: pro_tipoejecucion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_tipoejecucion (
    id bigint NOT NULL,
    destipoejecucion character varying(40) NOT NULL,
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL
);


ALTER TABLE sch_gaj.pro_tipoejecucion OWNER TO gaj_owner;

--
-- Name: pro_tipoejecucion_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_tipoejecucion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_tipoejecucion_id_seq OWNER TO gaj_owner;

--
-- Name: pro_tipoejecucion_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_tipoejecucion_id_seq OWNED BY sch_gaj.pro_tipoejecucion.id;


--
-- Name: pro_tipoprogejec; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_tipoprogejec (
    id bigint NOT NULL,
    destipoprogejec character varying(40) NOT NULL,
    usuario character varying(60) NOT NULL,
    fechaultmdf timestamp without time zone NOT NULL,
    estado smallint NOT NULL
);


ALTER TABLE sch_gaj.pro_tipoprogejec OWNER TO gaj_owner;

--
-- Name: pro_tipoprogejec_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_tipoprogejec_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_tipoprogejec_id_seq OWNER TO gaj_owner;

--
-- Name: pro_tipoprogejec_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_tipoprogejec_id_seq OWNED BY sch_gaj.pro_tipoprogejec.id;


--
-- Name: pro_unifcta; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.pro_unifcta (
    id bigint NOT NULL,
    idctaok bigint,
    nom_tabla character varying(20),
    accion character varying(10),
    cuantos smallint,
    usuario character varying(10),
    fecha_hora timestamp without time zone
);


ALTER TABLE sch_gaj.pro_unifcta OWNER TO gaj_owner;

--
-- Name: pro_unifcta_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.pro_unifcta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.pro_unifcta_id_seq OWNER TO gaj_owner;

--
-- Name: pro_unifcta_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.pro_unifcta_id_seq OWNED BY sch_gaj.pro_unifcta.id;


--
-- Name: select * from com_detalle_objeto_audit cdoa  where   substr(cla; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj."select * from com_detalle_objeto_audit cdoa 
where 
 substr(cla" (
    id bigint NOT NULL,
    revision_id integer NOT NULL,
    revision_type smallint,
    tipo_id bigint,
    valores jsonb,
    detalles jsonb,
    acta_id bigint,
    domicilio_id bigint,
    observaciones character varying,
    clave character varying,
    clave_secundaria character varying,
    entidad_id bigint
);


ALTER TABLE sch_gaj."select * from com_detalle_objeto_audit cdoa 
where 
 substr(cla" OWNER TO gaj_owner;

--
-- Name: tmp_correccion_patente; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_correccion_patente (
    patente character varying(10),
    id_malo bigint,
    id_bueno bigint
);


ALTER TABLE sch_gaj.tmp_correccion_patente OWNER TO gaj_owner;

--
-- Name: tmp_ctrl; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_ctrl (
    t_acta integer,
    nro_acta integer,
    serie character(1),
    accion_gaj character(1)
);


ALTER TABLE sch_gaj.tmp_ctrl OWNER TO gaj_owner;

--
-- Name: tmp_datos_domicilio; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_datos_domicilio (
    objeto_id bigint,
    tipo_objeto character varying(20),
    objeto character varying(500),
    acta_id bigint,
    t_acta integer,
    nro_acta bigint,
    serie character varying(2),
    fecha_acta timestamp without time zone,
    lugar_acta_id bigint,
    ref_geografica character varying(255),
    cant_encontradas integer,
    cod_calle character varying(10),
    nom_calle character varying(50),
    cod_intersec character varying(10),
    nom_intersec character varying(50),
    altura character varying(10),
    letra_a character varying(5),
    bis_a character varying(10),
    sec character varying(2),
    mnz character varying(3),
    gra character varying(3),
    div character varying(3),
    sdiv character varying(3),
    carpeta character varying(10),
    catastral character varying(25)
);


ALTER TABLE sch_gaj.tmp_datos_domicilio OWNER TO gaj_owner;

--
-- Name: tmp_pate_prov; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_pate_prov (
    patente character varying(10),
    id_persona bigint,
    modelo character varying(3),
    fecha character varying(10),
    usuario character varying(10),
    fecha_hora character varying(50),
    a character varying(50),
    b character varying(50)
);


ALTER TABLE sch_gaj.tmp_pate_prov OWNER TO gaj_owner;

--
-- Name: tmp_unl_actas; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_unl_actas (
    tipoacta bigint,
    numero bigint,
    serie character varying,
    anioacta character varying,
    fechaalta character varying,
    horaalta character varying,
    proposito character varying,
    fechaacta character varying,
    horaacta character varying,
    agente bigint,
    tipoinfraccion character varying,
    idpersona character varying,
    idpersonatest character varying,
    observaciones character varying,
    estado character varying,
    objeto character varying,
    clave character varying,
    usuario_alta character varying,
    username character varying,
    fechacambio character varying,
    codigoreparticion character varying,
    objetos_secues character varying,
    e1 character varying,
    e3 character varying
);


ALTER TABLE sch_gaj.tmp_unl_actas OWNER TO gaj_owner;

--
-- Name: tmp_unl_agentes; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_unl_agentes (
    codigo_agente bigint,
    usuario character varying,
    apellido character varying,
    nombre character varying,
    idpersona bigint,
    codigoreparticion character varying,
    tipoagente character varying,
    fechacambio character varying,
    idpersonates bigint,
    a character varying,
    idagente bigint
);


ALTER TABLE sch_gaj.tmp_unl_agentes OWNER TO gaj_owner;

--
-- Name: tmp_unl_agentes2; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_unl_agentes2 (
    codigo_agente bigint,
    usuario character varying,
    apellido character varying,
    nombre character varying,
    idpersona bigint,
    codigoreparticion character varying,
    tipoagente character varying,
    fechacambio character varying,
    idpersonates bigint,
    a character varying,
    idagente bigint
);


ALTER TABLE sch_gaj.tmp_unl_agentes2 OWNER TO gaj_owner;

--
-- Name: tmp_zz_carlos; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tmp_zz_carlos (
    id bigint
);


ALTER TABLE sch_gaj.tmp_zz_carlos OWNER TO gaj_owner;

--
-- Name: tra_estado_notificacion_tramite; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tra_estado_notificacion_tramite (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    codigo character varying(50) NOT NULL,
    descripcion character varying(150) NOT NULL
);


ALTER TABLE sch_gaj.tra_estado_notificacion_tramite OWNER TO gaj_owner;

--
-- Name: tra_estado_notificacion_tramite_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_estado_notificacion_tramite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_estado_notificacion_tramite_id_seq OWNER TO gaj_owner;

--
-- Name: tra_estado_notificacion_tramite_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.tra_estado_notificacion_tramite_id_seq OWNED BY sch_gaj.tra_estado_notificacion_tramite.id;


--
-- Name: tra_libremulta_numero_112020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_libremulta_numero_112020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_libremulta_numero_112020_seq OWNER TO gaj_owner;

--
-- Name: tra_libremulta_numero_222020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_libremulta_numero_222020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_libremulta_numero_222020_seq OWNER TO gaj_owner;

--
-- Name: tra_libremulta_numero_82020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_libremulta_numero_82020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_libremulta_numero_82020_seq OWNER TO gaj_owner;

--
-- Name: tra_libremulta_numero_92020_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_libremulta_numero_92020_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_libremulta_numero_92020_seq OWNER TO gaj_owner;

--
-- Name: tra_libremulta_tramite; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tra_libremulta_tramite (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    numero_tramite bigint NOT NULL,
    tipo integer NOT NULL,
    fecha_generacion timestamp without time zone,
    fecha_vencimiento timestamp without time zone,
    patente character varying(10),
    persona_id bigint,
    print_data jsonb,
    uuid character varying(40),
    extra_data jsonb,
    tramite integer
);


ALTER TABLE sch_gaj.tra_libremulta_tramite OWNER TO gaj_owner;

--
-- Name: tra_libremulta_tramite_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_libremulta_tramite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_libremulta_tramite_id_seq OWNER TO gaj_owner;

--
-- Name: tra_libremulta_tramite_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.tra_libremulta_tramite_id_seq OWNED BY sch_gaj.tra_libremulta_tramite.id;


--
-- Name: tra_notificacion_tramite; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tra_notificacion_tramite (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    usuario_tramite_id bigint NOT NULL,
    notificacion_id bigint NOT NULL,
    estado_notificacion_tramite_id bigint NOT NULL
);


ALTER TABLE sch_gaj.tra_notificacion_tramite OWNER TO gaj_owner;

--
-- Name: tra_notificacion_tramite_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_notificacion_tramite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_notificacion_tramite_id_seq OWNER TO gaj_owner;

--
-- Name: tra_notificacion_tramite_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.tra_notificacion_tramite_id_seq OWNED BY sch_gaj.tra_notificacion_tramite.id;


--
-- Name: tra_usuario_tramite; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.tra_usuario_tramite (
    id bigint NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    persona_id bigint NOT NULL,
    email character varying(50),
    notificacion_electronica boolean,
    nombre_y_apellido character varying(150)
);


ALTER TABLE sch_gaj.tra_usuario_tramite OWNER TO gaj_owner;

--
-- Name: tra_usuario_tramite_id_seq; Type: SEQUENCE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE SEQUENCE sch_gaj.tra_usuario_tramite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE sch_gaj.tra_usuario_tramite_id_seq OWNER TO gaj_owner;

--
-- Name: tra_usuario_tramite_id_seq; Type: SEQUENCE OWNED BY; Schema: sch_gaj; Owner: gaj_owner
--

ALTER SEQUENCE sch_gaj.tra_usuario_tramite_id_seq OWNED BY sch_gaj.tra_usuario_tramite.id;


--
-- Name: w_borrar; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE UNLOGGED TABLE sch_gaj.w_borrar (
    a character varying(20),
    b bigint,
    c character varying(1)
);


ALTER TABLE sch_gaj.w_borrar OWNER TO gaj_owner;

--
-- Name: w_carga; Type: TABLE; Schema: sch_gaj; Owner: acozzi0
--

CREATE TABLE sch_gaj.w_carga (
    id bigint,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint,
    sentencia_id bigint,
    persona_id bigint,
    justificacion character varying(255),
    estado_juzgamiento integer,
    tipo_juzgamiento_id bigint,
    acta_id bigint,
    revision_id bigint,
    instancia integer,
    tasa_fotografica double precision
);


ALTER TABLE sch_gaj.w_carga OWNER TO acozzi0;

--
-- Name: zz_nueva_def_pena_infraccion; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.zz_nueva_def_pena_infraccion (
    id bigint DEFAULT nextval('sch_gaj.def_pena_infraccion_id_seq'::regclass) NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    infraccion_id bigint NOT NULL,
    tipo_pena_id bigint NOT NULL,
    fecha_desde timestamp without time zone DEFAULT CURRENT_DATE NOT NULL,
    fecha_hasta timestamp without time zone,
    caracter_pena integer,
    obligatoria_sentencia boolean DEFAULT false NOT NULL,
    es_definitiva boolean DEFAULT false NOT NULL
);


ALTER TABLE sch_gaj.zz_nueva_def_pena_infraccion OWNER TO gaj_owner;

--
-- Name: zzz_ctrl; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.zzz_ctrl (
    t_acta integer,
    nro_acta integer,
    serie character(1),
    accion_gaj character(1),
    z character(1)
);


ALTER TABLE sch_gaj.zzz_ctrl OWNER TO gaj_owner;

--
-- Name: zzz_juz_recibo_siat; Type: TABLE; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TABLE sch_gaj.zzz_juz_recibo_siat (
    id bigint DEFAULT nextval('sch_gaj.juz_recibo_siat_id_seq'::regclass) NOT NULL,
    creation_timestamp timestamp without time zone,
    creation_user character varying(255),
    deleted boolean NOT NULL,
    modification_timestamp timestamp without time zone,
    modification_user character varying(255),
    version_number bigint NOT NULL,
    id_recibo_siat bigint,
    nro_recibo bigint,
    codrefpag bigint,
    fecha_vencimiento timestamp without time zone,
    codbarra character varying(255),
    importe_recibo double precision,
    vigente boolean,
    fecha_segundo_vencimiento timestamp without time zone,
    porcentaje_descuento double precision,
    importe_sin_descuento double precision,
    cod_pago_electronico character varying(255)
);


ALTER TABLE sch_gaj.zzz_juz_recibo_siat OWNER TO gaj_owner;

--
-- Name: cla_clausura id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_clausura_id_seq'::regclass);


--
-- Name: cla_clausura_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_clausura_acta_id_seq'::regclass);


--
-- Name: cla_clausura_definitiva id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_definitiva ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_clausura_definitiva_id_seq'::regclass);


--
-- Name: cla_clausura_status id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_status ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_clausura_status_id_seq'::regclass);


--
-- Name: cla_detalle_clausura id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_detalle_clausura ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_detalle_clausura_id_seq'::regclass);


--
-- Name: cla_detalle_clausura_hist id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_detalle_clausura_hist ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_detalle_clausura_hist_id_seq'::regclass);


--
-- Name: cla_levantamiento_clausura id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_levantamiento_clausura ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_levantamiento_clausura_id_seq'::regclass);


--
-- Name: cla_oficio_desprecintamiento id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_oficio_desprecintamiento ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_oficio_desprecintamiento_id_seq'::regclass);


--
-- Name: cla_reanudacion_clausura id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_reanudacion_clausura ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_reanudacion_clausura_id_seq'::regclass);


--
-- Name: cla_suspencion_clausura id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_suspencion_clausura ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cla_suspencion_clausura_id_seq'::regclass);


--
-- Name: com_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_acta_id_seq'::regclass);


--
-- Name: com_acta_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_acta_infraccion_id_seq'::regclass);


--
-- Name: com_acta_inspeccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_inspeccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_acta_inspeccion_id_seq'::regclass);


--
-- Name: com_acta_recepcion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_recepcion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_acta_recepcion_id_seq'::regclass);


--
-- Name: com_actaimagen id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actaimagen ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_actaimagen_id_seq'::regclass);


--
-- Name: com_actatransitoprovisoria id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actatransitoprovisoria ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_actatransitoprovisoria_id_seq'::regclass);


--
-- Name: com_audiencia_imagen id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_audiencia_imagen ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_audiencia_imagen_id_seq'::regclass);


--
-- Name: com_background_run id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_background_run ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_background_run_id_seq'::regclass);


--
-- Name: com_background_task id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_background_task ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_background_task_id_seq'::regclass);


--
-- Name: com_detalle_objeto id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_objeto ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_detalle_objeto_id_seq'::regclass);


--
-- Name: com_detalle_oficio id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_oficio ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_detalle_oficio_id_seq'::regclass);


--
-- Name: com_detalle_pena_clausura id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_pena_clausura ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_detalle_pena_clausura_id_seq'::regclass);


--
-- Name: com_domicilio id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_domicilio ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_domicilio_id_seq'::regclass);


--
-- Name: com_estado_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_estado_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_estado_acta_id_seq'::regclass);


--
-- Name: com_imagen id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_imagen ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_imagen_id_seq'::regclass);


--
-- Name: com_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_infraccion_id_seq'::regclass);


--
-- Name: com_infraccionprovisoria id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccionprovisoria ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_infraccionprovisoria_id_seq'::regclass);


--
-- Name: com_libera_requisito id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_libera_requisito ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_libera_requisito_id_seq'::regclass);


--
-- Name: com_liberacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_liberacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_liberacion_id_seq'::regclass);


--
-- Name: com_lote id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_lote ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_lote_id_seq'::regclass);


--
-- Name: com_loteitem id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_loteitem ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_loteitem_id_seq'::regclass);


--
-- Name: com_oficio id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_oficio_id_seq'::regclass);


--
-- Name: com_presunto_infractor id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_presunto_infractor ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_presunto_infractor_id_seq'::regclass);


--
-- Name: com_proposito_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_proposito_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_proposito_acta_id_seq'::regclass);


--
-- Name: com_sugerencia_destino id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_sugerencia_destino ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_sugerencia_destino_id_seq'::regclass);


--
-- Name: com_tipo_imagen id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipo_imagen ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_tipo_imagen_id_seq'::regclass);


--
-- Name: com_tipo_objeto id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipo_objeto ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_tipo_objeto_id_seq'::regclass);


--
-- Name: com_tipo_oficio id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipo_oficio ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_tipo_oficio_id_seq'::regclass);


--
-- Name: com_tipoacta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipoacta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_tipoacta_id_seq'::regclass);


--
-- Name: com_tipoacta_reparticion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipoacta_reparticion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.com_tipoacta_reparticion_id_seq'::regclass);


--
-- Name: cor_actaestado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_actaestado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_actaestado_id_seq'::regclass);


--
-- Name: cor_egreso id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_egreso ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_egreso_id_seq'::regclass);


--
-- Name: cor_finalizartraslado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_finalizartraslado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_finalizartraslado_id_seq'::regclass);


--
-- Name: cor_ingreso id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_ingreso ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_ingreso_id_seq'::regclass);


--
-- Name: cor_iniciotraslado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_iniciotraslado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_iniciotraslado_id_seq'::regclass);


--
-- Name: cor_inventario id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_inventario ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_inventario_id_seq'::regclass);


--
-- Name: cor_novedad id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_novedad ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_novedad_id_seq'::regclass);


--
-- Name: cor_recepciontraslado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_recepciontraslado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_recepciontraslado_id_seq'::regclass);


--
-- Name: cor_sector id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_sector ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_sector_id_seq'::regclass);


--
-- Name: cor_tipocorralon id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipocorralon ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_tipocorralon_id_seq'::regclass);


--
-- Name: cor_tipodestino id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipodestino ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_tipodestino_id_seq'::regclass);


--
-- Name: cor_tipoegreso id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipoegreso ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_tipoegreso_id_seq'::regclass);


--
-- Name: cor_tipovehiculoacarreo id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipovehiculoacarreo ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_tipovehiculoacarreo_id_seq'::regclass);


--
-- Name: cor_traslado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_traslado_id_seq'::regclass);


--
-- Name: cor_traslado_traslado_inventarios id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado_traslado_inventarios ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_traslado_traslado_inventarios_id_seq'::regclass);


--
-- Name: cor_vehiculoacarreo id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_vehiculoacarreo ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_vehiculoacarreo_id_seq'::regclass);


--
-- Name: cor_verificaciontecnica id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_verificaciontecnica ALTER COLUMN id SET DEFAULT nextval('sch_gaj.cor_verificaciontecnica_id_seq'::regclass);


--
-- Name: def_alternativalib id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_alternativalib ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_alternativalib_id_seq'::regclass);


--
-- Name: def_causal_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_causal_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_causal_infraccion_id_seq'::regclass);


--
-- Name: def_concepto_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_concepto_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_concepto_infraccion_id_seq'::regclass);


--
-- Name: def_especie_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_especie_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_especie_infraccion_id_seq'::regclass);


--
-- Name: def_excluida_sugit id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_excluida_sugit ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_excluida_sugit_id_seq'::regclass);


--
-- Name: def_normativa_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_normativa_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_normativa_infraccion_id_seq'::regclass);


--
-- Name: def_parametro id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_parametro ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_parametro_id_seq'::regclass);


--
-- Name: def_particularidadlib id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_particularidadlib ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_particularidadlib_id_seq'::regclass);


--
-- Name: def_pena_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_pena_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_pena_infraccion_id_seq'::regclass);


--
-- Name: def_pena_regla_reincidencia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_pena_regla_reincidencia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_pena_regla_reincidencia_id_seq'::regclass);


--
-- Name: def_penalidad_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_penalidad_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_penalidad_infraccion_id_seq'::regclass);


--
-- Name: def_penalidad_infraccion infraccion_id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_penalidad_infraccion ALTER COLUMN infraccion_id SET DEFAULT nextval('sch_gaj.def_penalidad_infraccion_infraccion_id_seq'::regclass);


--
-- Name: def_permiso_funcional id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_permiso_funcional ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_permiso_funcional_id_seq'::regclass);


--
-- Name: def_permiso_funcional_usuario id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_permiso_funcional_usuario ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_permiso_funcional_usuario_id_seq'::regclass);


--
-- Name: def_regimen_juzgamiento id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regimen_juzgamiento ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_regimen_juzgamiento_id_seq'::regclass);


--
-- Name: def_regimen_juzgamiento infraccion_id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regimen_juzgamiento ALTER COLUMN infraccion_id SET DEFAULT nextval('sch_gaj.def_regimen_juzgamiento_infraccion_id_seq'::regclass);


--
-- Name: def_regla_reincidencia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_regla_reincidencia_id_seq'::regclass);


--
-- Name: def_regla_reincidencia_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_regla_reincidencia_infraccion_id_seq'::regclass);


--
-- Name: def_reparticion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_reparticion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_reparticion_id_seq'::regclass);


--
-- Name: def_requisitolib id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitolib ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_requisitolib_id_seq'::regclass);


--
-- Name: def_requisitoslibveh id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitoslibveh ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_requisitoslibveh_id_seq'::regclass);


--
-- Name: def_subespecie_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_subespecie_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_subespecie_infraccion_id_seq'::regclass);


--
-- Name: def_tipo_pago_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipo_pago_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_tipo_pago_infraccion_id_seq'::regclass);


--
-- Name: def_tipo_pago_infraccion infraccion_id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipo_pago_infraccion ALTER COLUMN infraccion_id SET DEFAULT nextval('sch_gaj.def_tipo_pago_infraccion_infraccion_id_seq'::regclass);


--
-- Name: def_tipo_pena id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipo_pena ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_tipo_pena_id_seq'::regclass);


--
-- Name: def_tipovehiculolibera id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipovehiculolibera ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_tipovehiculolibera_id_seq'::regclass);


--
-- Name: def_usuario id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_usuario_id_seq'::regclass);


--
-- Name: def_usuario_permiso_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_usuario_permiso_acta_id_seq'::regclass);


--
-- Name: def_usuario_permiso_notificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_notificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_usuario_permiso_notificacion_id_seq'::regclass);


--
-- Name: def_usuario_reparticion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_reparticion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_usuario_reparticion_id_seq'::regclass);


--
-- Name: def_usuariofuncion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuariofuncion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_usuariofuncion_id_seq'::regclass);


--
-- Name: def_valor_reincidencia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_valor_reincidencia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_valor_reincidencia_id_seq'::regclass);


--
-- Name: def_valuacion_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_valuacion_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.def_valuacion_infraccion_id_seq'::regclass);


--
-- Name: ext_consulta_sugit id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_consulta_sugit ALTER COLUMN id SET DEFAULT nextval('sch_gaj.ext_consulta_sugit_id_seq'::regclass);


--
-- Name: ext_consulta_sugit_det id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_consulta_sugit_det ALTER COLUMN id SET DEFAULT nextval('sch_gaj.ext_consulta_sugit_det_id_seq'::regclass);


--
-- Name: ext_pagos_sugit id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_pagos_sugit ALTER COLUMN id SET DEFAULT nextval('sch_gaj.ext_pagos_sugit_id_seq'::regclass);


--
-- Name: for_formulario id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.for_formulario ALTER COLUMN id SET DEFAULT nextval('sch_gaj.for_formulario_id_seq'::regclass);


--
-- Name: juz_accion_juzgamiento id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_accion_juzgamiento ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_accion_juzgamiento_id_seq'::regclass);


--
-- Name: juz_acta_juez id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_acta_juez ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_acta_juez_id_seq'::regclass);


--
-- Name: juz_agravio_apelacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_agravio_apelacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_agravio_apelacion_id_seq'::regclass);


--
-- Name: juz_apelacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_apelacion_id_seq'::regclass);


--
-- Name: juz_apelacion_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_apelacion_acta_id_seq'::regclass);


--
-- Name: juz_apelacion_imagen id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_imagen ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_apelacion_imagen_id_seq'::regclass);


--
-- Name: juz_apelacion_imagen apelacion_id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_imagen ALTER COLUMN apelacion_id SET DEFAULT nextval('sch_gaj.juz_apelacion_imagen_apelacion_id_seq'::regclass);


--
-- Name: juz_apelacion_imagen imagen_id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_imagen ALTER COLUMN imagen_id SET DEFAULT nextval('sch_gaj.juz_apelacion_imagen_imagen_id_seq'::regclass);


--
-- Name: juz_audiencia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_audiencia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_audiencia_id_seq'::regclass);


--
-- Name: juz_borrador_juzgamiento id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_borrador_juzgamiento ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_borrador_juzgamiento_id_seq'::regclass);


--
-- Name: juz_camara id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_camara ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_camara_id_seq'::regclass);


--
-- Name: juz_cambio_infractor id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_cambio_infractor ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_cambio_infractor_id_seq'::regclass);


--
-- Name: juz_descargo_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_descargo_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_descargo_acta_id_seq'::regclass);


--
-- Name: juz_desistencia_apelacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_desistencia_apelacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_desistencia_apelacion_id_seq'::regclass);


--
-- Name: juz_deuda_siat id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_deuda_siat ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_deuda_siat_id_seq'::regclass);


--
-- Name: juz_envio_siat id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_envio_siat ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_envio_siat_id_seq'::regclass);


--
-- Name: juz_estado_apelacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_estado_apelacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_estado_apelacion_id_seq'::regclass);


--
-- Name: juz_histestape id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_histestape ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_histestape_id_seq'::regclass);


--
-- Name: juz_histestsenact id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_histestsenact ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_histestsenact_id_seq'::regclass);


--
-- Name: juz_juez_apelacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_juez_apelacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_juez_apelacion_id_seq'::regclass);


--
-- Name: juz_novedad_siat id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_novedad_siat ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_novedad_siat_id_seq'::regclass);


--
-- Name: juz_pago_sugit id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pago_sugit ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_pago_sugit_id_seq'::regclass);


--
-- Name: juz_pena_sentencia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pena_sentencia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_pena_sentencia_id_seq'::regclass);


--
-- Name: juz_periodo_cumplimiento_pena id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_periodo_cumplimiento_pena ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_periodo_cumplimiento_pena_id_seq'::regclass);


--
-- Name: juz_proceso_rebeldia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_proceso_rebeldia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_proceso_rebeldia_id_seq'::regclass);


--
-- Name: juz_recibo_siat id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_recibo_siat ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_recibo_siat_id_seq'::regclass);


--
-- Name: juz_recusacion_excusacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_recusacion_excusacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_recusacion_excusacion_id_seq'::regclass);


--
-- Name: juz_sentencia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_sentencia_id_seq'::regclass);


--
-- Name: juz_sentencia_acta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_acta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_sentencia_acta_id_seq'::regclass);


--
-- Name: juz_sentencia_anulacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_anulacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_sentencia_anulacion_id_seq'::regclass);


--
-- Name: juz_sentencia_imagen id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_imagen ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_sentencia_imagen_id_seq'::regclass);


--
-- Name: juz_sentencia_imagen sentencia_id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_imagen ALTER COLUMN sentencia_id SET DEFAULT nextval('sch_gaj.juz_sentencia_imagen_sentencia_id_seq'::regclass);


--
-- Name: juz_sentencia_imagen imagen_id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_imagen ALTER COLUMN imagen_id SET DEFAULT nextval('sch_gaj.juz_sentencia_imagen_imagen_id_seq'::regclass);


--
-- Name: juz_sentencia_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_sentencia_infraccion_id_seq'::regclass);


--
-- Name: juz_sentencia_proceso_rebeldia id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_proceso_rebeldia ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_sentencia_proceso_rebeldia_id_seq'::regclass);


--
-- Name: juz_sentencia_tramite id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_tramite ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_sentencia_tramite_id_seq'::regclass);


--
-- Name: juz_tasa_fotografica id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tasa_fotografica ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_tasa_fotografica_id_seq'::regclass);


--
-- Name: juz_tipo_juzgamiento id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tipo_juzgamiento ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_tipo_juzgamiento_id_seq'::regclass);


--
-- Name: juz_tribunal_automatico id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tribunal_automatico ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_tribunal_automatico_id_seq'::regclass);


--
-- Name: juz_unidad_fija id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_unidad_fija ALTER COLUMN id SET DEFAULT nextval('sch_gaj.juz_unidad_fija_id_seq'::regclass);


--
-- Name: not_areanotificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_areanotificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_areanotificacion_id_seq'::regclass);


--
-- Name: not_auxnotificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_auxnotificacion_id_seq'::regclass);


--
-- Name: not_auxnotificaciondetalle id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificaciondetalle ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_auxnotificaciondetalle_id_seq'::regclass);


--
-- Name: not_estadonotificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_estadonotificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_estadonotificacion_id_seq'::regclass);


--
-- Name: not_grupo_notificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_grupo_notificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_grupo_notificacion_id_seq'::regclass);


--
-- Name: not_grupo_notificacion_localidad id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_grupo_notificacion_localidad ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_grupo_notificacion_localidad_id_seq'::regclass);


--
-- Name: not_hisestnot id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_hisestnot ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_hisestnot_id_seq'::regclass);


--
-- Name: not_lotenotificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_lotenotificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_lotenotificacion_id_seq'::regclass);


--
-- Name: not_notificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_notificacion_id_seq'::regclass);


--
-- Name: not_notificacion_imagen id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion_imagen ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_notificacion_imagen_id_seq'::regclass);


--
-- Name: not_notificaciondetalle id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificaciondetalle ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_notificaciondetalle_id_seq'::regclass);


--
-- Name: not_notificador id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificador ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_notificador_id_seq'::regclass);


--
-- Name: not_procesonotificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_procesonotificacion_id_seq'::regclass);


--
-- Name: not_procesonotificacion_infraccion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_infraccion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_procesonotificacion_infraccion_id_seq'::regclass);


--
-- Name: not_procesonotificacion_objeto id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_objeto ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_procesonotificacion_objeto_id_seq'::regclass);


--
-- Name: not_procesonotificacion_reparticion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_reparticion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_procesonotificacion_reparticion_id_seq'::regclass);


--
-- Name: not_procesonotificacion_zona id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_zona ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_procesonotificacion_zona_id_seq'::regclass);


--
-- Name: not_registro_servicios_publicos id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_registro_servicios_publicos ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_registro_servicios_publicos_id_seq'::regclass);


--
-- Name: not_tipobjnot id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tipobjnot ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_tipobjnot_id_seq'::regclass);


--
-- Name: not_tiponotificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tiponotificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_tiponotificacion_id_seq'::regclass);


--
-- Name: not_zonanotificacion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_zonanotificacion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.not_zonanotificacion_id_seq'::regclass);


--
-- Name: pad_agente id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_agente ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_agente_id_seq'::regclass);


--
-- Name: pad_agente_reparticion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_agente_reparticion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_agente_reparticion_id_seq'::regclass);


--
-- Name: pad_autorizado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_autorizado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_autorizado_id_seq'::regclass);


--
-- Name: pad_juez id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juez ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_juez_id_seq'::regclass);


--
-- Name: pad_juzgado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juzgado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_juzgado_id_seq'::regclass);


--
-- Name: pad_persona id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_persona ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_persona_id_seq'::regclass);


--
-- Name: pad_tipovehiculo id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_tipovehiculo ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_tipovehiculo_id_seq'::regclass);


--
-- Name: pad_titular id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_titular ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_titular_id_seq'::regclass);


--
-- Name: pad_vehiculo id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_vehiculo_id_seq'::regclass);


--
-- Name: pad_vehiculo_audit id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_audit ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_vehiculo_audit_id_seq'::regclass);


--
-- Name: pad_vehiculo_autorizado id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_autorizado ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_vehiculo_autorizado_id_seq'::regclass);


--
-- Name: pad_vehiculo_autorizado_audit id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_autorizado_audit ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_vehiculo_autorizado_audit_id_seq'::regclass);


--
-- Name: pad_vehiculo_hist id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_hist ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_vehiculo_hist_id_seq'::regclass);


--
-- Name: pad_vehiculo_titular id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_titular ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_vehiculo_titular_id_seq'::regclass);


--
-- Name: pad_vehiculo_titular_audit id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_titular_audit ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pad_vehiculo_titular_audit_id_seq'::regclass);


--
-- Name: pro_corrida id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_corrida ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_corrida_id_seq'::regclass);


--
-- Name: pro_estadocorrida id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_estadocorrida ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_estadocorrida_id_seq'::regclass);


--
-- Name: pro_filecorrida id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_filecorrida ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_filecorrida_id_seq'::regclass);


--
-- Name: pro_logcorrida id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_logcorrida ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_logcorrida_id_seq'::regclass);


--
-- Name: pro_pasocorrida id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_pasocorrida ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_pasocorrida_id_seq'::regclass);


--
-- Name: pro_proceso id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_proceso ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_proceso_id_seq'::regclass);


--
-- Name: pro_procesoatrval id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_procesoatrval ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_procesoatrval_id_seq'::regclass);


--
-- Name: pro_procesoparval id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_procesoparval ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_procesoparval_id_seq'::regclass);


--
-- Name: pro_tipoejecucion id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_tipoejecucion ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_tipoejecucion_id_seq'::regclass);


--
-- Name: pro_tipoprogejec id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_tipoprogejec ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_tipoprogejec_id_seq'::regclass);


--
-- Name: pro_unifcta id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_unifcta ALTER COLUMN id SET DEFAULT nextval('sch_gaj.pro_unifcta_id_seq'::regclass);


--
-- Name: tra_estado_notificacion_tramite id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_estado_notificacion_tramite ALTER COLUMN id SET DEFAULT nextval('sch_gaj.tra_estado_notificacion_tramite_id_seq'::regclass);


--
-- Name: tra_libremulta_tramite id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_libremulta_tramite ALTER COLUMN id SET DEFAULT nextval('sch_gaj.tra_libremulta_tramite_id_seq'::regclass);


--
-- Name: tra_notificacion_tramite id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_notificacion_tramite ALTER COLUMN id SET DEFAULT nextval('sch_gaj.tra_notificacion_tramite_id_seq'::regclass);


--
-- Name: tra_usuario_tramite id; Type: DEFAULT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_usuario_tramite ALTER COLUMN id SET DEFAULT nextval('sch_gaj.tra_usuario_tramite_id_seq'::regclass);


--
-- Name: cla_clausura_acta cla_clausura_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_acta
    ADD CONSTRAINT cla_clausura_acta_pkey PRIMARY KEY (id);


--
-- Name: cla_clausura_acta cla_clausura_acta_unique_acta_id; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_acta
    ADD CONSTRAINT cla_clausura_acta_unique_acta_id UNIQUE (acta_id);


--
-- Name: cla_clausura_definitiva cla_clausura_definitiva_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_definitiva
    ADD CONSTRAINT cla_clausura_definitiva_pkey PRIMARY KEY (id);


--
-- Name: cla_clausura cla_clausura_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura
    ADD CONSTRAINT cla_clausura_pkey PRIMARY KEY (id);


--
-- Name: cla_clausura_status cla_clausura_status_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_status
    ADD CONSTRAINT cla_clausura_status_pkey PRIMARY KEY (id);


--
-- Name: cla_clausura cla_clausura_unique; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura
    ADD CONSTRAINT cla_clausura_unique UNIQUE (numero);


--
-- Name: cla_detalle_clausura_hist cla_detalle_clausura_hist_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_detalle_clausura_hist
    ADD CONSTRAINT cla_detalle_clausura_hist_pkey PRIMARY KEY (id);


--
-- Name: cla_detalle_clausura cla_detalle_clausura_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_detalle_clausura
    ADD CONSTRAINT cla_detalle_clausura_pkey PRIMARY KEY (id);


--
-- Name: cla_levantamiento_clausura cla_levantamiento_clausura_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_levantamiento_clausura
    ADD CONSTRAINT cla_levantamiento_clausura_pkey PRIMARY KEY (id);


--
-- Name: cla_oficio_desprecintamiento cla_oficio_desprecintamiento_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_oficio_desprecintamiento
    ADD CONSTRAINT cla_oficio_desprecintamiento_pkey PRIMARY KEY (id);


--
-- Name: cla_reanudacion_clausura cla_reanudacion_clausura_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_reanudacion_clausura
    ADD CONSTRAINT cla_reanudacion_clausura_pkey PRIMARY KEY (id);


--
-- Name: cla_suspencion_clausura cla_suspencion_clausura_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_suspencion_clausura
    ADD CONSTRAINT cla_suspencion_clausura_pkey PRIMARY KEY (id);


--
-- Name: com_acta_audit com_acta_audit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_audit
    ADD CONSTRAINT com_acta_audit_pkey PRIMARY KEY (id, revision_id);


--
-- Name: com_acta_infraccion_audit com_acta_infraccion_audit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_infraccion_audit
    ADD CONSTRAINT com_acta_infraccion_audit_pkey PRIMARY KEY (id, revision_id);


--
-- Name: com_acta_infraccion com_acta_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_infraccion
    ADD CONSTRAINT com_acta_infraccion_pkey PRIMARY KEY (id);


--
-- Name: com_acta_inspeccion com_acta_inspeccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_inspeccion
    ADD CONSTRAINT com_acta_inspeccion_pkey PRIMARY KEY (id);


--
-- Name: com_acta com_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_pkey PRIMARY KEY (id);


--
-- Name: com_acta_recepcion com_acta_recepcion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_recepcion
    ADD CONSTRAINT com_acta_recepcion_pkey PRIMARY KEY (id);


--
-- Name: com_actaimagen_audit com_actaimagen_audit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actaimagen_audit
    ADD CONSTRAINT com_actaimagen_audit_pkey PRIMARY KEY (id, revision_id);


--
-- Name: com_actaimagen com_actaimagen_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actaimagen
    ADD CONSTRAINT com_actaimagen_pkey PRIMARY KEY (id);


--
-- Name: com_actatransitoprovisoria com_actatransitoprovisoria_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actatransitoprovisoria
    ADD CONSTRAINT com_actatransitoprovisoria_pkey PRIMARY KEY (id);


--
-- Name: com_audiencia_imagen com_audiencia_imagen_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_audiencia_imagen
    ADD CONSTRAINT com_audiencia_imagen_pkey PRIMARY KEY (id);


--
-- Name: com_background_run com_background_run_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_background_run
    ADD CONSTRAINT com_background_run_pkey PRIMARY KEY (id);


--
-- Name: com_background_task com_background_task_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_background_task
    ADD CONSTRAINT com_background_task_pkey PRIMARY KEY (id);


--
-- Name: com_detalle_objeto com_detalle_objeto_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_objeto
    ADD CONSTRAINT com_detalle_objeto_pkey PRIMARY KEY (id);


--
-- Name: com_detalle_oficio com_detalle_oficio_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_oficio
    ADD CONSTRAINT com_detalle_oficio_pkey PRIMARY KEY (id);


--
-- Name: com_detalle_pena_clausura com_detalle_pena_clausura_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_pena_clausura
    ADD CONSTRAINT com_detalle_pena_clausura_pkey PRIMARY KEY (id);


--
-- Name: com_domicilio com_domicilio_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_domicilio
    ADD CONSTRAINT com_domicilio_pkey PRIMARY KEY (id);


--
-- Name: com_estado_acta com_estado_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_estado_acta
    ADD CONSTRAINT com_estado_acta_pkey PRIMARY KEY (id);


--
-- Name: com_imagen com_imagen_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_imagen
    ADD CONSTRAINT com_imagen_pkey PRIMARY KEY (id);


--
-- Name: com_imagen_vieja com_imagen_pkey_viejo; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_imagen_vieja
    ADD CONSTRAINT com_imagen_pkey_viejo PRIMARY KEY (id);


--
-- Name: com_infraccion com_infraccion_codigo_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT com_infraccion_codigo_uq UNIQUE (cod1, cod2, cod3, cod4);


--
-- Name: com_infraccion com_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT com_infraccion_pkey PRIMARY KEY (id);


--
-- Name: com_infraccionprovisoria com_infraccionprovisoria_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccionprovisoria
    ADD CONSTRAINT com_infraccionprovisoria_pkey PRIMARY KEY (id);


--
-- Name: com_liberacion com_liberacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_liberacion
    ADD CONSTRAINT com_liberacion_pkey PRIMARY KEY (id);


--
-- Name: com_liberacion com_liberacion_unique; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_liberacion
    ADD CONSTRAINT com_liberacion_unique UNIQUE (nro_liberacion);


--
-- Name: com_lote com_lote_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_lote
    ADD CONSTRAINT com_lote_pkey PRIMARY KEY (id);


--
-- Name: com_loteitem com_loteitem_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_loteitem
    ADD CONSTRAINT com_loteitem_pkey PRIMARY KEY (id);


--
-- Name: com_oficio com_oficio_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_pkey PRIMARY KEY (id);


--
-- Name: com_oficio com_oficio_unique; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_unique UNIQUE (numero);


--
-- Name: com_presunto_infractor_audit com_presunto_infractor_audit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_presunto_infractor_audit
    ADD CONSTRAINT com_presunto_infractor_audit_pkey PRIMARY KEY (id, revision_id);


--
-- Name: com_presunto_infractor com_presunto_infractor_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_presunto_infractor
    ADD CONSTRAINT com_presunto_infractor_pkey PRIMARY KEY (id);


--
-- Name: com_proposito_acta com_proposito_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_proposito_acta
    ADD CONSTRAINT com_proposito_acta_pkey PRIMARY KEY (id);


--
-- Name: com_sugerencia_destino com_sugerencia_destino_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_sugerencia_destino
    ADD CONSTRAINT com_sugerencia_destino_pkey PRIMARY KEY (id);


--
-- Name: com_tipo_imagen com_tipo_imagen_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipo_imagen
    ADD CONSTRAINT com_tipo_imagen_pkey PRIMARY KEY (id);


--
-- Name: com_tipo_objeto com_tipo_objeto_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipo_objeto
    ADD CONSTRAINT com_tipo_objeto_pkey PRIMARY KEY (id);


--
-- Name: com_tipo_oficio com_tipo_oficio_codigo_key; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipo_oficio
    ADD CONSTRAINT com_tipo_oficio_codigo_key UNIQUE (codigo);


--
-- Name: com_tipo_oficio com_tipo_oficio_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipo_oficio
    ADD CONSTRAINT com_tipo_oficio_pkey PRIMARY KEY (id);


--
-- Name: com_tipoacta com_tipoacta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipoacta
    ADD CONSTRAINT com_tipoacta_pkey PRIMARY KEY (id);


--
-- Name: com_tipoacta_reparticion com_tipoacta_reparticion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipoacta_reparticion
    ADD CONSTRAINT com_tipoacta_reparticion_pkey PRIMARY KEY (id);


--
-- Name: cor_actaestado cor_actaestado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_actaestado
    ADD CONSTRAINT cor_actaestado_pkey PRIMARY KEY (id);


--
-- Name: cor_egreso cor_egreso_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_egreso
    ADD CONSTRAINT cor_egreso_pkey PRIMARY KEY (id);


--
-- Name: cor_finalizartraslado cor_finalizartraslado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_finalizartraslado
    ADD CONSTRAINT cor_finalizartraslado_pkey PRIMARY KEY (id);


--
-- Name: cor_ingreso cor_ingreso_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_ingreso
    ADD CONSTRAINT cor_ingreso_pkey PRIMARY KEY (id);


--
-- Name: cor_iniciotraslado cor_iniciotraslado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_iniciotraslado
    ADD CONSTRAINT cor_iniciotraslado_pkey PRIMARY KEY (id);


--
-- Name: cor_inventario cor_inventario_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_inventario
    ADD CONSTRAINT cor_inventario_pkey PRIMARY KEY (id);


--
-- Name: cor_novedad cor_novedad_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_novedad
    ADD CONSTRAINT cor_novedad_pkey PRIMARY KEY (id);


--
-- Name: cor_recepciontraslado cor_recepciontraslado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_recepciontraslado
    ADD CONSTRAINT cor_recepciontraslado_pkey PRIMARY KEY (id);


--
-- Name: cor_sector cor_sector_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_sector
    ADD CONSTRAINT cor_sector_pkey PRIMARY KEY (id);


--
-- Name: cor_tipocorralon cor_tipocorralon_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipocorralon
    ADD CONSTRAINT cor_tipocorralon_pkey PRIMARY KEY (id);


--
-- Name: cor_tipodestino cor_tipodestino_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipodestino
    ADD CONSTRAINT cor_tipodestino_pkey PRIMARY KEY (id);


--
-- Name: cor_tipoegreso cor_tipoegreso_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipoegreso
    ADD CONSTRAINT cor_tipoegreso_pkey PRIMARY KEY (id);


--
-- Name: cor_tipovehiculoacarreo cor_tipovehiculoacarreo_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_tipovehiculoacarreo
    ADD CONSTRAINT cor_tipovehiculoacarreo_pkey PRIMARY KEY (id);


--
-- Name: cor_traslado cor_traslado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado
    ADD CONSTRAINT cor_traslado_pkey PRIMARY KEY (id);


--
-- Name: cor_traslado_traslado_inventarios cor_traslado_traslado_inventarios_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado_traslado_inventarios
    ADD CONSTRAINT cor_traslado_traslado_inventarios_pkey PRIMARY KEY (id);


--
-- Name: cor_vehiculoacarreo cor_vehiculoacarreo_patente_key; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_vehiculoacarreo
    ADD CONSTRAINT cor_vehiculoacarreo_patente_key UNIQUE (patente);


--
-- Name: cor_vehiculoacarreo cor_vehiculoacarreo_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_vehiculoacarreo
    ADD CONSTRAINT cor_vehiculoacarreo_pkey PRIMARY KEY (id);


--
-- Name: cor_verificaciontecnica cor_verificaciontecnica_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_verificaciontecnica
    ADD CONSTRAINT cor_verificaciontecnica_pkey PRIMARY KEY (id);


--
-- Name: def_alternativalib def_alternativalib_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_alternativalib
    ADD CONSTRAINT def_alternativalib_pkey PRIMARY KEY (id);


--
-- Name: def_causal_infraccion def_causal_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_causal_infraccion
    ADD CONSTRAINT def_causal_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_concepto_infraccion def_concepto_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_concepto_infraccion
    ADD CONSTRAINT def_concepto_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_especie_infraccion def_especie_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_especie_infraccion
    ADD CONSTRAINT def_especie_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_excluida_sugit def_excluida_sugit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_excluida_sugit
    ADD CONSTRAINT def_excluida_sugit_pkey PRIMARY KEY (id);


--
-- Name: def_normativa_infraccion def_normativa_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_normativa_infraccion
    ADD CONSTRAINT def_normativa_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_parametro def_parametro_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_parametro
    ADD CONSTRAINT def_parametro_pkey PRIMARY KEY (id);


--
-- Name: def_particularidadlib def_particularidadlib_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_particularidadlib
    ADD CONSTRAINT def_particularidadlib_pkey PRIMARY KEY (id);


--
-- Name: def_pena_infraccion def_pena_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_pena_infraccion
    ADD CONSTRAINT def_pena_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_pena_regla_reincidencia def_pena_regla_reincidencia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_pena_regla_reincidencia
    ADD CONSTRAINT def_pena_regla_reincidencia_pkey PRIMARY KEY (id);


--
-- Name: def_penalidad_infraccion def_penalidad_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_penalidad_infraccion
    ADD CONSTRAINT def_penalidad_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_permiso_funcional def_permiso_funcional_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_permiso_funcional
    ADD CONSTRAINT def_permiso_funcional_pkey PRIMARY KEY (id);


--
-- Name: def_permiso_funcional_usuario def_permiso_funcional_usuario_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_permiso_funcional_usuario
    ADD CONSTRAINT def_permiso_funcional_usuario_pkey PRIMARY KEY (id);


--
-- Name: def_regimen_juzgamiento def_regimen_juzgamiento_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regimen_juzgamiento
    ADD CONSTRAINT def_regimen_juzgamiento_pkey PRIMARY KEY (id);


--
-- Name: def_regla_reincidencia def_regla_reincidencia_codigo_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia
    ADD CONSTRAINT def_regla_reincidencia_codigo_uq UNIQUE (codigo);


--
-- Name: def_regla_reincidencia_infraccion def_regla_reincidencia_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia_infraccion
    ADD CONSTRAINT def_regla_reincidencia_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_regla_reincidencia_infraccion def_regla_reincidencia_infraccion_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia_infraccion
    ADD CONSTRAINT def_regla_reincidencia_infraccion_uq UNIQUE (infraccion_id);


--
-- Name: def_regla_reincidencia def_regla_reincidencia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia
    ADD CONSTRAINT def_regla_reincidencia_pkey PRIMARY KEY (id);


--
-- Name: def_reparticion def_reparticion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_reparticion
    ADD CONSTRAINT def_reparticion_pkey PRIMARY KEY (id);


--
-- Name: def_requisitolib def_requisitolib_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitolib
    ADD CONSTRAINT def_requisitolib_pkey PRIMARY KEY (id);


--
-- Name: def_requisitoslibveh def_requisitoslibveh_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitoslibveh
    ADD CONSTRAINT def_requisitoslibveh_pkey PRIMARY KEY (id);


--
-- Name: def_subespecie_infraccion def_subespecie_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_subespecie_infraccion
    ADD CONSTRAINT def_subespecie_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_tipo_pago_infraccion def_tipo_pago_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipo_pago_infraccion
    ADD CONSTRAINT def_tipo_pago_infraccion_pkey PRIMARY KEY (id);


--
-- Name: def_tipo_pena def_tipo_pena_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipo_pena
    ADD CONSTRAINT def_tipo_pena_pkey PRIMARY KEY (id);


--
-- Name: def_tipovehiculolibera def_tipovehiculolibera_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipovehiculolibera
    ADD CONSTRAINT def_tipovehiculolibera_pkey PRIMARY KEY (id);


--
-- Name: def_usuario_permiso_acta def_usuario_permiso_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_acta
    ADD CONSTRAINT def_usuario_permiso_acta_pkey PRIMARY KEY (id);


--
-- Name: def_usuario_permiso_notificacion def_usuario_permiso_notificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_notificacion
    ADD CONSTRAINT def_usuario_permiso_notificacion_pkey PRIMARY KEY (id);


--
-- Name: def_usuario def_usuario_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario
    ADD CONSTRAINT def_usuario_pkey PRIMARY KEY (id);


--
-- Name: def_usuario_reparticion def_usuario_reparticion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_reparticion
    ADD CONSTRAINT def_usuario_reparticion_pkey PRIMARY KEY (id);


--
-- Name: def_usuario def_usuario_usuario_unique; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario
    ADD CONSTRAINT def_usuario_usuario_unique UNIQUE (usuario);


--
-- Name: def_usuariofuncion def_usuariofuncion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuariofuncion
    ADD CONSTRAINT def_usuariofuncion_pkey PRIMARY KEY (id);


--
-- Name: def_valor_reincidencia def_valor_reincidencia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_valor_reincidencia
    ADD CONSTRAINT def_valor_reincidencia_pkey PRIMARY KEY (id);


--
-- Name: def_valuacion_infraccion def_valuacion_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_valuacion_infraccion
    ADD CONSTRAINT def_valuacion_infraccion_pkey PRIMARY KEY (id);


--
-- Name: ext_consulta_sugit_det ext_consulta_sugit_det_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_consulta_sugit_det
    ADD CONSTRAINT ext_consulta_sugit_det_pkey PRIMARY KEY (id);


--
-- Name: ext_consulta_sugit ext_consulta_sugit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_consulta_sugit
    ADD CONSTRAINT ext_consulta_sugit_pkey PRIMARY KEY (id);


--
-- Name: ext_pagos_sugit ext_pagos_sugit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_pagos_sugit
    ADD CONSTRAINT ext_pagos_sugit_pkey PRIMARY KEY (id);


--
-- Name: ext_pagos_sugit ext_pagos_sugit_ukey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_pagos_sugit
    ADD CONSTRAINT ext_pagos_sugit_ukey UNIQUE (traid, infacta, cifid);


--
-- Name: for_formulario for_formulario_codigo_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.for_formulario
    ADD CONSTRAINT for_formulario_codigo_uq UNIQUE (codigo);


--
-- Name: for_formulario for_formulario_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.for_formulario
    ADD CONSTRAINT for_formulario_pkey PRIMARY KEY (id);


--
-- Name: juz_accion_juzgamiento juz_accion_juzgamiento_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_accion_juzgamiento
    ADD CONSTRAINT juz_accion_juzgamiento_pkey PRIMARY KEY (id);


--
-- Name: juz_acta_juez juz_acta_juez_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_acta_juez
    ADD CONSTRAINT juz_acta_juez_pkey PRIMARY KEY (id);


--
-- Name: juz_agravio_apelacion juz_agravio_apelacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_agravio_apelacion
    ADD CONSTRAINT juz_agravio_apelacion_pkey PRIMARY KEY (id);


--
-- Name: juz_apelacion_acta juz_apelacion_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_acta
    ADD CONSTRAINT juz_apelacion_acta_pkey PRIMARY KEY (id);


--
-- Name: juz_apelacion_imagen juz_apelacion_imagen_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_imagen
    ADD CONSTRAINT juz_apelacion_imagen_pkey PRIMARY KEY (id);


--
-- Name: juz_apelacion juz_apelacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion
    ADD CONSTRAINT juz_apelacion_pkey PRIMARY KEY (id);


--
-- Name: juz_audiencia juz_audiencia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_audiencia
    ADD CONSTRAINT juz_audiencia_pkey PRIMARY KEY (id);


--
-- Name: juz_borrador_juzgamiento juz_borrador_juzgamiento_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_borrador_juzgamiento
    ADD CONSTRAINT juz_borrador_juzgamiento_pkey PRIMARY KEY (id);


--
-- Name: juz_camara juz_camara_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_camara
    ADD CONSTRAINT juz_camara_pkey PRIMARY KEY (id);


--
-- Name: juz_cambio_infractor juz_cambio_infractor_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_cambio_infractor
    ADD CONSTRAINT juz_cambio_infractor_pkey PRIMARY KEY (id);


--
-- Name: juz_descargo_acta juz_descargo_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_descargo_acta
    ADD CONSTRAINT juz_descargo_acta_pkey PRIMARY KEY (id);


--
-- Name: juz_desistencia_apelacion juz_desistencia_apelacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_desistencia_apelacion
    ADD CONSTRAINT juz_desistencia_apelacion_pkey PRIMARY KEY (id);


--
-- Name: juz_deuda_siat juz_deuda_siat_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_deuda_siat
    ADD CONSTRAINT juz_deuda_siat_pkey PRIMARY KEY (id);


--
-- Name: juz_envio_siat juz_envio_siat_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_envio_siat
    ADD CONSTRAINT juz_envio_siat_pkey PRIMARY KEY (id);


--
-- Name: juz_estado_apelacion juz_estado_apelacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_estado_apelacion
    ADD CONSTRAINT juz_estado_apelacion_pkey PRIMARY KEY (id);


--
-- Name: juz_histestape juz_histestape_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_histestape
    ADD CONSTRAINT juz_histestape_pkey PRIMARY KEY (id);


--
-- Name: juz_histestsenact juz_histestsenact_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_histestsenact
    ADD CONSTRAINT juz_histestsenact_pkey PRIMARY KEY (id);


--
-- Name: juz_juez_apelacion juz_juez_apelacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_juez_apelacion
    ADD CONSTRAINT juz_juez_apelacion_pkey PRIMARY KEY (id);


--
-- Name: juz_novedad_siat juz_novedad_siat_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_novedad_siat
    ADD CONSTRAINT juz_novedad_siat_pkey PRIMARY KEY (id);


--
-- Name: juz_pago_sugit juz_pago_sugit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pago_sugit
    ADD CONSTRAINT juz_pago_sugit_pkey PRIMARY KEY (id);


--
-- Name: juz_pena_sentencia juz_pena_sentencia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pena_sentencia
    ADD CONSTRAINT juz_pena_sentencia_pkey PRIMARY KEY (id);


--
-- Name: juz_periodo_cumplimiento_pena juz_periodo_cumplimiento_pena_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_periodo_cumplimiento_pena
    ADD CONSTRAINT juz_periodo_cumplimiento_pena_pkey PRIMARY KEY (id);


--
-- Name: juz_proceso_rebeldia juz_proceso_rebeldia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_proceso_rebeldia
    ADD CONSTRAINT juz_proceso_rebeldia_pkey PRIMARY KEY (id);


--
-- Name: juz_recibo_siat juz_recibo_siat_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_recibo_siat
    ADD CONSTRAINT juz_recibo_siat_pkey PRIMARY KEY (id);


--
-- Name: juz_recusacion_excusacion juz_recusacion_excusacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_recusacion_excusacion
    ADD CONSTRAINT juz_recusacion_excusacion_pkey PRIMARY KEY (id);


--
-- Name: juz_sentencia_acta juz_sentencia_acta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_acta
    ADD CONSTRAINT juz_sentencia_acta_pkey PRIMARY KEY (id);


--
-- Name: juz_sentencia_anulacion juz_sentencia_anulacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_anulacion
    ADD CONSTRAINT juz_sentencia_anulacion_pkey PRIMARY KEY (id);


--
-- Name: juz_sentencia_imagen juz_sentencia_imagen_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_imagen
    ADD CONSTRAINT juz_sentencia_imagen_pkey PRIMARY KEY (id);


--
-- Name: juz_sentencia_infraccion juz_sentencia_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_infraccion
    ADD CONSTRAINT juz_sentencia_infraccion_pkey PRIMARY KEY (id);


--
-- Name: juz_sentencia juz_sentencia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia
    ADD CONSTRAINT juz_sentencia_pkey PRIMARY KEY (id);


--
-- Name: juz_sentencia_proceso_rebeldia juz_sentencia_proceso_rebeldia_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_proceso_rebeldia
    ADD CONSTRAINT juz_sentencia_proceso_rebeldia_pkey PRIMARY KEY (id);


--
-- Name: juz_sentencia_tramite juz_sentencia_tramite_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_tramite
    ADD CONSTRAINT juz_sentencia_tramite_pkey PRIMARY KEY (id);


--
-- Name: juz_tasa_fotografica juz_tasa_fotografica_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tasa_fotografica
    ADD CONSTRAINT juz_tasa_fotografica_pkey PRIMARY KEY (id);


--
-- Name: juz_tipo_juzgamiento juz_tipo_juzgamiento_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tipo_juzgamiento
    ADD CONSTRAINT juz_tipo_juzgamiento_pkey PRIMARY KEY (id);


--
-- Name: juz_tribunal_automatico juz_tribunal_automatico_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tribunal_automatico
    ADD CONSTRAINT juz_tribunal_automatico_pkey PRIMARY KEY (id);


--
-- Name: juz_unidad_fija juz_unidad_fija_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_unidad_fija
    ADD CONSTRAINT juz_unidad_fija_pkey PRIMARY KEY (id);


--
-- Name: not_areanotificacion not_areanotificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_areanotificacion
    ADD CONSTRAINT not_areanotificacion_pkey PRIMARY KEY (id);


--
-- Name: not_auxnotificacion not_auxnotificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificacion
    ADD CONSTRAINT not_auxnotificacion_pkey PRIMARY KEY (id);


--
-- Name: not_auxnotificaciondetalle not_auxnotificaciondetalle_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificaciondetalle
    ADD CONSTRAINT not_auxnotificaciondetalle_pkey PRIMARY KEY (id);


--
-- Name: not_estadonotificacion not_estadonotificacion_descripcion_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_estadonotificacion
    ADD CONSTRAINT not_estadonotificacion_descripcion_uq UNIQUE (descripcion);


--
-- Name: not_estadonotificacion not_estadonotificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_estadonotificacion
    ADD CONSTRAINT not_estadonotificacion_pkey PRIMARY KEY (id);


--
-- Name: not_grupo_notificacion_localidad not_grupo_notificacion_localidad_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_grupo_notificacion_localidad
    ADD CONSTRAINT not_grupo_notificacion_localidad_pkey PRIMARY KEY (id);


--
-- Name: not_grupo_notificacion not_grupo_notificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_grupo_notificacion
    ADD CONSTRAINT not_grupo_notificacion_pkey PRIMARY KEY (id);


--
-- Name: not_hisestnot not_hisestnot_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_hisestnot
    ADD CONSTRAINT not_hisestnot_pkey PRIMARY KEY (id);


--
-- Name: not_lotenotificacion not_lotenotificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_lotenotificacion
    ADD CONSTRAINT not_lotenotificacion_pkey PRIMARY KEY (id);


--
-- Name: not_notificacion_imagen not_notificacion_imagen_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion_imagen
    ADD CONSTRAINT not_notificacion_imagen_pkey PRIMARY KEY (id);


--
-- Name: not_notificacion not_notificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion
    ADD CONSTRAINT not_notificacion_pkey PRIMARY KEY (id);


--
-- Name: not_notificaciondetalle not_notificaciondetalle_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificaciondetalle
    ADD CONSTRAINT not_notificaciondetalle_pkey PRIMARY KEY (id);


--
-- Name: not_notificador not_notificador_numero_legajo_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificador
    ADD CONSTRAINT not_notificador_numero_legajo_uq UNIQUE (area_notificacion_id, numero_legajo);


--
-- Name: not_notificador not_notificador_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificador
    ADD CONSTRAINT not_notificador_pkey PRIMARY KEY (id);


--
-- Name: not_procesonotificacion_infraccion not_procesonotificacion_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_infraccion
    ADD CONSTRAINT not_procesonotificacion_infraccion_pkey PRIMARY KEY (id);


--
-- Name: not_procesonotificacion_objeto not_procesonotificacion_objeto_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_objeto
    ADD CONSTRAINT not_procesonotificacion_objeto_pkey PRIMARY KEY (id);


--
-- Name: not_procesonotificacion not_procesonotificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion
    ADD CONSTRAINT not_procesonotificacion_pkey PRIMARY KEY (id);


--
-- Name: not_procesonotificacion_reparticion not_procesonotificacion_reparticion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_reparticion
    ADD CONSTRAINT not_procesonotificacion_reparticion_pkey PRIMARY KEY (id);


--
-- Name: not_procesonotificacion_zona not_procesonotificacion_zona_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_zona
    ADD CONSTRAINT not_procesonotificacion_zona_pkey PRIMARY KEY (id);


--
-- Name: not_registro_servicios_publicos not_registro_servicios_publicos_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_registro_servicios_publicos
    ADD CONSTRAINT not_registro_servicios_publicos_pkey PRIMARY KEY (id);


--
-- Name: not_tipobjnot not_tipobjnot_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tipobjnot
    ADD CONSTRAINT not_tipobjnot_pkey PRIMARY KEY (id);


--
-- Name: not_tipobjnot not_tipobjnot_tabla_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tipobjnot
    ADD CONSTRAINT not_tipobjnot_tabla_uq UNIQUE (tabla);


--
-- Name: not_tiponotificacion not_tiponotificacion_codigo_uq; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tiponotificacion
    ADD CONSTRAINT not_tiponotificacion_codigo_uq UNIQUE (codigo);


--
-- Name: not_tiponotificacion not_tiponotificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tiponotificacion
    ADD CONSTRAINT not_tiponotificacion_pkey PRIMARY KEY (id);


--
-- Name: not_zonanotificacion not_zonanotificacion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_zonanotificacion
    ADD CONSTRAINT not_zonanotificacion_pkey PRIMARY KEY (id);


--
-- Name: pad_agente pad_agente_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_agente
    ADD CONSTRAINT pad_agente_pkey PRIMARY KEY (id);


--
-- Name: pad_agente_reparticion pad_agente_reparticion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_agente_reparticion
    ADD CONSTRAINT pad_agente_reparticion_pkey PRIMARY KEY (id);


--
-- Name: pad_autorizado pad_autorizado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_autorizado
    ADD CONSTRAINT pad_autorizado_pkey PRIMARY KEY (id);


--
-- Name: pad_juez pad_juez_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juez
    ADD CONSTRAINT pad_juez_pkey PRIMARY KEY (id);


--
-- Name: pad_juzgado pad_juzgado_numero_key; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juzgado
    ADD CONSTRAINT pad_juzgado_numero_key UNIQUE (numero);


--
-- Name: pad_juzgado pad_juzgado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juzgado
    ADD CONSTRAINT pad_juzgado_pkey PRIMARY KEY (id);


--
-- Name: pad_persona pad_persona_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_persona
    ADD CONSTRAINT pad_persona_pkey PRIMARY KEY (id);


--
-- Name: pad_tipovehiculo pad_tipovehiculo_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_tipovehiculo
    ADD CONSTRAINT pad_tipovehiculo_pkey PRIMARY KEY (id);


--
-- Name: pad_titular pad_titular_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_titular
    ADD CONSTRAINT pad_titular_pkey PRIMARY KEY (id);


--
-- Name: pad_vehiculo_audit pad_vehiculo_audit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_audit
    ADD CONSTRAINT pad_vehiculo_audit_pkey PRIMARY KEY (id, revision_id);


--
-- Name: pad_vehiculo_autorizado_audit pad_vehiculo_autorizado_audit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_autorizado_audit
    ADD CONSTRAINT pad_vehiculo_autorizado_audit_pkey PRIMARY KEY (id, revision_id);


--
-- Name: pad_vehiculo_autorizado pad_vehiculo_autorizado_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_autorizado
    ADD CONSTRAINT pad_vehiculo_autorizado_pkey PRIMARY KEY (id);


--
-- Name: pad_vehiculo_hist pad_vehiculo_hist_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_hist
    ADD CONSTRAINT pad_vehiculo_hist_pkey PRIMARY KEY (id);


--
-- Name: pad_vehiculo pad_vehiculo_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo
    ADD CONSTRAINT pad_vehiculo_pkey PRIMARY KEY (id);


--
-- Name: pad_vehiculo_titular_audit pad_vehiculo_titular_audit_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_titular_audit
    ADD CONSTRAINT pad_vehiculo_titular_audit_pkey PRIMARY KEY (id, revision_id);


--
-- Name: pad_vehiculo_titular pad_vehiculo_titular_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_titular
    ADD CONSTRAINT pad_vehiculo_titular_pkey PRIMARY KEY (id);


--
-- Name: com_libera_requisito pk_com_libera_requisito_id; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_libera_requisito
    ADD CONSTRAINT pk_com_libera_requisito_id PRIMARY KEY (id);


--
-- Name: pro_corrida pro_corrida_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_corrida
    ADD CONSTRAINT pro_corrida_pkey PRIMARY KEY (id);


--
-- Name: pro_estadocorrida pro_estadocorrida_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_estadocorrida
    ADD CONSTRAINT pro_estadocorrida_pkey PRIMARY KEY (id);


--
-- Name: pro_filecorrida pro_filecorrida_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_filecorrida
    ADD CONSTRAINT pro_filecorrida_pkey PRIMARY KEY (id);


--
-- Name: pro_logcorrida pro_logcorrida_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_logcorrida
    ADD CONSTRAINT pro_logcorrida_pkey PRIMARY KEY (id);


--
-- Name: pro_pasocorrida pro_pasocorrida_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_pasocorrida
    ADD CONSTRAINT pro_pasocorrida_pkey PRIMARY KEY (id);


--
-- Name: pro_proceso pro_proceso_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_proceso
    ADD CONSTRAINT pro_proceso_pkey PRIMARY KEY (id);


--
-- Name: pro_procesoatrval pro_procesoatrval_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_procesoatrval
    ADD CONSTRAINT pro_procesoatrval_pkey PRIMARY KEY (id);


--
-- Name: pro_procesoparval pro_procesoparval_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_procesoparval
    ADD CONSTRAINT pro_procesoparval_pkey PRIMARY KEY (id);


--
-- Name: pro_tipoejecucion pro_tipoejecucion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_tipoejecucion
    ADD CONSTRAINT pro_tipoejecucion_pkey PRIMARY KEY (id);


--
-- Name: pro_tipoprogejec pro_tipoprogejec_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_tipoprogejec
    ADD CONSTRAINT pro_tipoprogejec_pkey PRIMARY KEY (id);


--
-- Name: pro_unifcta pro_unifcta_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_unifcta
    ADD CONSTRAINT pro_unifcta_pkey PRIMARY KEY (id);


--
-- Name: com_revision_info revinfo_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_revision_info
    ADD CONSTRAINT revinfo_pkey PRIMARY KEY (id);


--
-- Name: tra_estado_notificacion_tramite tra_estado_notificacion_tramite_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_estado_notificacion_tramite
    ADD CONSTRAINT tra_estado_notificacion_tramite_pkey PRIMARY KEY (id);


--
-- Name: tra_libremulta_tramite tra_libremulta_tramite_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_libremulta_tramite
    ADD CONSTRAINT tra_libremulta_tramite_pkey PRIMARY KEY (id);


--
-- Name: tra_notificacion_tramite tra_notificacion_tramite_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_notificacion_tramite
    ADD CONSTRAINT tra_notificacion_tramite_pkey PRIMARY KEY (id);


--
-- Name: tra_usuario_tramite tra_usuario_tramite_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_usuario_tramite
    ADD CONSTRAINT tra_usuario_tramite_pkey PRIMARY KEY (id);


--
-- Name: zz_nueva_def_pena_infraccion zz_nueva_def_pena_infraccion_pkey; Type: CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.zz_nueva_def_pena_infraccion
    ADD CONSTRAINT zz_nueva_def_pena_infraccion_pkey PRIMARY KEY (id);


--
-- Name: agente_id_reparticion_id_tipo_agente_uq_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE UNIQUE INDEX agente_id_reparticion_id_tipo_agente_uq_idx ON sch_gaj.pad_agente_reparticion USING btree (agente_id, reparticion_id, tipo_agente);


--
-- Name: cla_clausura_acta_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cla_clausura_acta_acta_idx ON sch_gaj.cla_clausura_acta USING btree (acta_id);


--
-- Name: cla_clausura_fecha_inicio_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cla_clausura_fecha_inicio_idx ON sch_gaj.cla_clausura USING btree (fecha_inicio);


--
-- Name: cla_clausura_numero_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cla_clausura_numero_idx ON sch_gaj.cla_clausura USING btree (numero);


--
-- Name: com_acta_21_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_21_idx ON sch_gaj.com_acta USING btree (fecha_alta, tipo_acta_id);


--
-- Name: com_acta_22_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_22_idx ON sch_gaj.com_acta USING btree (fecha_alta, estado_acta_id, proposito_acta_id, tipo_acta_id);


--
-- Name: com_acta_23_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_23_idx ON sch_gaj.com_acta USING btree (fecha_acta, estado_acta_id, proposito_acta_id, tipo_acta_id);


--
-- Name: com_acta_24_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_24_idx ON sch_gaj.com_acta USING btree (estado_acta_id);


--
-- Name: com_acta_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_agente_id_idx ON sch_gaj.com_acta USING btree (agente_id);


--
-- Name: com_acta_audit_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_audit_id_idx ON sch_gaj.com_acta_audit USING btree (id);


--
-- Name: com_acta_com_infractor_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_com_infractor_id_idx ON sch_gaj.com_acta USING btree (infractor_id);


--
-- Name: com_acta_creation_user_cmp_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_creation_user_cmp_idx ON sch_gaj.com_acta USING btree (creation_user, estado_envio_acta_tmf, fecha_acta);


--
-- Name: com_acta_estado_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_estado_acta_id_idx ON sch_gaj.com_acta USING btree (estado_acta_id);


--
-- Name: com_acta_estado_acta_notificacion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_estado_acta_notificacion_idx ON sch_gaj.com_acta USING btree (estado_acta_notificacion);


--
-- Name: com_acta_fecha_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_fecha_acta_idx ON sch_gaj.com_acta USING btree (fecha_acta);


--
-- Name: com_acta_fecha_alta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_fecha_alta_idx ON sch_gaj.com_acta USING btree (fecha_alta);


--
-- Name: com_acta_fecha_alta_tipo_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_fecha_alta_tipo_acta_id_idx ON sch_gaj.com_acta USING btree (fecha_alta, tipo_acta_id);


--
-- Name: com_acta_fecha_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_fecha_idx ON sch_gaj.com_acta USING btree (fecha_acta);


--
-- Name: com_acta_infraccion_com_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_infraccion_com_acta_idx ON sch_gaj.com_acta_infraccion USING btree (acta_id);


--
-- Name: com_acta_infraccion_com_infraccion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_infraccion_com_infraccion_id_idx ON sch_gaj.com_acta_infraccion USING btree (infraccion_id);


--
-- Name: com_acta_infractor_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_infractor_id_idx ON sch_gaj.com_acta USING btree (infractor_id);


--
-- Name: com_acta_inventario_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_inventario_id_idx ON sch_gaj.com_acta USING btree (inventario_id);


--
-- Name: com_acta_lugar_infraccion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_lugar_infraccion_id_idx ON sch_gaj.com_acta USING btree (lugar_acta_id);


--
-- Name: com_acta_modification_user_cmp_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_modification_user_cmp_idx ON sch_gaj.com_acta USING btree (modification_user, estado_envio_acta_tmf, fecha_acta);


--
-- Name: com_acta_numero_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_numero_idx ON sch_gaj.com_acta USING btree (numero);


--
-- Name: com_acta_proposito_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_proposito_id_idx ON sch_gaj.com_acta USING btree (proposito_acta_id);


--
-- Name: com_acta_recepcion_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_recepcion_acta_idx ON sch_gaj.com_acta_recepcion USING btree (acta_id);


--
-- Name: com_acta_reparticion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_reparticion_id_idx ON sch_gaj.com_acta USING btree (reparticion_id);


--
-- Name: com_acta_serie_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_serie_idx ON sch_gaj.com_acta USING btree (serie);


--
-- Name: com_acta_tipo_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_tipo_acta_id_idx ON sch_gaj.com_acta USING btree (tipo_acta_id);


--
-- Name: com_acta_tipo_numero_serie_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_acta_tipo_numero_serie_idx ON sch_gaj.com_acta USING btree (tipo_acta_id, numero, serie);


--
-- Name: com_actaimagen_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_actaimagen_acta_idx ON sch_gaj.com_actaimagen USING btree (acta_id);


--
-- Name: com_actatransitoprovisoria_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_actatransitoprovisoria_acta_id_idx ON sch_gaj.com_actatransitoprovisoria USING btree (acta_id);


--
-- Name: com_background_task_codigo_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE UNIQUE INDEX com_background_task_codigo_idx ON sch_gaj.com_background_task USING btree (codigo);


--
-- Name: com_detalle_objeto_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_detalle_objeto_acta_id_idx ON sch_gaj.com_detalle_objeto USING btree (acta_id);


--
-- Name: com_detalle_objeto_com_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_detalle_objeto_com_acta_id_idx ON sch_gaj.com_detalle_objeto USING btree (acta_id);


--
-- Name: com_detalle_objeto_tipo_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_detalle_objeto_tipo_id_idx ON sch_gaj.com_detalle_objeto USING btree (tipo_id);


--
-- Name: com_domicilio_id_calle_id_calle_int_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_domicilio_id_calle_id_calle_int_idx ON sch_gaj.com_domicilio USING btree (id_calle, id_calle_int);


--
-- Name: com_estado_acta_codigo_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_estado_acta_codigo_idx ON sch_gaj.com_estado_acta USING btree (codigo);


--
-- Name: com_infraccion_com_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_infraccion_com_infraccion_idx ON sch_gaj.com_infraccion USING btree (infraccion_relacionada_id);


--
-- Name: com_infraccion_concepto_infraccion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_infraccion_concepto_infraccion_id_idx ON sch_gaj.com_infraccion USING btree (concepto_infraccion_id);


--
-- Name: com_infraccion_def_causal_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_infraccion_def_causal_infraccion_idx ON sch_gaj.com_infraccion USING btree (causal_infraccion_id);


--
-- Name: com_infraccion_def_especie_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_infraccion_def_especie_infraccion_idx ON sch_gaj.com_infraccion USING btree (subespecie_infraccion_id);


--
-- Name: com_infraccion_def_normativa_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_infraccion_def_normativa_infraccion_idx ON sch_gaj.com_infraccion USING btree (normativa_infraccion_id);


--
-- Name: com_infraccionprovisoria_acta_transito_provisoria_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_infraccionprovisoria_acta_transito_provisoria_id_idx ON sch_gaj.com_infraccionprovisoria USING btree (acta_transito_provisoria_id);


--
-- Name: com_liberacion_nro_liberacion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_liberacion_nro_liberacion_idx ON sch_gaj.com_liberacion USING btree (nro_liberacion);


--
-- Name: com_liberacion_patente_migracion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_liberacion_patente_migracion_idx ON sch_gaj.com_liberacion USING btree (patente_migracion);


--
-- Name: com_oficio_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_oficio_acta_id_idx ON sch_gaj.com_oficio USING btree (acta_id);


--
-- Name: com_oficio_clausura_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_oficio_clausura_id_idx ON sch_gaj.com_oficio USING btree (clausura_id);


--
-- Name: com_oficio_fecha_hora_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_oficio_fecha_hora_idx ON sch_gaj.com_oficio USING btree (fecha_hora);


--
-- Name: com_oficio_juez_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_oficio_juez_id_idx ON sch_gaj.com_oficio USING btree (juez_id);


--
-- Name: com_oficio_numero_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_oficio_numero_idx ON sch_gaj.com_oficio USING btree (numero);


--
-- Name: com_oficio_tipo_oficio_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_oficio_tipo_oficio_id_idx ON sch_gaj.com_oficio USING btree (tipo_oficio_id);


--
-- Name: com_presunto_infractor_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_presunto_infractor_acta_id_idx ON sch_gaj.com_presunto_infractor USING btree (acta_id);


--
-- Name: com_presunto_infractor_persona_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_presunto_infractor_persona_id_idx ON sch_gaj.com_presunto_infractor USING btree (persona_id);


--
-- Name: com_punto_com_domicilio_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_punto_com_domicilio_id_idx ON sch_gaj.com_punto_domicilio USING btree (domicilio_id);


--
-- Name: com_punto_com_domicilio_id_idx_viejo; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_punto_com_domicilio_id_idx_viejo ON sch_gaj.com_punto_domicilio_vieja USING btree (domicilio_id);


--
-- Name: com_tipoacta_numero_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX com_tipoacta_numero_idx ON sch_gaj.com_tipoacta USING btree (numero);


--
-- Name: cor_actaestado_fecha_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_actaestado_fecha_idx ON sch_gaj.cor_actaestado USING btree (fecha);


--
-- Name: cor_actaestado_inventario_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_actaestado_inventario_id_idx ON sch_gaj.cor_actaestado USING btree (inventario_id);


--
-- Name: cor_actaestado_numero_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_actaestado_numero_idx ON sch_gaj.cor_actaestado USING btree (numero);


--
-- Name: cor_egreso_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_egreso_agente_id_idx ON sch_gaj.cor_egreso USING btree (agente_id);


--
-- Name: cor_egreso_liberacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_egreso_liberacion_id_idx ON sch_gaj.cor_egreso USING btree (liberacion_id);


--
-- Name: cor_egreso_persona_retira_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_egreso_persona_retira_id_idx ON sch_gaj.cor_egreso USING btree (persona_retira_id);


--
-- Name: cor_egreso_tipo_destino_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_egreso_tipo_destino_id_idx ON sch_gaj.cor_egreso USING btree (tipo_destino_id);


--
-- Name: cor_finalizartraslado_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_finalizartraslado_agente_id_idx ON sch_gaj.cor_finalizartraslado USING btree (agente_id);


--
-- Name: cor_finalizartraslado_fecha_hora_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_finalizartraslado_fecha_hora_idx ON sch_gaj.cor_finalizartraslado USING btree (fecha_hora);


--
-- Name: cor_ingreso_acarreo_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_ingreso_acarreo_id_idx ON sch_gaj.cor_ingreso USING btree (acarreo_id);


--
-- Name: cor_ingreso_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_ingreso_agente_id_idx ON sch_gaj.cor_ingreso USING btree (agente_id);


--
-- Name: cor_iniciotraslado_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_iniciotraslado_agente_id_idx ON sch_gaj.cor_iniciotraslado USING btree (agente_id);


--
-- Name: cor_inventario_egreso_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_inventario_egreso_id_idx ON sch_gaj.cor_inventario USING btree (egreso_id);


--
-- Name: cor_inventario_ingreso_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_inventario_ingreso_id_idx ON sch_gaj.cor_inventario USING btree (ingreso_id);


--
-- Name: cor_inventario_nro_inventario_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_inventario_nro_inventario_idx ON sch_gaj.cor_inventario USING btree (nro_inventario);


--
-- Name: cor_inventario_sector_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_inventario_sector_id_idx ON sch_gaj.cor_inventario USING btree (sector_id);


--
-- Name: cor_inventario_tipo_corralon_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_inventario_tipo_corralon_id_idx ON sch_gaj.cor_inventario USING btree (tipo_corralon_id);


--
-- Name: cor_inventario_tipo_vehiculo_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_inventario_tipo_vehiculo_id_idx ON sch_gaj.cor_inventario USING btree (vehiculo_id);


--
-- Name: cor_novedad_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_novedad_agente_id_idx ON sch_gaj.cor_novedad USING btree (agente_id);


--
-- Name: cor_novedad_inventario_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_novedad_inventario_id_idx ON sch_gaj.cor_novedad USING btree (inventario_id);


--
-- Name: cor_novedad_inventario_persona_notificada_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_novedad_inventario_persona_notificada_id_idx ON sch_gaj.cor_novedad USING btree (persona_notificada_id);


--
-- Name: cor_recepciontraslado_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_recepciontraslado_agente_id_idx ON sch_gaj.cor_recepciontraslado USING btree (agente_id);


--
-- Name: cor_recepciontraslado_fecha_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_recepciontraslado_fecha_idx ON sch_gaj.cor_recepciontraslado USING btree (fecha);


--
-- Name: cor_sector_tipo_corralon_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_sector_tipo_corralon_id_idx ON sch_gaj.cor_sector USING btree (tipo_corralon_id);


--
-- Name: cor_traslado_nro_traslado_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_traslado_nro_traslado_idx ON sch_gaj.cor_traslado USING btree (nro_traslado);


--
-- Name: cor_traslado_traslado_inventarios_inventario_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_traslado_traslado_inventarios_inventario_id_idx ON sch_gaj.cor_traslado_traslado_inventarios USING btree (inventario_id);


--
-- Name: cor_traslado_traslado_inventarios_traslado_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_traslado_traslado_inventarios_traslado_id_idx ON sch_gaj.cor_traslado_traslado_inventarios USING btree (traslado_id);


--
-- Name: cor_vehiculoacarreo_tipo_vehiculo_acarreo_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_vehiculoacarreo_tipo_vehiculo_acarreo_id_idx ON sch_gaj.cor_vehiculoacarreo USING btree (tipo_vehiculo_acarreo_id);


--
-- Name: cor_verificaciontecnica_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_verificaciontecnica_agente_id_idx ON sch_gaj.cor_verificaciontecnica USING btree (agente_id);


--
-- Name: cor_verificaciontecnica_fecha_hora_verificacion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_verificaciontecnica_fecha_hora_verificacion_idx ON sch_gaj.cor_verificaciontecnica USING btree (fecha_hora_verificacion);


--
-- Name: cor_verificaciontecnica_inventario_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_verificaciontecnica_inventario_id_idx ON sch_gaj.cor_verificaciontecnica USING btree (inventario_id);


--
-- Name: cor_verificaciontecnica_numero_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_verificaciontecnica_numero_idx ON sch_gaj.cor_verificaciontecnica USING btree (numero);


--
-- Name: cor_verificaciontecnica_persona_verifica_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX cor_verificaciontecnica_persona_verifica_id_idx ON sch_gaj.cor_verificaciontecnica USING btree (persona_verifica_id);


--
-- Name: def_excluida_sugit_infraccion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX def_excluida_sugit_infraccion_id_idx ON sch_gaj.def_excluida_sugit USING btree (infraccion_id);


--
-- Name: def_penalidad_infraccion_com_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX def_penalidad_infraccion_com_infraccion_idx ON sch_gaj.def_penalidad_infraccion USING btree (infraccion_id);


--
-- Name: def_regimen_juzgamiento_def_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX def_regimen_juzgamiento_def_infraccion_idx ON sch_gaj.def_regimen_juzgamiento USING btree (infraccion_id);


--
-- Name: def_tipo_pago_infraccion_com_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX def_tipo_pago_infraccion_com_infraccion_idx ON sch_gaj.def_tipo_pago_infraccion USING btree (infraccion_id);


--
-- Name: def_usuario_tipo_corralon_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX def_usuario_tipo_corralon_id_idx ON sch_gaj.def_usuario USING btree (tipo_corralon_id);


--
-- Name: ext_consulta_sugit_det_com_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ext_consulta_sugit_det_com_acta_idx ON sch_gaj.ext_consulta_sugit_det USING btree (acta_id);


--
-- Name: ext_consulta_sugit_det_com_infraccion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ext_consulta_sugit_det_com_infraccion_id_idx ON sch_gaj.ext_consulta_sugit_det USING btree (infraccion_id);


--
-- Name: ext_pagos_sugit_ext_consulta_sugit_det_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ext_pagos_sugit_ext_consulta_sugit_det_idx ON sch_gaj.ext_pagos_sugit USING btree (consulta_sugit_det_id);


--
-- Name: ext_pagos_sugit_infacta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ext_pagos_sugit_infacta_idx ON sch_gaj.ext_pagos_sugit USING btree (infacta);


--
-- Name: ext_pagos_sugit_nro_recibo_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ext_pagos_sugit_nro_recibo_idx ON sch_gaj.ext_pagos_sugit USING btree (nro_recibo);


--
-- Name: ext_pagos_sugit_tradominio_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ext_pagos_sugit_tradominio_idx ON sch_gaj.ext_pagos_sugit USING btree (tradominio);


--
-- Name: idx1; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX idx1 ON sch_gaj.pad_agente USING btree (creation_timestamp);


--
-- Name: idx_migra_rel_siat; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX idx_migra_rel_siat ON sch_gaj.mig_rel_siat USING btree (id_deuda, id_cuenta);


--
-- Name: idx_pad_vehiculo_autorizado_autorizado_id; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX idx_pad_vehiculo_autorizado_autorizado_id ON sch_gaj.pad_vehiculo_autorizado USING btree (autorizado_id);


--
-- Name: idx_pad_vehiculo_autorizado_vehiculo_id; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX idx_pad_vehiculo_autorizado_vehiculo_id ON sch_gaj.pad_vehiculo_autorizado USING btree (vehiculo_id);


--
-- Name: idx_pad_vehiculo_titular_titular_id; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX idx_pad_vehiculo_titular_titular_id ON sch_gaj.pad_vehiculo_titular USING btree (titular_id);


--
-- Name: idx_pad_vehiculo_titular_vehiculo_id; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX idx_pad_vehiculo_titular_vehiculo_id ON sch_gaj.pad_vehiculo_titular USING btree (vehiculo_id);


--
-- Name: idx_tmp_acta; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE UNIQUE INDEX idx_tmp_acta ON sch_gaj.tmp_unl_actas USING btree (tipoacta, numero, serie);


--
-- Name: ixfk_pro_corrida_pro_estadocorrida; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_corrida_pro_estadocorrida ON sch_gaj.pro_corrida USING btree (idestadocorrida);


--
-- Name: ixfk_pro_corrida_pro_proceso; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_corrida_pro_proceso ON sch_gaj.pro_corrida USING btree (idproceso);


--
-- Name: ixfk_pro_filecorrida_pro_corrida; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_filecorrida_pro_corrida ON sch_gaj.pro_filecorrida USING btree (idcorrida);


--
-- Name: ixfk_pro_logcorrida_pro_corrida; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_logcorrida_pro_corrida ON sch_gaj.pro_logcorrida USING btree (idcorrida);


--
-- Name: ixfk_pro_pasocorrida_pro_corrida; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_pasocorrida_pro_corrida ON sch_gaj.pro_pasocorrida USING btree (idcorrida);


--
-- Name: ixfk_pro_proceso_pro_tipoejecucion; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_proceso_pro_tipoejecucion ON sch_gaj.pro_proceso USING btree (idtipoejecucion);


--
-- Name: ixfk_pro_proceso_pro_tipoprogejec; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_proceso_pro_tipoprogejec ON sch_gaj.pro_proceso USING btree (idtipoprogejec);


--
-- Name: ixfk_pro_procesoparval_pro_corrida; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX ixfk_pro_procesoparval_pro_corrida ON sch_gaj.pro_procesoparval USING btree (idcorrida);


--
-- Name: juz_acta_juez_pad_juez_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_acta_juez_pad_juez_idx ON sch_gaj.juz_acta_juez USING btree (juez_id);


--
-- Name: juz_apelacion_acta_for_apelacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_apelacion_acta_for_apelacion_id_idx ON sch_gaj.juz_apelacion_acta USING btree (apelacion_id);


--
-- Name: juz_apelacion_acta_for_sentencia_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_apelacion_acta_for_sentencia_acta_id_idx ON sch_gaj.juz_apelacion_acta USING btree (sentencia_acta_id);


--
-- Name: juz_apelacion_for_domicilio_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_apelacion_for_domicilio_id_idx ON sch_gaj.juz_apelacion USING btree (domicilio_id);


--
-- Name: juz_apelacion_for_sentencia_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_apelacion_for_sentencia_id_idx ON sch_gaj.juz_apelacion USING btree (sentencia_id);


--
-- Name: juz_audiencia_juz_acta_juez_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_audiencia_juz_acta_juez_idx ON sch_gaj.juz_audiencia USING btree (acta_juez_id);


--
-- Name: juz_cambio_infractor_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_cambio_infractor_acta_id_idx ON sch_gaj.juz_cambio_infractor USING btree (acta_id);


--
-- Name: juz_cambio_infractor_persona_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_cambio_infractor_persona_id_idx ON sch_gaj.juz_cambio_infractor USING btree (persona_id);


--
-- Name: juz_descargo_acta_com_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_descargo_acta_com_acta_idx ON sch_gaj.juz_descargo_acta USING btree (acta_id);


--
-- Name: juz_desistencia_apelacion_for_apelacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_desistencia_apelacion_for_apelacion_id_idx ON sch_gaj.juz_desistencia_apelacion USING btree (apelacion_id);


--
-- Name: juz_deuda_siat_sentencia_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_deuda_siat_sentencia_acta_id_idx ON sch_gaj.juz_deuda_siat USING btree (sentencia_acta_id);


--
-- Name: juz_novedad_siat_estado_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_novedad_siat_estado_idx ON sch_gaj.juz_novedad_siat USING btree (estado);


--
-- Name: juz_novedad_siat_tipo_novedad_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_novedad_siat_tipo_novedad_idx ON sch_gaj.juz_novedad_siat USING btree (tipo_novedad);


--
-- Name: juz_pago_sugit_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_pago_sugit_acta_idx ON sch_gaj.juz_pago_sugit USING btree (acta_id);


--
-- Name: juz_pena_sentencia_juz_sentencia_infraccion_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_pena_sentencia_juz_sentencia_infraccion_idx ON sch_gaj.juz_pena_sentencia USING btree (sentencia_infraccion_id);


--
-- Name: juz_periodo_cumplimiento_juz_sentencia_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_periodo_cumplimiento_juz_sentencia_idx ON sch_gaj.juz_periodo_cumplimiento_pena USING btree (sentencia_activadora_id);


--
-- Name: juz_periodo_cumplimiento_pena_pena_sentencia_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_periodo_cumplimiento_pena_pena_sentencia_idx ON sch_gaj.juz_periodo_cumplimiento_pena USING btree (pena_sentencia_id);


--
-- Name: juz_sentencia_acta__com_acta_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_sentencia_acta__com_acta_id_idx ON sch_gaj.juz_sentencia_acta USING btree (acta_id);


--
-- Name: juz_sentencia_acta_com_acta__estado_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_sentencia_acta_com_acta__estado_idx ON sch_gaj.juz_sentencia_acta USING btree (instancia, acta_id, estado_juzgamiento);


--
-- Name: juz_sentencia_acta_com_acta_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_sentencia_acta_com_acta_idx ON sch_gaj.juz_sentencia_acta USING btree (instancia, acta_id);


--
-- Name: juz_sentencia_fecha_sentencia_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_sentencia_fecha_sentencia_idx ON sch_gaj.juz_sentencia USING btree (fecha_sentencia);


--
-- Name: juz_sentencia_infraccion_sentencia_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_sentencia_infraccion_sentencia_id_idx ON sch_gaj.juz_sentencia_infraccion USING btree (juzgamiento_id);


--
-- Name: juz_sentencia_tramite_uuid_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX juz_sentencia_tramite_uuid_idx ON sch_gaj.juz_sentencia_tramite USING btree (uuid);


--
-- Name: not_hisestnot_not_estadonotificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_hisestnot_not_estadonotificacion_id_idx ON sch_gaj.not_hisestnot USING btree (estado_actual_id);


--
-- Name: not_hisestnot_not_notificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_hisestnot_not_notificacion_id_idx ON sch_gaj.not_hisestnot USING btree (notificacion_id);


--
-- Name: not_lotenotificacion_not_zonanotificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_lotenotificacion_not_zonanotificacion_id_idx ON sch_gaj.not_lotenotificacion USING btree (zona_notificacion_id);


--
-- Name: not_notificacion_not_estado_notificacion_id_codigo_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificacion_not_estado_notificacion_id_codigo_idx ON sch_gaj.not_notificacion USING btree (estado_notificacion_id, codigo);


--
-- Name: not_notificacion_not_estadonotificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificacion_not_estadonotificacion_id_idx ON sch_gaj.not_notificacion USING btree (estado_notificacion_id);


--
-- Name: not_notificacion_not_lotenotificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificacion_not_lotenotificacion_id_idx ON sch_gaj.not_notificacion USING btree (lote_notificacion_id);


--
-- Name: not_notificacion_not_tiponotificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificacion_not_tiponotificacion_id_idx ON sch_gaj.not_notificacion USING btree (tipo_notificacion_id);


--
-- Name: not_notificaciondetalle_entidad_ref_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificaciondetalle_entidad_ref_id_idx ON sch_gaj.not_notificaciondetalle USING btree (entidad_ref_id);


--
-- Name: not_notificaciondetalle_notificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificaciondetalle_notificacion_id_idx ON sch_gaj.not_notificaciondetalle USING btree (notificacion_id);


--
-- Name: not_notificaciondetalle_tip_obj_not_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificaciondetalle_tip_obj_not_id_idx ON sch_gaj.not_notificaciondetalle USING btree (tip_obj_not_id);


--
-- Name: not_notificador_not_areanotificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_notificador_not_areanotificacion_id_idx ON sch_gaj.not_notificador USING btree (area_notificacion_id);


--
-- Name: not_procesonotificacion_not_tiponotificacion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_procesonotificacion_not_tiponotificacion_id_idx ON sch_gaj.not_procesonotificacion USING btree (tipo_notificacion_id);


--
-- Name: not_tiponotificacion_for_formulario_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_tiponotificacion_for_formulario_id_idx ON sch_gaj.not_tiponotificacion USING btree (formulario_id);


--
-- Name: not_tiponotificacion_not_tipobjnot_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX not_tiponotificacion_not_tipobjnot_id_idx ON sch_gaj.not_tiponotificacion USING btree (tip_obj_not_id);


--
-- Name: pad_agente_persona_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_agente_persona_id_idx ON sch_gaj.pad_agente USING btree (persona_id);


--
-- Name: pad_agente_reparticion_agente_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_agente_reparticion_agente_id_idx ON sch_gaj.pad_agente_reparticion USING btree (agente_id);


--
-- Name: pad_agente_reparticion_codigo_agente_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_agente_reparticion_codigo_agente_idx ON sch_gaj.pad_agente_reparticion USING btree (codigo_agente);


--
-- Name: pad_agente_reparticion_reparticion_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_agente_reparticion_reparticion_id_idx ON sch_gaj.pad_agente_reparticion USING btree (reparticion_id);


--
-- Name: pad_agente_usuario_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_agente_usuario_id_idx ON sch_gaj.pad_agente USING btree (usuario_id);


--
-- Name: pad_autorizado_persona_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_autorizado_persona_id_idx ON sch_gaj.pad_autorizado USING btree (persona_id);


--
-- Name: pad_persona_id_persona_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_persona_id_persona_idx ON sch_gaj.pad_persona USING btree (id_persona);


--
-- Name: pad_titular_persona_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_titular_persona_id_idx ON sch_gaj.pad_titular USING btree (persona_id);


--
-- Name: pad_vehiculo_patente_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_vehiculo_patente_idx ON sch_gaj.pad_vehiculo USING btree (patente);


--
-- Name: pad_vehiculo_tipo_vehiculo_id_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_vehiculo_tipo_vehiculo_id_idx ON sch_gaj.pad_vehiculo USING btree (tipo_vehiculo_id);


--
-- Name: pad_vehiculo_tipo_vehiculo_patente_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX pad_vehiculo_tipo_vehiculo_patente_idx ON sch_gaj.pad_vehiculo USING btree (patente);


--
-- Name: reparticion_id_codigo_agente_uq_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE UNIQUE INDEX reparticion_id_codigo_agente_uq_idx ON sch_gaj.pad_agente_reparticion USING btree (reparticion_id, codigo_agente);


--
-- Name: tra_estado_notificacion_tramite_codigo_idx; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX tra_estado_notificacion_tramite_codigo_idx ON sch_gaj.tra_estado_notificacion_tramite USING btree (codigo);


--
-- Name: tra_notificacion_tramite_not_notificacion; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX tra_notificacion_tramite_not_notificacion ON sch_gaj.tra_notificacion_tramite USING btree (notificacion_id);


--
-- Name: tra_notificacion_tramite_tra_estado_notificacion_tramite; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX tra_notificacion_tramite_tra_estado_notificacion_tramite ON sch_gaj.tra_notificacion_tramite USING btree (estado_notificacion_tramite_id);


--
-- Name: tra_notificacion_tramite_tra_usuario_tramite; Type: INDEX; Schema: sch_gaj; Owner: gaj_owner
--

CREATE INDEX tra_notificacion_tramite_tra_usuario_tramite ON sch_gaj.tra_notificacion_tramite USING btree (usuario_tramite_id);


--
-- Name: cla_clausura cla_clausura_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER cla_clausura_bi BEFORE INSERT ON sch_gaj.cla_clausura FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_clausura();


--
-- Name: cla_detalle_clausura cla_detalle_clausura_bu; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER cla_detalle_clausura_bu BEFORE UPDATE ON sch_gaj.cla_detalle_clausura FOR EACH ROW EXECUTE PROCEDURE sch_gaj.update_cla_detalle_clausura_hist();


--
-- Name: com_liberacion com_liberacion_sequence; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER com_liberacion_sequence BEFORE INSERT ON sch_gaj.com_liberacion FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_com_liberacion();


--
-- Name: com_oficio com_oficio_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER com_oficio_bi BEFORE INSERT ON sch_gaj.com_oficio FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_oficio();


--
-- Name: cor_inventario cor_inventario_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER cor_inventario_bi BEFORE INSERT ON sch_gaj.cor_inventario FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_inventario();


--
-- Name: cor_traslado cor_traslado_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER cor_traslado_bi BEFORE INSERT ON sch_gaj.cor_traslado FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_traslado();


--
-- Name: cor_verificaciontecnica cor_verificaciontecnica_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER cor_verificaciontecnica_bi BEFORE INSERT ON sch_gaj.cor_verificaciontecnica FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_verificaciontecnica();


--
-- Name: juz_apelacion juz_apelacion_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER juz_apelacion_bi BEFORE INSERT ON sch_gaj.juz_apelacion FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_apelacion();

ALTER TABLE sch_gaj.juz_apelacion DISABLE TRIGGER juz_apelacion_bi;


--
-- Name: juz_sentencia juz_sentencia_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER juz_sentencia_bi BEFORE INSERT ON sch_gaj.juz_sentencia FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_sentencia();

ALTER TABLE sch_gaj.juz_sentencia DISABLE TRIGGER juz_sentencia_bi;


--
-- Name: juz_sentencia juz_sentencia_bu; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER juz_sentencia_bu BEFORE UPDATE ON sch_gaj.juz_sentencia FOR EACH ROW EXECUTE PROCEDURE sch_gaj.update_sentencia();

ALTER TABLE sch_gaj.juz_sentencia DISABLE TRIGGER juz_sentencia_bu;


--
-- Name: not_notificacion not_notificacion_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER not_notificacion_bi BEFORE INSERT ON sch_gaj.not_notificacion FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_notificacion();

ALTER TABLE sch_gaj.not_notificacion DISABLE TRIGGER not_notificacion_bi;


--
-- Name: pad_vehiculo pad_vehiculo_bu; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER pad_vehiculo_bu BEFORE UPDATE ON sch_gaj.pad_vehiculo FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_pad_vehiculo_hist();


--
-- Name: tra_libremulta_tramite tra_libremulta_tramite_bi; Type: TRIGGER; Schema: sch_gaj; Owner: gaj_owner
--

CREATE TRIGGER tra_libremulta_tramite_bi BEFORE INSERT ON sch_gaj.tra_libremulta_tramite FOR EACH ROW EXECUTE PROCEDURE sch_gaj.insert_libremulta();


--
-- Name: cla_clausura_acta cla_clausura_acta_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_acta
    ADD CONSTRAINT cla_clausura_acta_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: cla_clausura_acta cla_clausura_acta_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_acta
    ADD CONSTRAINT cla_clausura_acta_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: cla_clausura_definitiva cla_clausura_definitiva_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_definitiva
    ADD CONSTRAINT cla_clausura_definitiva_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: cla_clausura_definitiva cla_clausura_definitiva_oficio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_definitiva
    ADD CONSTRAINT cla_clausura_definitiva_oficio_id_fkey FOREIGN KEY (oficio_id) REFERENCES sch_gaj.com_oficio(id);


--
-- Name: cla_clausura_status cla_clausura_status_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_clausura_status
    ADD CONSTRAINT cla_clausura_status_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: cla_detalle_clausura cla_detalle_clausura_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_detalle_clausura
    ADD CONSTRAINT cla_detalle_clausura_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: cla_detalle_clausura cla_detalle_clausura_oficio_desprecintamiento_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_detalle_clausura
    ADD CONSTRAINT cla_detalle_clausura_oficio_desprecintamiento_id_fkey FOREIGN KEY (oficio_desprecintamiento_id) REFERENCES sch_gaj.cla_oficio_desprecintamiento(id);


--
-- Name: cla_detalle_clausura cla_detalle_clausura_oficio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_detalle_clausura
    ADD CONSTRAINT cla_detalle_clausura_oficio_id_fkey FOREIGN KEY (oficio_id) REFERENCES sch_gaj.com_oficio(id);


--
-- Name: cla_levantamiento_clausura cla_levantamiento_clausura_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_levantamiento_clausura
    ADD CONSTRAINT cla_levantamiento_clausura_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: cla_levantamiento_clausura cla_levantamiento_clausura_oficio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_levantamiento_clausura
    ADD CONSTRAINT cla_levantamiento_clausura_oficio_id_fkey FOREIGN KEY (oficio_id) REFERENCES sch_gaj.com_oficio(id);


--
-- Name: cla_oficio_desprecintamiento cla_oficio_desprecintamiento_oficio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_oficio_desprecintamiento
    ADD CONSTRAINT cla_oficio_desprecintamiento_oficio_id_fkey FOREIGN KEY (oficio_id) REFERENCES sch_gaj.com_oficio(id);


--
-- Name: cla_reanudacion_clausura cla_reanudacion_clausura_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_reanudacion_clausura
    ADD CONSTRAINT cla_reanudacion_clausura_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: cla_reanudacion_clausura cla_reanudacion_clausura_oficio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_reanudacion_clausura
    ADD CONSTRAINT cla_reanudacion_clausura_oficio_id_fkey FOREIGN KEY (oficio_id) REFERENCES sch_gaj.com_oficio(id);


--
-- Name: cla_suspencion_clausura cla_suspencion_clausura_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_suspencion_clausura
    ADD CONSTRAINT cla_suspencion_clausura_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: cla_suspencion_clausura cla_suspencion_clausura_oficio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cla_suspencion_clausura
    ADD CONSTRAINT cla_suspencion_clausura_oficio_id_fkey FOREIGN KEY (oficio_id) REFERENCES sch_gaj.com_oficio(id);


--
-- Name: com_acta com_acta_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: com_acta_audit com_acta_audit_revinfo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_audit
    ADD CONSTRAINT com_acta_audit_revinfo FOREIGN KEY (revision_id) REFERENCES sch_gaj.com_revision_info(id);


--
-- Name: com_acta com_acta_estado_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_estado_acta_id_fkey FOREIGN KEY (estado_acta_id) REFERENCES sch_gaj.com_estado_acta(id);


--
-- Name: com_acta_infraccion com_acta_infraccion_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_infraccion
    ADD CONSTRAINT com_acta_infraccion_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: com_acta_infraccion_audit com_acta_infraccion_audit_revinfo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_infraccion_audit
    ADD CONSTRAINT com_acta_infraccion_audit_revinfo FOREIGN KEY (revision_id) REFERENCES sch_gaj.com_revision_info(id);


--
-- Name: com_acta com_acta_infractor_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_infractor_id_fkey FOREIGN KEY (infractor_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: com_acta com_acta_inventario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_inventario_id_fkey FOREIGN KEY (inventario_id) REFERENCES sch_gaj.cor_inventario(id);


--
-- Name: com_acta com_acta_proposito_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_proposito_acta_id_fkey FOREIGN KEY (proposito_acta_id) REFERENCES sch_gaj.com_proposito_acta(id);


--
-- Name: com_acta_recepcion com_acta_recepcion_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_recepcion
    ADD CONSTRAINT com_acta_recepcion_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: com_acta com_acta_reparticion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_reparticion_id_fkey FOREIGN KEY (reparticion_id) REFERENCES sch_gaj.def_reparticion(id);


--
-- Name: com_acta com_acta_tipo_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_tipo_acta_id_fkey FOREIGN KEY (tipo_acta_id) REFERENCES sch_gaj.com_tipoacta(id);


--
-- Name: com_acta com_acta_zona_notificacion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta
    ADD CONSTRAINT com_acta_zona_notificacion_id_fkey FOREIGN KEY (zona_notificacion_id) REFERENCES sch_gaj.not_zonanotificacion(id);


--
-- Name: com_actaimagen com_actaimagen_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actaimagen
    ADD CONSTRAINT com_actaimagen_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: com_actaimagen_audit com_actaimagen_audit_revinfo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actaimagen_audit
    ADD CONSTRAINT com_actaimagen_audit_revinfo FOREIGN KEY (revision_id) REFERENCES sch_gaj.com_revision_info(id);


--
-- Name: com_actaimagen com_actaimagen_imagen_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_actaimagen
    ADD CONSTRAINT com_actaimagen_imagen_id_fkey FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: com_audiencia_imagen com_audiencia_imagen_com_imagen_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_audiencia_imagen
    ADD CONSTRAINT com_audiencia_imagen_com_imagen_fk FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: com_audiencia_imagen com_audiencia_imagen_juz_audiencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_audiencia_imagen
    ADD CONSTRAINT com_audiencia_imagen_juz_audiencia_fk FOREIGN KEY (audiencia_id) REFERENCES sch_gaj.juz_audiencia(id);


--
-- Name: com_background_run com_background_run_background_task_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_background_run
    ADD CONSTRAINT com_background_run_background_task_id_fkey FOREIGN KEY (background_task_id) REFERENCES sch_gaj.com_background_task(id);


--
-- Name: com_background_run com_background_run_corrida_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_background_run
    ADD CONSTRAINT com_background_run_corrida_id_fkey FOREIGN KEY (corrida_id) REFERENCES sch_gaj.pro_corrida(id);


--
-- Name: com_detalle_objeto com_detalle_objeto_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_objeto
    ADD CONSTRAINT com_detalle_objeto_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: com_detalle_objeto com_detalle_objeto_tipo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_objeto
    ADD CONSTRAINT com_detalle_objeto_tipo_id_fkey FOREIGN KEY (tipo_id) REFERENCES sch_gaj.com_tipo_objeto(id);


--
-- Name: com_detalle_objeto_audit com_detalle_objeto_tipo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_detalle_objeto_audit
    ADD CONSTRAINT com_detalle_objeto_tipo_id_fkey FOREIGN KEY (tipo_id) REFERENCES sch_gaj.com_tipo_objeto(id);


--
-- Name: com_imagen com_imagen_tipo_imagen_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_imagen
    ADD CONSTRAINT com_imagen_tipo_imagen_id_fkey FOREIGN KEY (tipo_imagen_id) REFERENCES sch_gaj.com_tipo_imagen(id);


--
-- Name: com_imagen_vieja com_imagen_tipo_imagen_id_fkey_viejo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_imagen_vieja
    ADD CONSTRAINT com_imagen_tipo_imagen_id_fkey_viejo FOREIGN KEY (tipo_imagen_id) REFERENCES sch_gaj.com_tipo_imagen(id);


--
-- Name: com_infraccion com_infraccion_def_causal_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT com_infraccion_def_causal_infraccion_fk FOREIGN KEY (causal_infraccion_id) REFERENCES sch_gaj.def_causal_infraccion(id);


--
-- Name: com_infraccion com_infraccion_def_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT com_infraccion_def_infraccion_fk FOREIGN KEY (infraccion_relacionada_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: com_infraccion com_infraccion_def_subespecie; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT com_infraccion_def_subespecie FOREIGN KEY (subespecie_infraccion_id) REFERENCES sch_gaj.def_subespecie_infraccion(id);


--
-- Name: com_infraccion com_infraccion_def_subespecie_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT com_infraccion_def_subespecie_infraccion_fk FOREIGN KEY (subespecie_infraccion_id) REFERENCES sch_gaj.def_subespecie_infraccion(id);


--
-- Name: com_acta_infraccion com_infraccion_infraccion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_acta_infraccion
    ADD CONSTRAINT com_infraccion_infraccion_id_fkey FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: com_infraccionprovisoria com_infraccionprovisoria_acta_transito_provisoria_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccionprovisoria
    ADD CONSTRAINT com_infraccionprovisoria_acta_transito_provisoria_id_fkey FOREIGN KEY (acta_transito_provisoria_id) REFERENCES sch_gaj.com_actatransitoprovisoria(id);


--
-- Name: com_libera_requisito com_libera_requisito_imagen_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_libera_requisito
    ADD CONSTRAINT com_libera_requisito_imagen_id FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: com_libera_requisito com_libera_requisito_liberacion_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_libera_requisito
    ADD CONSTRAINT com_libera_requisito_liberacion_id FOREIGN KEY (liberacion_id) REFERENCES sch_gaj.com_liberacion(id);


--
-- Name: com_libera_requisito com_libera_requisito_requisito_lib_veh_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_libera_requisito
    ADD CONSTRAINT com_libera_requisito_requisito_lib_veh_id FOREIGN KEY (requisito_lib_veh_id) REFERENCES sch_gaj.def_requisitoslibveh(id);


--
-- Name: com_liberacion com_liberacion_inventario_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_liberacion
    ADD CONSTRAINT com_liberacion_inventario_id FOREIGN KEY (inventario_id) REFERENCES sch_gaj.cor_inventario(id);


--
-- Name: com_liberacion com_liberacion_juez_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_liberacion
    ADD CONSTRAINT com_liberacion_juez_id FOREIGN KEY (juez_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: com_liberacion com_liberacion_persona_libera_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_liberacion
    ADD CONSTRAINT com_liberacion_persona_libera_id FOREIGN KEY (persona_libera_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: com_liberacion com_liberacion_tipo_destino_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_liberacion
    ADD CONSTRAINT com_liberacion_tipo_destino_id FOREIGN KEY (tipo_destino_id) REFERENCES sch_gaj.cor_tipodestino(id);


--
-- Name: com_loteitem com_lote_item_lote_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_loteitem
    ADD CONSTRAINT com_lote_item_lote_id_fkey FOREIGN KEY (lote_id) REFERENCES sch_gaj.com_lote(id);


--
-- Name: com_oficio com_oficio_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: com_oficio com_oficio_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_clausura_id_fkey FOREIGN KEY (clausura_id) REFERENCES sch_gaj.cla_clausura(id);


--
-- Name: com_oficio com_oficio_detalle_clausura_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_detalle_clausura_id_fkey FOREIGN KEY (detalle_clausura_id) REFERENCES sch_gaj.com_detalle_pena_clausura(id);


--
-- Name: com_oficio com_oficio_detalle_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_detalle_id_fkey FOREIGN KEY (detalle_id) REFERENCES sch_gaj.com_detalle_oficio(id);


--
-- Name: com_oficio com_oficio_juez_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_juez_id_fkey FOREIGN KEY (juez_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: com_oficio com_oficio_tipo_oficio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_oficio
    ADD CONSTRAINT com_oficio_tipo_oficio_id_fkey FOREIGN KEY (tipo_oficio_id) REFERENCES sch_gaj.com_tipo_oficio(id);


--
-- Name: com_presunto_infractor com_presunto_infractor_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_presunto_infractor
    ADD CONSTRAINT com_presunto_infractor_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: com_presunto_infractor_audit com_presunto_infractor_audit_revinfo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_presunto_infractor_audit
    ADD CONSTRAINT com_presunto_infractor_audit_revinfo FOREIGN KEY (revision_id) REFERENCES sch_gaj.com_revision_info(id);


--
-- Name: com_presunto_infractor com_presunto_infractor_persona_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_presunto_infractor
    ADD CONSTRAINT com_presunto_infractor_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: com_punto_domicilio com_punto_domicilio_domicilio_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_punto_domicilio
    ADD CONSTRAINT com_punto_domicilio_domicilio_id_fkey FOREIGN KEY (domicilio_id) REFERENCES sch_gaj.com_domicilio(id);


--
-- Name: com_punto_domicilio_vieja com_punto_domicilio_domicilio_id_fkey_viejo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_punto_domicilio_vieja
    ADD CONSTRAINT com_punto_domicilio_domicilio_id_fkey_viejo FOREIGN KEY (domicilio_id) REFERENCES sch_gaj.com_domicilio(id);


--
-- Name: com_tipoacta_reparticion com_tipoacta_reparticion_reparticion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipoacta_reparticion
    ADD CONSTRAINT com_tipoacta_reparticion_reparticion_id_fkey FOREIGN KEY (reparticion_id) REFERENCES sch_gaj.def_reparticion(id);


--
-- Name: com_tipoacta_reparticion com_tipoacta_reparticion_tipo_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_tipoacta_reparticion
    ADD CONSTRAINT com_tipoacta_reparticion_tipo_acta_id_fkey FOREIGN KEY (tipo_acta_id) REFERENCES sch_gaj.com_tipoacta(id);


--
-- Name: cor_actaestado cor_actaestado_inventario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_actaestado
    ADD CONSTRAINT cor_actaestado_inventario_id_fkey FOREIGN KEY (inventario_id) REFERENCES sch_gaj.cor_inventario(id);


--
-- Name: cor_egreso cor_egreso_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_egreso
    ADD CONSTRAINT cor_egreso_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: cor_egreso cor_egreso_liberacion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_egreso
    ADD CONSTRAINT cor_egreso_liberacion_id_fkey FOREIGN KEY (liberacion_id) REFERENCES sch_gaj.com_liberacion(id);


--
-- Name: cor_egreso cor_egreso_persona_retira_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_egreso
    ADD CONSTRAINT cor_egreso_persona_retira_id_fkey FOREIGN KEY (persona_retira_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: cor_egreso cor_egreso_tipo_destino_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_egreso
    ADD CONSTRAINT cor_egreso_tipo_destino_id_fkey FOREIGN KEY (tipo_destino_id) REFERENCES sch_gaj.cor_tipodestino(id);


--
-- Name: cor_finalizartraslado cor_finalizartraslado_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_finalizartraslado
    ADD CONSTRAINT cor_finalizartraslado_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: cor_ingreso cor_ingreso_acarreo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_ingreso
    ADD CONSTRAINT cor_ingreso_acarreo_id_fkey FOREIGN KEY (acarreo_id) REFERENCES sch_gaj.cor_vehiculoacarreo(id);


--
-- Name: cor_ingreso cor_ingreso_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_ingreso
    ADD CONSTRAINT cor_ingreso_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: cor_iniciotraslado cor_iniciotraslado_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_iniciotraslado
    ADD CONSTRAINT cor_iniciotraslado_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: cor_inventario cor_inventario_egreso_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_inventario
    ADD CONSTRAINT cor_inventario_egreso_id_fkey FOREIGN KEY (egreso_id) REFERENCES sch_gaj.cor_egreso(id);


--
-- Name: cor_inventario cor_inventario_ingreso_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_inventario
    ADD CONSTRAINT cor_inventario_ingreso_id_fkey FOREIGN KEY (ingreso_id) REFERENCES sch_gaj.cor_ingreso(id);


--
-- Name: cor_inventario cor_inventario_sector_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_inventario
    ADD CONSTRAINT cor_inventario_sector_id_fkey FOREIGN KEY (sector_id) REFERENCES sch_gaj.cor_sector(id);


--
-- Name: cor_inventario cor_inventario_tipo_corralon_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_inventario
    ADD CONSTRAINT cor_inventario_tipo_corralon_id_fkey FOREIGN KEY (tipo_corralon_id) REFERENCES sch_gaj.cor_tipocorralon(id);


--
-- Name: cor_inventario cor_inventario_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_inventario
    ADD CONSTRAINT cor_inventario_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES sch_gaj.pad_vehiculo(id);


--
-- Name: cor_novedad cor_novedad_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_novedad
    ADD CONSTRAINT cor_novedad_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: cor_novedad cor_novedad_inventario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_novedad
    ADD CONSTRAINT cor_novedad_inventario_id_fkey FOREIGN KEY (inventario_id) REFERENCES sch_gaj.cor_inventario(id);


--
-- Name: cor_novedad cor_novedad_persona_notificada_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_novedad
    ADD CONSTRAINT cor_novedad_persona_notificada_id_fkey FOREIGN KEY (persona_notificada_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: cor_recepciontraslado cor_recepciontraslado_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_recepciontraslado
    ADD CONSTRAINT cor_recepciontraslado_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: cor_sector cor_sector_tipo_corralon_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_sector
    ADD CONSTRAINT cor_sector_tipo_corralon_id_fkey FOREIGN KEY (tipo_corralon_id) REFERENCES sch_gaj.cor_tipocorralon(id);


--
-- Name: cor_traslado cor_traslado_corralon_destino_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado
    ADD CONSTRAINT cor_traslado_corralon_destino_id_fkey FOREIGN KEY (corralon_destino_id) REFERENCES sch_gaj.cor_tipocorralon(id);


--
-- Name: cor_traslado cor_traslado_corralon_origen_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado
    ADD CONSTRAINT cor_traslado_corralon_origen_id_fkey FOREIGN KEY (corralon_origen_id) REFERENCES sch_gaj.cor_tipocorralon(id);


--
-- Name: cor_traslado cor_traslado_finalizar_traslado_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado
    ADD CONSTRAINT cor_traslado_finalizar_traslado_id_fkey FOREIGN KEY (finalizar_traslado_id) REFERENCES sch_gaj.cor_finalizartraslado(id);


--
-- Name: cor_traslado cor_traslado_inicio_traslado_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado
    ADD CONSTRAINT cor_traslado_inicio_traslado_id_fkey FOREIGN KEY (inicio_traslado_id) REFERENCES sch_gaj.cor_iniciotraslado(id);


--
-- Name: cor_traslado cor_traslado_recepcion_traslado_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado
    ADD CONSTRAINT cor_traslado_recepcion_traslado_id_fkey FOREIGN KEY (recepcion_traslado_id) REFERENCES sch_gaj.cor_recepciontraslado(id);


--
-- Name: cor_traslado_traslado_inventarios cor_traslado_traslado_inventarios_actaestado_creacion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado_traslado_inventarios
    ADD CONSTRAINT cor_traslado_traslado_inventarios_actaestado_creacion_id_fkey FOREIGN KEY (actaestado_creacion_id) REFERENCES sch_gaj.cor_actaestado(id);


--
-- Name: cor_traslado_traslado_inventarios cor_traslado_traslado_inventarios_actaestado_recepcion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado_traslado_inventarios
    ADD CONSTRAINT cor_traslado_traslado_inventarios_actaestado_recepcion_id_fkey FOREIGN KEY (actaestado_recepcion_id) REFERENCES sch_gaj.cor_actaestado(id);


--
-- Name: cor_traslado_traslado_inventarios cor_traslado_traslado_inventarios_inventario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado_traslado_inventarios
    ADD CONSTRAINT cor_traslado_traslado_inventarios_inventario_id_fkey FOREIGN KEY (inventario_id) REFERENCES sch_gaj.cor_inventario(id);


--
-- Name: cor_traslado_traslado_inventarios cor_traslado_traslado_inventarios_traslado_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_traslado_traslado_inventarios
    ADD CONSTRAINT cor_traslado_traslado_inventarios_traslado_id_fkey FOREIGN KEY (traslado_id) REFERENCES sch_gaj.cor_traslado(id);


--
-- Name: cor_vehiculoacarreo cor_vehiculoacarreo_tipo_vehiculo_acarreo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_vehiculoacarreo
    ADD CONSTRAINT cor_vehiculoacarreo_tipo_vehiculo_acarreo_id_fkey FOREIGN KEY (tipo_vehiculo_acarreo_id) REFERENCES sch_gaj.cor_tipovehiculoacarreo(id);


--
-- Name: cor_verificaciontecnica cor_verificaciontecnica_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_verificaciontecnica
    ADD CONSTRAINT cor_verificaciontecnica_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: cor_verificaciontecnica cor_verificaciontecnica_inventario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_verificaciontecnica
    ADD CONSTRAINT cor_verificaciontecnica_inventario_id_fkey FOREIGN KEY (inventario_id) REFERENCES sch_gaj.cor_inventario(id);


--
-- Name: cor_verificaciontecnica cor_verificaciontecnica_persona_verifica_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.cor_verificaciontecnica
    ADD CONSTRAINT cor_verificaciontecnica_persona_verifica_id_fkey FOREIGN KEY (persona_verifica_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: def_excluida_sugit def_excluida_sugit_infraccion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_excluida_sugit
    ADD CONSTRAINT def_excluida_sugit_infraccion_id_fkey FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: com_infraccion def_infraccion_def_concepto_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT def_infraccion_def_concepto_infraccion_fk FOREIGN KEY (concepto_infraccion_id) REFERENCES sch_gaj.def_concepto_infraccion(id);


--
-- Name: com_infraccion def_infraccion_def_normativa_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.com_infraccion
    ADD CONSTRAINT def_infraccion_def_normativa_infraccion_fk FOREIGN KEY (normativa_infraccion_id) REFERENCES sch_gaj.def_normativa_infraccion(id);


--
-- Name: def_pena_infraccion def_pena_infraccion_def_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_pena_infraccion
    ADD CONSTRAINT def_pena_infraccion_def_infraccion_fk FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: def_pena_infraccion def_pena_infraccion_def_tipo_pena_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_pena_infraccion
    ADD CONSTRAINT def_pena_infraccion_def_tipo_pena_fk FOREIGN KEY (tipo_pena_id) REFERENCES sch_gaj.def_tipo_pena(id);


--
-- Name: def_pena_regla_reincidencia def_pena_regla_reincidencia_def_valor_reincidencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_pena_regla_reincidencia
    ADD CONSTRAINT def_pena_regla_reincidencia_def_valor_reincidencia_fk FOREIGN KEY (valor_reincidencia_id) REFERENCES sch_gaj.def_valor_reincidencia(id);


--
-- Name: def_penalidad_infraccion def_penalidad_infraccion_com_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_penalidad_infraccion
    ADD CONSTRAINT def_penalidad_infraccion_com_infraccion_fk FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: def_permiso_funcional_usuario def_permiso_funcional_usuario_permiso_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_permiso_funcional_usuario
    ADD CONSTRAINT def_permiso_funcional_usuario_permiso_fkey FOREIGN KEY (permiso_funcional_id) REFERENCES sch_gaj.def_permiso_funcional(id);


--
-- Name: def_permiso_funcional_usuario def_permiso_funcional_usuario_usuario_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_permiso_funcional_usuario
    ADD CONSTRAINT def_permiso_funcional_usuario_usuario_fkey FOREIGN KEY (usuario_id) REFERENCES sch_gaj.def_usuario(id);


--
-- Name: def_regimen_juzgamiento def_regimen_juzgamiento_com_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regimen_juzgamiento
    ADD CONSTRAINT def_regimen_juzgamiento_com_infraccion_fk FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: def_regla_reincidencia def_regla_reincidencia_def_regla_reincidencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia
    ADD CONSTRAINT def_regla_reincidencia_def_regla_reincidencia_fk FOREIGN KEY (regla_reincidencia_alternativa_id) REFERENCES sch_gaj.def_regla_reincidencia(id);


--
-- Name: def_regla_reincidencia_infraccion def_regla_reincidencia_infraccion_com_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia_infraccion
    ADD CONSTRAINT def_regla_reincidencia_infraccion_com_infraccion_fk FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: def_regla_reincidencia_infraccion def_regla_reincidencia_infraccion_def_regla_reincidencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_regla_reincidencia_infraccion
    ADD CONSTRAINT def_regla_reincidencia_infraccion_def_regla_reincidencia_fk FOREIGN KEY (regla_reincidencia_id) REFERENCES sch_gaj.def_regla_reincidencia(id);


--
-- Name: def_requisitoslibveh def_requisitoslibveh_id_alternativalib; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitoslibveh
    ADD CONSTRAINT def_requisitoslibveh_id_alternativalib FOREIGN KEY (id_alternativalib) REFERENCES sch_gaj.def_alternativalib(id);


--
-- Name: def_requisitoslibveh def_requisitoslibveh_id_particularidadlib; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitoslibveh
    ADD CONSTRAINT def_requisitoslibveh_id_particularidadlib FOREIGN KEY (id_particularidadlib) REFERENCES sch_gaj.def_particularidadlib(id);


--
-- Name: def_requisitoslibveh def_requisitoslibveh_id_requisitolib; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitoslibveh
    ADD CONSTRAINT def_requisitoslibveh_id_requisitolib FOREIGN KEY (id_requisitolib) REFERENCES sch_gaj.def_requisitolib(id);


--
-- Name: def_requisitoslibveh def_requisitoslibveh_id_tipovehiculolibera; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_requisitoslibveh
    ADD CONSTRAINT def_requisitoslibveh_id_tipovehiculolibera FOREIGN KEY (id_tipovehiculolibera) REFERENCES sch_gaj.def_tipovehiculolibera(id);


--
-- Name: def_subespecie_infraccion def_subespecie_infraccion_especie_infraccion; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_subespecie_infraccion
    ADD CONSTRAINT def_subespecie_infraccion_especie_infraccion FOREIGN KEY (especie_id) REFERENCES sch_gaj.def_especie_infraccion(id);


--
-- Name: def_tipo_pago_infraccion def_tipo_pago_infraccion_com_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_tipo_pago_infraccion
    ADD CONSTRAINT def_tipo_pago_infraccion_com_infraccion_fk FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: def_usuario_permiso_acta def_usuario_permiso_acta_proposito_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_acta
    ADD CONSTRAINT def_usuario_permiso_acta_proposito_acta_id_fkey FOREIGN KEY (proposito_acta_id) REFERENCES sch_gaj.com_proposito_acta(id);


--
-- Name: def_usuario_permiso_acta def_usuario_permiso_acta_reparticion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_acta
    ADD CONSTRAINT def_usuario_permiso_acta_reparticion_id_fkey FOREIGN KEY (reparticion_id) REFERENCES sch_gaj.def_reparticion(id);


--
-- Name: def_usuario_permiso_acta def_usuario_permiso_acta_tipo_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_acta
    ADD CONSTRAINT def_usuario_permiso_acta_tipo_acta_id_fkey FOREIGN KEY (tipo_acta_id) REFERENCES sch_gaj.com_tipoacta(id);


--
-- Name: def_usuario_permiso_acta def_usuario_permiso_acta_tipo_objeto_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_acta
    ADD CONSTRAINT def_usuario_permiso_acta_tipo_objeto_id_fkey FOREIGN KEY (tipo_objeto_id) REFERENCES sch_gaj.com_tipo_objeto(id);


--
-- Name: def_usuario_permiso_acta def_usuario_permiso_acta_usuario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_acta
    ADD CONSTRAINT def_usuario_permiso_acta_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES sch_gaj.def_usuario(id);


--
-- Name: def_usuario_permiso_notificacion def_usuario_permiso_notificacion_reparticion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_notificacion
    ADD CONSTRAINT def_usuario_permiso_notificacion_reparticion_id_fkey FOREIGN KEY (reparticion_id) REFERENCES sch_gaj.def_reparticion(id);


--
-- Name: def_usuario_permiso_notificacion def_usuario_permiso_notificacion_tipo_notificacion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_notificacion
    ADD CONSTRAINT def_usuario_permiso_notificacion_tipo_notificacion_id_fkey FOREIGN KEY (tipo_notificacion_id) REFERENCES sch_gaj.not_tiponotificacion(id);


--
-- Name: def_usuario_permiso_notificacion def_usuario_permiso_notificacion_tipo_objeto_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_notificacion
    ADD CONSTRAINT def_usuario_permiso_notificacion_tipo_objeto_id_fkey FOREIGN KEY (tipo_objeto_id) REFERENCES sch_gaj.com_tipo_objeto(id);


--
-- Name: def_usuario_permiso_notificacion def_usuario_permiso_notificacion_usuario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_permiso_notificacion
    ADD CONSTRAINT def_usuario_permiso_notificacion_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES sch_gaj.def_usuario(id);


--
-- Name: def_usuario_reparticion def_usuario_reparticion_reparticion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_reparticion
    ADD CONSTRAINT def_usuario_reparticion_reparticion_id_fkey FOREIGN KEY (reparticion_id) REFERENCES sch_gaj.def_reparticion(id);


--
-- Name: def_usuario_reparticion def_usuario_reparticion_usuario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario_reparticion
    ADD CONSTRAINT def_usuario_reparticion_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES sch_gaj.def_usuario(id);


--
-- Name: def_usuario def_usuario_tipo_corralon_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_usuario
    ADD CONSTRAINT def_usuario_tipo_corralon_id_fkey FOREIGN KEY (tipo_corralon_id) REFERENCES sch_gaj.cor_tipocorralon(id);


--
-- Name: def_valor_reincidencia def_valor_reincidencia_def_regla_reincidencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_valor_reincidencia
    ADD CONSTRAINT def_valor_reincidencia_def_regla_reincidencia_fk FOREIGN KEY (regla_reincidencia_id) REFERENCES sch_gaj.def_regla_reincidencia(id);


--
-- Name: def_valuacion_infraccion def_valuacion_infraccion_def_pena_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.def_valuacion_infraccion
    ADD CONSTRAINT def_valuacion_infraccion_def_pena_infraccion_fk FOREIGN KEY (pena_infraccion_id) REFERENCES sch_gaj.def_pena_infraccion(id);


--
-- Name: ext_consulta_sugit_det ext_consulta_sugit_det_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_consulta_sugit_det
    ADD CONSTRAINT ext_consulta_sugit_det_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: ext_consulta_sugit_det ext_consulta_sugit_det_infraccion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.ext_consulta_sugit_det
    ADD CONSTRAINT ext_consulta_sugit_det_infraccion_id_fkey FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: not_notificador fk_not_notificador_not_areanotificacion; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificador
    ADD CONSTRAINT fk_not_notificador_not_areanotificacion FOREIGN KEY (area_notificacion_id) REFERENCES sch_gaj.not_areanotificacion(id);


--
-- Name: pro_corrida fk_pro_corrida_pro_estadocorrida; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_corrida
    ADD CONSTRAINT fk_pro_corrida_pro_estadocorrida FOREIGN KEY (idestadocorrida) REFERENCES sch_gaj.pro_estadocorrida(id);


--
-- Name: pro_corrida fk_pro_corrida_pro_proceso; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_corrida
    ADD CONSTRAINT fk_pro_corrida_pro_proceso FOREIGN KEY (idproceso) REFERENCES sch_gaj.pro_proceso(id);


--
-- Name: pro_filecorrida fk_pro_filecorrida_pro_corrida; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_filecorrida
    ADD CONSTRAINT fk_pro_filecorrida_pro_corrida FOREIGN KEY (idcorrida) REFERENCES sch_gaj.pro_corrida(id);


--
-- Name: pro_logcorrida fk_pro_logcorrida_pro_corrida; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_logcorrida
    ADD CONSTRAINT fk_pro_logcorrida_pro_corrida FOREIGN KEY (idcorrida) REFERENCES sch_gaj.pro_corrida(id);


--
-- Name: pro_pasocorrida fk_pro_pasocorrida_pro_corrida; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_pasocorrida
    ADD CONSTRAINT fk_pro_pasocorrida_pro_corrida FOREIGN KEY (idcorrida) REFERENCES sch_gaj.pro_corrida(id);


--
-- Name: pro_proceso fk_pro_proceso_pro_tipoejecucion; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_proceso
    ADD CONSTRAINT fk_pro_proceso_pro_tipoejecucion FOREIGN KEY (idtipoejecucion) REFERENCES sch_gaj.pro_tipoejecucion(id);


--
-- Name: pro_proceso fk_pro_proceso_pro_tipoprogejec; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_proceso
    ADD CONSTRAINT fk_pro_proceso_pro_tipoprogejec FOREIGN KEY (idtipoprogejec) REFERENCES sch_gaj.pro_tipoprogejec(id);


--
-- Name: pro_procesoparval fk_pro_procesoparval_pro_corrida; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pro_procesoparval
    ADD CONSTRAINT fk_pro_procesoparval_pro_corrida FOREIGN KEY (idcorrida) REFERENCES sch_gaj.pro_corrida(id);


--
-- Name: juz_acta_juez juz_acta_juez_pad_juez_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_acta_juez
    ADD CONSTRAINT juz_acta_juez_pad_juez_fk FOREIGN KEY (juez_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: juz_agravio_apelacion juz_agravio_apelacion_com_imagen_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_agravio_apelacion
    ADD CONSTRAINT juz_agravio_apelacion_com_imagen_fk FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: juz_agravio_apelacion juz_agravio_apelacion_juz_apelacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_agravio_apelacion
    ADD CONSTRAINT juz_agravio_apelacion_juz_apelacion_fk FOREIGN KEY (apelacion_id) REFERENCES sch_gaj.juz_apelacion(id);


--
-- Name: juz_apelacion_acta juz_apelacion_acta_juz_apelacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_acta
    ADD CONSTRAINT juz_apelacion_acta_juz_apelacion_fk FOREIGN KEY (apelacion_id) REFERENCES sch_gaj.juz_apelacion(id);


--
-- Name: juz_apelacion_acta juz_apelacion_acta_juz_sentencia_acta_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_acta
    ADD CONSTRAINT juz_apelacion_acta_juz_sentencia_acta_fk FOREIGN KEY (sentencia_acta_id) REFERENCES sch_gaj.juz_sentencia_acta(id);


--
-- Name: juz_apelacion_imagen juz_apelacion_imagen_com_imagen_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_imagen
    ADD CONSTRAINT juz_apelacion_imagen_com_imagen_fk FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: juz_apelacion_imagen juz_apelacion_imagen_juz_apelacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion_imagen
    ADD CONSTRAINT juz_apelacion_imagen_juz_apelacion_fk FOREIGN KEY (apelacion_id) REFERENCES sch_gaj.juz_apelacion(id);


--
-- Name: juz_apelacion juz_apelacion_juz_estado_apelacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion
    ADD CONSTRAINT juz_apelacion_juz_estado_apelacion_fk FOREIGN KEY (estado_apelacion_id) REFERENCES sch_gaj.juz_estado_apelacion(id);


--
-- Name: juz_apelacion juz_apelacion_juz_sentencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion
    ADD CONSTRAINT juz_apelacion_juz_sentencia_fk FOREIGN KEY (sentencia_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_apelacion juz_apelacion_sentencia_generada; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_apelacion
    ADD CONSTRAINT juz_apelacion_sentencia_generada FOREIGN KEY (sentencia_generada_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_audiencia juz_audiencia_juz_acta_juez_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_audiencia
    ADD CONSTRAINT juz_audiencia_juz_acta_juez_fk FOREIGN KEY (acta_juez_id) REFERENCES sch_gaj.juz_acta_juez(id);


--
-- Name: juz_borrador_juzgamiento juz_borrador_juzgamiento_infractor_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_borrador_juzgamiento
    ADD CONSTRAINT juz_borrador_juzgamiento_infractor_id_fkey FOREIGN KEY (infractor_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: juz_borrador_juzgamiento juz_borrador_juzgamiento_juez_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_borrador_juzgamiento
    ADD CONSTRAINT juz_borrador_juzgamiento_juez_id_fkey FOREIGN KEY (juez_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: juz_cambio_infractor juz_cambio_infractor_com_acta_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_cambio_infractor
    ADD CONSTRAINT juz_cambio_infractor_com_acta_fk FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: juz_descargo_acta juz_descargo_acta_com_acta_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_descargo_acta
    ADD CONSTRAINT juz_descargo_acta_com_acta_fk FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: juz_descargo_acta juz_descargo_acta_com_imagen_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_descargo_acta
    ADD CONSTRAINT juz_descargo_acta_com_imagen_fk FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: juz_descargo_acta juz_descargo_acta_sentencia_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_descargo_acta
    ADD CONSTRAINT juz_descargo_acta_sentencia_acta_id_fkey FOREIGN KEY (sentencia_acta_id) REFERENCES sch_gaj.juz_sentencia_acta(id);


--
-- Name: juz_desistencia_apelacion juz_desistencia_apelacion_com_imagen_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_desistencia_apelacion
    ADD CONSTRAINT juz_desistencia_apelacion_com_imagen_fk FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: juz_desistencia_apelacion juz_desistencia_apelacion_juz_apelacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_desistencia_apelacion
    ADD CONSTRAINT juz_desistencia_apelacion_juz_apelacion_fk FOREIGN KEY (apelacion_id) REFERENCES sch_gaj.juz_apelacion(id);


--
-- Name: juz_deuda_siat juz_deuda_siat_recibo_siat_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_deuda_siat
    ADD CONSTRAINT juz_deuda_siat_recibo_siat_id FOREIGN KEY (recibo_siat_id) REFERENCES sch_gaj.juz_recibo_siat(id);


--
-- Name: juz_deuda_siat juz_deuda_siat_sentencia_acta_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_deuda_siat
    ADD CONSTRAINT juz_deuda_siat_sentencia_acta_id FOREIGN KEY (sentencia_acta_id) REFERENCES sch_gaj.juz_sentencia_acta(id);


--
-- Name: juz_envio_siat juz_envio_siat_apelacion_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_envio_siat
    ADD CONSTRAINT juz_envio_siat_apelacion_id FOREIGN KEY (apelacion_id) REFERENCES sch_gaj.juz_apelacion(id);


--
-- Name: juz_envio_siat juz_envio_siat_sentencia_acta_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_envio_siat
    ADD CONSTRAINT juz_envio_siat_sentencia_acta_id FOREIGN KEY (sentencia_acta_id) REFERENCES sch_gaj.juz_sentencia_acta(id);


--
-- Name: juz_histestape juz_histestape_apelacion_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_histestape
    ADD CONSTRAINT juz_histestape_apelacion_id FOREIGN KEY (apelacion_id) REFERENCES sch_gaj.juz_apelacion(id);


--
-- Name: juz_histestsenact juz_histestape_apelacion_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_histestsenact
    ADD CONSTRAINT juz_histestape_apelacion_id FOREIGN KEY (sentencia_acta_id) REFERENCES sch_gaj.juz_sentencia_acta(id);


--
-- Name: juz_histestape juz_histestape_estado_apelacion_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_histestape
    ADD CONSTRAINT juz_histestape_estado_apelacion_id FOREIGN KEY (estado_apelacion_id) REFERENCES sch_gaj.juz_estado_apelacion(id);


--
-- Name: juz_juez_apelacion juz_juez_apelacion_juz_apelacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_juez_apelacion
    ADD CONSTRAINT juz_juez_apelacion_juz_apelacion_fk FOREIGN KEY (apelacion_id) REFERENCES sch_gaj.juz_apelacion(id);


--
-- Name: juz_juez_apelacion juz_juez_apelacion_juz_sentencia_a_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_juez_apelacion
    ADD CONSTRAINT juz_juez_apelacion_juz_sentencia_a_fk FOREIGN KEY (sentencia_acuerda_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_juez_apelacion juz_juez_apelacion_juz_sentencia_n_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_juez_apelacion
    ADD CONSTRAINT juz_juez_apelacion_juz_sentencia_n_fk FOREIGN KEY (sentencia_nueva_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_juez_apelacion juz_juez_apelacion_pad_juez_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_juez_apelacion
    ADD CONSTRAINT juz_juez_apelacion_pad_juez_fk FOREIGN KEY (juez_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: juz_novedad_siat juz_novedad_siat_corrida_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_novedad_siat
    ADD CONSTRAINT juz_novedad_siat_corrida_id_fkey FOREIGN KEY (corrida_id) REFERENCES sch_gaj.pro_corrida(id);


--
-- Name: juz_pago_sugit juz_pago_sugit_acta_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pago_sugit
    ADD CONSTRAINT juz_pago_sugit_acta_id_fkey FOREIGN KEY (acta_id) REFERENCES sch_gaj.com_acta(id);


--
-- Name: juz_pago_sugit juz_pago_sugit_deuda_siat_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pago_sugit
    ADD CONSTRAINT juz_pago_sugit_deuda_siat_id_fkey FOREIGN KEY (deuda_siat_id) REFERENCES sch_gaj.juz_deuda_siat(id);


--
-- Name: juz_pago_sugit juz_pago_sugit_recibo_siat_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pago_sugit
    ADD CONSTRAINT juz_pago_sugit_recibo_siat_id_fkey FOREIGN KEY (recibo_siat_id) REFERENCES sch_gaj.juz_recibo_siat(id);


--
-- Name: juz_pena_sentencia juz_pena_sentencia_juz_accion_juzgamiento_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pena_sentencia
    ADD CONSTRAINT juz_pena_sentencia_juz_accion_juzgamiento_fk FOREIGN KEY (accion_juzgamiento_id) REFERENCES sch_gaj.juz_accion_juzgamiento(id);


--
-- Name: juz_pena_sentencia juz_pena_sentencia_juz_def_tipo_pena_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pena_sentencia
    ADD CONSTRAINT juz_pena_sentencia_juz_def_tipo_pena_fk FOREIGN KEY (tipo_pena_id) REFERENCES sch_gaj.def_tipo_pena(id);


--
-- Name: juz_pena_sentencia juz_pena_sentencia_juz_sentencia_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_pena_sentencia
    ADD CONSTRAINT juz_pena_sentencia_juz_sentencia_infraccion_fk FOREIGN KEY (sentencia_infraccion_id) REFERENCES sch_gaj.juz_sentencia_infraccion(id);


--
-- Name: juz_periodo_cumplimiento_pena juz_periodo_cumplimiento_pena_juz_pena_sentencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_periodo_cumplimiento_pena
    ADD CONSTRAINT juz_periodo_cumplimiento_pena_juz_pena_sentencia_fk FOREIGN KEY (pena_sentencia_id) REFERENCES sch_gaj.juz_pena_sentencia(id);


--
-- Name: juz_recusacion_excusacion juz_recusacion_excusacion_juz_juez_apelacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_recusacion_excusacion
    ADD CONSTRAINT juz_recusacion_excusacion_juz_juez_apelacion_fk FOREIGN KEY (juez_apelacion_id) REFERENCES sch_gaj.juz_juez_apelacion(id);


--
-- Name: juz_sentencia_acta juz_sentencia_acta_juz_sentencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_acta
    ADD CONSTRAINT juz_sentencia_acta_juz_sentencia_fk FOREIGN KEY (sentencia_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_sentencia_acta juz_sentencia_acta_juz_tipo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_acta
    ADD CONSTRAINT juz_sentencia_acta_juz_tipo FOREIGN KEY (tipo_juzgamiento_id) REFERENCES sch_gaj.juz_tipo_juzgamiento(id);


--
-- Name: juz_sentencia_anulacion juz_sentencia_anulacion_sentencia_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_anulacion
    ADD CONSTRAINT juz_sentencia_anulacion_sentencia_id FOREIGN KEY (sentencia_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_sentencia_imagen juz_sentencia_imagen_com_imagen_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_imagen
    ADD CONSTRAINT juz_sentencia_imagen_com_imagen_fk FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: juz_sentencia_imagen juz_sentencia_imagen_juz_sentencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_imagen
    ADD CONSTRAINT juz_sentencia_imagen_juz_sentencia_fk FOREIGN KEY (sentencia_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_sentencia_infraccion juz_sentencia_infraccion_com_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_infraccion
    ADD CONSTRAINT juz_sentencia_infraccion_com_infraccion_fk FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: juz_sentencia_infraccion juz_sentencia_infraccion_juz_accion_juzgamiento_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_infraccion
    ADD CONSTRAINT juz_sentencia_infraccion_juz_accion_juzgamiento_fk FOREIGN KEY (accion_juzgamiento_id) REFERENCES sch_gaj.juz_accion_juzgamiento(id);


--
-- Name: juz_sentencia_infraccion juz_sentencia_infraccion_juz_sentencia_acta_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_infraccion
    ADD CONSTRAINT juz_sentencia_infraccion_juz_sentencia_acta_fk FOREIGN KEY (juzgamiento_id) REFERENCES sch_gaj.juz_sentencia_acta(id);


--
-- Name: juz_sentencia_proceso_rebeldia juz_sentencia_proceso_rebeldia_proceso_rebeldia; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_proceso_rebeldia
    ADD CONSTRAINT juz_sentencia_proceso_rebeldia_proceso_rebeldia FOREIGN KEY (proceso_rebeldia_id) REFERENCES sch_gaj.juz_proceso_rebeldia(id);


--
-- Name: juz_sentencia_proceso_rebeldia juz_sentencia_proceso_rebeldia_sentencia; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_proceso_rebeldia
    ADD CONSTRAINT juz_sentencia_proceso_rebeldia_sentencia FOREIGN KEY (sentencia_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_sentencia_tramite juz_sentencia_tramite_juz_sentencia_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_tramite
    ADD CONSTRAINT juz_sentencia_tramite_juz_sentencia_fk FOREIGN KEY (sentencia_id) REFERENCES sch_gaj.juz_sentencia(id);


--
-- Name: juz_sentencia_tramite juz_sentencia_tramite_pad_persona_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_sentencia_tramite
    ADD CONSTRAINT juz_sentencia_tramite_pad_persona_fk FOREIGN KEY (persona_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: juz_tribunal_automatico juz_tribunal_automatico_juez1_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tribunal_automatico
    ADD CONSTRAINT juz_tribunal_automatico_juez1_id FOREIGN KEY (juez1_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: juz_tribunal_automatico juz_tribunal_automatico_juez2_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tribunal_automatico
    ADD CONSTRAINT juz_tribunal_automatico_juez2_id FOREIGN KEY (juez2_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: juz_tribunal_automatico juz_tribunal_automatico_juez3_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tribunal_automatico
    ADD CONSTRAINT juz_tribunal_automatico_juez3_id FOREIGN KEY (juez3_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: juz_tribunal_automatico juz_tribunal_automatico_juez4_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.juz_tribunal_automatico
    ADD CONSTRAINT juz_tribunal_automatico_juez4_id FOREIGN KEY (juez4_id) REFERENCES sch_gaj.pad_juez(id);


--
-- Name: not_auxnotificacion not_auxnotificacion_not_lotenotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificacion
    ADD CONSTRAINT not_auxnotificacion_not_lotenotificacion_fk FOREIGN KEY (lote_notificacion_id) REFERENCES sch_gaj.not_lotenotificacion(id);


--
-- Name: not_auxnotificacion not_auxnotificacion_not_procesonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificacion
    ADD CONSTRAINT not_auxnotificacion_not_procesonotificacion_fk FOREIGN KEY (proceso_notificacion_id) REFERENCES sch_gaj.not_procesonotificacion(id);


--
-- Name: not_auxnotificacion not_auxnotificacion_not_tiponotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificacion
    ADD CONSTRAINT not_auxnotificacion_not_tiponotificacion_fk FOREIGN KEY (tipo_notificacion_id) REFERENCES sch_gaj.not_tiponotificacion(id);


--
-- Name: not_auxnotificaciondetalle not_auxnotificaciondetalle_not_auxnotificacion_id_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificaciondetalle
    ADD CONSTRAINT not_auxnotificaciondetalle_not_auxnotificacion_id_fk FOREIGN KEY (auxnotificacion_id) REFERENCES sch_gaj.not_auxnotificacion(id);


--
-- Name: not_auxnotificaciondetalle not_auxnotificaciondetalle_not_tipobjnot_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_auxnotificaciondetalle
    ADD CONSTRAINT not_auxnotificaciondetalle_not_tipobjnot_fk FOREIGN KEY (tip_obj_not_id) REFERENCES sch_gaj.not_tipobjnot(id);


--
-- Name: not_grupo_notificacion_localidad not_grupo_notificacion_localidad_grupo_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_grupo_notificacion_localidad
    ADD CONSTRAINT not_grupo_notificacion_localidad_grupo_id FOREIGN KEY (grupo_notificacion_id) REFERENCES sch_gaj.not_grupo_notificacion(id);


--
-- Name: not_hisestnot not_hisestnot_not_estadonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_hisestnot
    ADD CONSTRAINT not_hisestnot_not_estadonotificacion_fk FOREIGN KEY (estado_actual_id) REFERENCES sch_gaj.not_estadonotificacion(id);


--
-- Name: not_hisestnot not_hisestnot_not_notificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_hisestnot
    ADD CONSTRAINT not_hisestnot_not_notificacion_fk FOREIGN KEY (notificacion_id) REFERENCES sch_gaj.not_notificacion(id);


--
-- Name: not_lotenotificacion not_lotenotificacion_not_procesonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_lotenotificacion
    ADD CONSTRAINT not_lotenotificacion_not_procesonotificacion_fk FOREIGN KEY (proceso_notificacion_id) REFERENCES sch_gaj.not_procesonotificacion(id);


--
-- Name: not_lotenotificacion not_lotenotificacion_not_zonanotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_lotenotificacion
    ADD CONSTRAINT not_lotenotificacion_not_zonanotificacion_fk FOREIGN KEY (zona_notificacion_id) REFERENCES sch_gaj.not_zonanotificacion(id);


--
-- Name: not_notificacion_imagen not_notificacion_imagen_com_imagen_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion_imagen
    ADD CONSTRAINT not_notificacion_imagen_com_imagen_fk FOREIGN KEY (imagen_id) REFERENCES sch_gaj.com_imagen(id);


--
-- Name: not_notificacion_imagen not_notificacion_imagen_not_notificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion_imagen
    ADD CONSTRAINT not_notificacion_imagen_not_notificacion_fk FOREIGN KEY (notificacion_id) REFERENCES sch_gaj.not_notificacion(id);


--
-- Name: not_notificacion not_notificacion_not_estadonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion
    ADD CONSTRAINT not_notificacion_not_estadonotificacion_fk FOREIGN KEY (estado_notificacion_id) REFERENCES sch_gaj.not_estadonotificacion(id);


--
-- Name: not_notificacion not_notificacion_not_lotenotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion
    ADD CONSTRAINT not_notificacion_not_lotenotificacion_fk FOREIGN KEY (lote_notificacion_id) REFERENCES sch_gaj.not_lotenotificacion(id);


--
-- Name: not_notificacion not_notificacion_not_notificador_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion
    ADD CONSTRAINT not_notificacion_not_notificador_fk FOREIGN KEY (notificador_id) REFERENCES sch_gaj.not_notificador(id);


--
-- Name: not_notificacion not_notificacion_not_tiponotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificacion
    ADD CONSTRAINT not_notificacion_not_tiponotificacion_fk FOREIGN KEY (tipo_notificacion_id) REFERENCES sch_gaj.not_tiponotificacion(id);


--
-- Name: not_notificaciondetalle not_notificaciondetalle_not_notificacion_id_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificaciondetalle
    ADD CONSTRAINT not_notificaciondetalle_not_notificacion_id_fk FOREIGN KEY (notificacion_id) REFERENCES sch_gaj.not_notificacion(id);


--
-- Name: not_notificaciondetalle not_notificaciondetalle_not_tipobjnot_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_notificaciondetalle
    ADD CONSTRAINT not_notificaciondetalle_not_tipobjnot_fk FOREIGN KEY (tip_obj_not_id) REFERENCES sch_gaj.not_tipobjnot(id);


--
-- Name: not_procesonotificacion not_procesonotificacion_grupo_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion
    ADD CONSTRAINT not_procesonotificacion_grupo_id FOREIGN KEY (grupo_notificacion_id) REFERENCES sch_gaj.not_grupo_notificacion(id);


--
-- Name: not_procesonotificacion_infraccion not_procesonotificacion_infraccion_com_infraccion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_infraccion
    ADD CONSTRAINT not_procesonotificacion_infraccion_com_infraccion_fk FOREIGN KEY (infraccion_id) REFERENCES sch_gaj.com_infraccion(id);


--
-- Name: not_procesonotificacion_infraccion not_procesonotificacion_infraccion_not_procesonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_infraccion
    ADD CONSTRAINT not_procesonotificacion_infraccion_not_procesonotificacion_fk FOREIGN KEY (proceso_notificacion_id) REFERENCES sch_gaj.not_procesonotificacion(id);


--
-- Name: not_procesonotificacion not_procesonotificacion_not_tiponotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion
    ADD CONSTRAINT not_procesonotificacion_not_tiponotificacion_fk FOREIGN KEY (tipo_notificacion_id) REFERENCES sch_gaj.not_tiponotificacion(id);


--
-- Name: not_procesonotificacion_objeto not_procesonotificacion_objeto_com_tipo_objeto_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_objeto
    ADD CONSTRAINT not_procesonotificacion_objeto_com_tipo_objeto_fk FOREIGN KEY (tipo_objeto_id) REFERENCES sch_gaj.com_tipo_objeto(id);


--
-- Name: not_procesonotificacion_objeto not_procesonotificacion_objeto_not_procesonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_objeto
    ADD CONSTRAINT not_procesonotificacion_objeto_not_procesonotificacion_fk FOREIGN KEY (proceso_notificacion_id) REFERENCES sch_gaj.not_procesonotificacion(id);


--
-- Name: not_procesonotificacion_reparticion not_procesonotificacion_reparticion_def_reparticion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_reparticion
    ADD CONSTRAINT not_procesonotificacion_reparticion_def_reparticion_fk FOREIGN KEY (reparticion_id) REFERENCES sch_gaj.def_reparticion(id);


--
-- Name: not_procesonotificacion_reparticion not_procesonotificacion_reparticion_not_procesonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_reparticion
    ADD CONSTRAINT not_procesonotificacion_reparticion_not_procesonotificacion_fk FOREIGN KEY (proceso_notificacion_id) REFERENCES sch_gaj.not_procesonotificacion(id);


--
-- Name: not_procesonotificacion_zona not_procesonotificacion_zona_not_procesonotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_zona
    ADD CONSTRAINT not_procesonotificacion_zona_not_procesonotificacion_fk FOREIGN KEY (proceso_notificacion_id) REFERENCES sch_gaj.not_procesonotificacion(id);


--
-- Name: not_procesonotificacion_zona not_procesonotificacion_zona_not_zonanotificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_procesonotificacion_zona
    ADD CONSTRAINT not_procesonotificacion_zona_not_zonanotificacion_fk FOREIGN KEY (zona_notificacion_id) REFERENCES sch_gaj.not_zonanotificacion(id);


--
-- Name: not_registro_servicios_publicos not_registro_servicios_publicos_persona_id_notificar; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_registro_servicios_publicos
    ADD CONSTRAINT not_registro_servicios_publicos_persona_id_notificar FOREIGN KEY (persona_id_notificar) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: not_registro_servicios_publicos not_registro_servicios_publicos_tipo_objeto_id; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_registro_servicios_publicos
    ADD CONSTRAINT not_registro_servicios_publicos_tipo_objeto_id FOREIGN KEY (tipo_objeto_id) REFERENCES sch_gaj.com_tipo_objeto(id);


--
-- Name: not_tiponotificacion not_tiponotificacion_for_formulario_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tiponotificacion
    ADD CONSTRAINT not_tiponotificacion_for_formulario_fk FOREIGN KEY (formulario_id) REFERENCES sch_gaj.for_formulario(id);


--
-- Name: not_tiponotificacion not_tiponotificacion_not_tipobjnot_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.not_tiponotificacion
    ADD CONSTRAINT not_tiponotificacion_not_tipobjnot_fk FOREIGN KEY (tip_obj_not_id) REFERENCES sch_gaj.not_tipobjnot(id);


--
-- Name: pad_agente_reparticion pad_agente_reparticion_agente_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_agente_reparticion
    ADD CONSTRAINT pad_agente_reparticion_agente_id_fkey FOREIGN KEY (agente_id) REFERENCES sch_gaj.pad_agente(id);


--
-- Name: pad_agente_reparticion pad_agente_reparticion_reparticion_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_agente_reparticion
    ADD CONSTRAINT pad_agente_reparticion_reparticion_id_fkey FOREIGN KEY (reparticion_id) REFERENCES sch_gaj.def_reparticion(id);


--
-- Name: pad_autorizado pad_autorizado_persona_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_autorizado
    ADD CONSTRAINT pad_autorizado_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: pad_juez pad_juez_juzgado_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juez
    ADD CONSTRAINT pad_juez_juzgado_id_fkey FOREIGN KEY (juzgado_id) REFERENCES sch_gaj.pad_juzgado(id);


--
-- Name: pad_juez pad_juez_persona_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juez
    ADD CONSTRAINT pad_juez_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: pad_juez pad_juez_usuario_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_juez
    ADD CONSTRAINT pad_juez_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES sch_gaj.def_usuario(id);


--
-- Name: pad_titular pad_titular_persona_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_titular
    ADD CONSTRAINT pad_titular_persona_id_fkey FOREIGN KEY (persona_id) REFERENCES sch_gaj.pad_persona(id);


--
-- Name: pad_vehiculo_audit pad_vehiculo_audit_revinfo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_audit
    ADD CONSTRAINT pad_vehiculo_audit_revinfo FOREIGN KEY (revision_id) REFERENCES sch_gaj.com_revision_info(id);


--
-- Name: pad_vehiculo_autorizado_audit pad_vehiculo_autorizado_audit_revinfo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_autorizado_audit
    ADD CONSTRAINT pad_vehiculo_autorizado_audit_revinfo FOREIGN KEY (revision_id) REFERENCES sch_gaj.com_revision_info(id);


--
-- Name: pad_vehiculo_autorizado pad_vehiculo_autorizado_autorizado_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_autorizado
    ADD CONSTRAINT pad_vehiculo_autorizado_autorizado_id_fkey FOREIGN KEY (autorizado_id) REFERENCES sch_gaj.pad_autorizado(id);


--
-- Name: pad_vehiculo_autorizado pad_vehiculo_autorizado_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_autorizado
    ADD CONSTRAINT pad_vehiculo_autorizado_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES sch_gaj.pad_vehiculo(id);


--
-- Name: pad_vehiculo pad_vehiculo_tipo_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo
    ADD CONSTRAINT pad_vehiculo_tipo_vehiculo_id_fkey FOREIGN KEY (tipo_vehiculo_id) REFERENCES sch_gaj.pad_tipovehiculo(id);


--
-- Name: pad_vehiculo_titular_audit pad_vehiculo_titular_audit_revinfo; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_titular_audit
    ADD CONSTRAINT pad_vehiculo_titular_audit_revinfo FOREIGN KEY (revision_id) REFERENCES sch_gaj.com_revision_info(id);


--
-- Name: pad_vehiculo_titular pad_vehiculo_titular_titulares_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_titular
    ADD CONSTRAINT pad_vehiculo_titular_titulares_id_fkey FOREIGN KEY (titular_id) REFERENCES sch_gaj.pad_titular(id);


--
-- Name: pad_vehiculo_titular pad_vehiculo_titular_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.pad_vehiculo_titular
    ADD CONSTRAINT pad_vehiculo_titular_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES sch_gaj.pad_vehiculo(id);


--
-- Name: tra_notificacion_tramite tra_notificacion_tramite_not_notificacion_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_notificacion_tramite
    ADD CONSTRAINT tra_notificacion_tramite_not_notificacion_fk FOREIGN KEY (notificacion_id) REFERENCES sch_gaj.not_notificacion(id);


--
-- Name: tra_notificacion_tramite tra_notificacion_tramite_tra_estado_notificacion_tramite_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_notificacion_tramite
    ADD CONSTRAINT tra_notificacion_tramite_tra_estado_notificacion_tramite_fk FOREIGN KEY (estado_notificacion_tramite_id) REFERENCES sch_gaj.tra_estado_notificacion_tramite(id);


--
-- Name: tra_notificacion_tramite tra_notificacion_tramite_tra_usuario_tramite_fk; Type: FK CONSTRAINT; Schema: sch_gaj; Owner: gaj_owner
--

ALTER TABLE ONLY sch_gaj.tra_notificacion_tramite
    ADD CONSTRAINT tra_notificacion_tramite_tra_usuario_tramite_fk FOREIGN KEY (usuario_tramite_id) REFERENCES sch_gaj.tra_usuario_tramite(id);


--
-- Name: SCHEMA sch_gaj; Type: ACL; Schema: -; Owner: gaj_owner
--

GRANT ALL ON SCHEMA sch_gaj TO gaj_rw;
GRANT ALL ON SCHEMA sch_gaj TO gaj_r;


--
-- Name: FUNCTION actualizar_persona_ids(idpersonaold bigint, idpersonanew bigint); Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON FUNCTION sch_gaj.actualizar_persona_ids(idpersonaold bigint, idpersonanew bigint) TO gaj_r;
GRANT ALL ON FUNCTION sch_gaj.actualizar_persona_ids(idpersonaold bigint, idpersonanew bigint) TO gaj_rw;


--
-- Name: FUNCTION insert_inventario(); Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON FUNCTION sch_gaj.insert_inventario() TO gaj_r;
GRANT ALL ON FUNCTION sch_gaj.insert_inventario() TO gaj_rw;


--
-- Name: FUNCTION insert_pad_vehiculo_hist(); Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON FUNCTION sch_gaj.insert_pad_vehiculo_hist() TO gaj_r;
GRANT ALL ON FUNCTION sch_gaj.insert_pad_vehiculo_hist() TO gaj_rw;


--
-- Name: FUNCTION insert_traslado(); Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON FUNCTION sch_gaj.insert_traslado() TO gaj_r;
GRANT ALL ON FUNCTION sch_gaj.insert_traslado() TO gaj_rw;


--
-- Name: FUNCTION insert_verificaciontecnica(); Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON FUNCTION sch_gaj.insert_verificaciontecnica() TO gaj_r;
GRANT ALL ON FUNCTION sch_gaj.insert_verificaciontecnica() TO gaj_rw;


--
-- Name: FUNCTION populate_agente_reparticion_table(); Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON FUNCTION sch_gaj.populate_agente_reparticion_table() TO gaj_r;
GRANT ALL ON FUNCTION sch_gaj.populate_agente_reparticion_table() TO gaj_rw;


--
-- Name: TABLE cla_clausura; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_clausura TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_clausura TO gaj_rw;


--
-- Name: TABLE cla_clausura_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_clausura_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_clausura_acta TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_acta_id_seq TO gaj_rw;


--
-- Name: TABLE cla_clausura_definitiva; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_clausura_definitiva TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_clausura_definitiva TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_definitiva_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_definitiva_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_definitiva_id_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_id_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2000_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2000_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2000_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2003_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2003_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2003_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2004_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2004_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2004_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2005_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2005_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2005_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2006_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2006_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2006_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2007_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2007_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2007_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2008_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2008_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2008_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2009_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2009_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2009_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2010_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2010_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2010_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2011_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2011_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2011_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2012_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2012_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2012_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2013_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2013_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2013_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2014_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2014_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2014_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2015_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2015_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2015_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2016_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2016_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2016_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2017_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2017_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2017_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2018_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2018_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2018_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2019_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2019_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2019_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_numero_2020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_numero_2020_seq TO gaj_rw;


--
-- Name: TABLE cla_clausura_status; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_clausura_status TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_clausura_status TO gaj_rw;


--
-- Name: SEQUENCE cla_clausura_status_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_status_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_clausura_status_id_seq TO gaj_rw;


--
-- Name: TABLE cla_detalle_clausura; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_detalle_clausura TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_detalle_clausura TO gaj_rw;


--
-- Name: TABLE cla_detalle_clausura_hist; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_detalle_clausura_hist TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_detalle_clausura_hist TO gaj_rw;


--
-- Name: SEQUENCE cla_detalle_clausura_hist_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_detalle_clausura_hist_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_detalle_clausura_hist_id_seq TO gaj_rw;


--
-- Name: SEQUENCE cla_detalle_clausura_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_detalle_clausura_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_detalle_clausura_id_seq TO gaj_rw;


--
-- Name: TABLE cla_levantamiento_clausura; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_levantamiento_clausura TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_levantamiento_clausura TO gaj_rw;


--
-- Name: SEQUENCE cla_levantamiento_clausura_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_levantamiento_clausura_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_levantamiento_clausura_id_seq TO gaj_rw;


--
-- Name: TABLE cla_oficio_desprecintamiento; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_oficio_desprecintamiento TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_oficio_desprecintamiento TO gaj_rw;


--
-- Name: SEQUENCE cla_oficio_desprecintamiento_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_oficio_desprecintamiento_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_oficio_desprecintamiento_id_seq TO gaj_rw;


--
-- Name: TABLE cla_reanudacion_clausura; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_reanudacion_clausura TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_reanudacion_clausura TO gaj_rw;


--
-- Name: SEQUENCE cla_reanudacion_clausura_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_reanudacion_clausura_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_reanudacion_clausura_id_seq TO gaj_rw;


--
-- Name: TABLE cla_suspencion_clausura; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cla_suspencion_clausura TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cla_suspencion_clausura TO gaj_rw;


--
-- Name: SEQUENCE cla_suspencion_clausura_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cla_suspencion_clausura_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cla_suspencion_clausura_id_seq TO gaj_rw;


--
-- Name: TABLE com_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta TO gaj_rw;


--
-- Name: TABLE com_acta_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta_audit TO gaj_rw;


--
-- Name: TABLE com_acta_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta_backup TO gaj_rw;


--
-- Name: SEQUENCE com_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_acta_id_seq TO gaj_rw;


--
-- Name: TABLE com_acta_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta_infraccion TO gaj_rw;


--
-- Name: TABLE com_acta_infraccion_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta_infraccion_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta_infraccion_audit TO gaj_rw;


--
-- Name: TABLE com_acta_infraccion_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta_infraccion_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta_infraccion_backup TO gaj_rw;


--
-- Name: SEQUENCE com_acta_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_acta_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_acta_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE com_acta_inspeccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta_inspeccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta_inspeccion TO gaj_rw;


--
-- Name: SEQUENCE com_acta_inspeccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_acta_inspeccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_acta_inspeccion_id_seq TO gaj_rw;


--
-- Name: TABLE com_acta_recepcion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_acta_recepcion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_acta_recepcion TO gaj_rw;


--
-- Name: SEQUENCE com_acta_recepcion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_acta_recepcion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_acta_recepcion_id_seq TO gaj_rw;


--
-- Name: TABLE com_actaimagen; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_actaimagen TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_actaimagen TO gaj_rw;


--
-- Name: TABLE com_actaimagen_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_actaimagen_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_actaimagen_audit TO gaj_rw;


--
-- Name: TABLE com_actaimagen_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_actaimagen_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_actaimagen_backup TO gaj_rw;


--
-- Name: SEQUENCE com_actaimagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_actaimagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_actaimagen_id_seq TO gaj_rw;


--
-- Name: TABLE com_actatransitoprovisoria; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_actatransitoprovisoria TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_actatransitoprovisoria TO gaj_rw;


--
-- Name: SEQUENCE com_actatransitoprovisoria_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_actatransitoprovisoria_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_actatransitoprovisoria_id_seq TO gaj_rw;


--
-- Name: TABLE com_audiencia_imagen; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_audiencia_imagen TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_audiencia_imagen TO gaj_rw;


--
-- Name: SEQUENCE com_audiencia_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_audiencia_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_audiencia_imagen_id_seq TO gaj_rw;


--
-- Name: TABLE com_background_run; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_background_run TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_background_run TO gaj_rw;


--
-- Name: SEQUENCE com_background_run_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_background_run_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_background_run_id_seq TO gaj_rw;


--
-- Name: TABLE com_background_task; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_background_task TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_background_task TO gaj_rw;


--
-- Name: SEQUENCE com_background_task_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_background_task_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_background_task_id_seq TO gaj_rw;


--
-- Name: TABLE com_detalle_objeto; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_detalle_objeto TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_detalle_objeto TO gaj_rw;


--
-- Name: TABLE com_detalle_objeto_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_detalle_objeto_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_detalle_objeto_audit TO gaj_rw;


--
-- Name: TABLE com_detalle_objeto_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_detalle_objeto_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_detalle_objeto_backup TO gaj_rw;


--
-- Name: SEQUENCE com_detalle_objeto_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_detalle_objeto_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_detalle_objeto_id_seq TO gaj_rw;


--
-- Name: TABLE com_detalle_oficio; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_detalle_oficio TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_detalle_oficio TO gaj_rw;


--
-- Name: SEQUENCE com_detalle_oficio_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_detalle_oficio_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_detalle_oficio_id_seq TO gaj_rw;


--
-- Name: TABLE com_detalle_pena_clausura; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_detalle_pena_clausura TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_detalle_pena_clausura TO gaj_rw;


--
-- Name: SEQUENCE com_detalle_pena_clausura_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_detalle_pena_clausura_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_detalle_pena_clausura_id_seq TO gaj_rw;


--
-- Name: TABLE com_domicilio; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_domicilio TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_domicilio TO gaj_rw;


--
-- Name: TABLE com_domicilio_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_domicilio_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_domicilio_backup TO gaj_rw;


--
-- Name: SEQUENCE com_domicilio_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_domicilio_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_domicilio_id_seq TO gaj_rw;


--
-- Name: TABLE com_estado_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_estado_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_estado_acta TO gaj_rw;


--
-- Name: SEQUENCE com_estado_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_estado_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_estado_acta_id_seq TO gaj_rw;


--
-- Name: TABLE com_imagen; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_imagen TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_imagen TO gaj_rw;


--
-- Name: TABLE com_imagen_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_imagen_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_imagen_backup TO gaj_rw;


--
-- Name: SEQUENCE com_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_imagen_id_seq TO gaj_rw;


--
-- Name: TABLE com_imagen_vieja; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_imagen_vieja TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_imagen_vieja TO gaj_rw;


--
-- Name: TABLE com_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_infraccion TO gaj_rw;


--
-- Name: SEQUENCE com_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE com_infraccionprovisoria; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_infraccionprovisoria TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_infraccionprovisoria TO gaj_rw;


--
-- Name: SEQUENCE com_infraccionprovisoria_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_infraccionprovisoria_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_infraccionprovisoria_id_seq TO gaj_rw;


--
-- Name: SEQUENCE com_libera_numero_liberacion_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_libera_numero_liberacion_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_libera_numero_liberacion_seq TO gaj_rw;


--
-- Name: TABLE com_libera_requisito; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_libera_requisito TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_libera_requisito TO gaj_rw;


--
-- Name: SEQUENCE com_libera_requisito_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_libera_requisito_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_libera_requisito_id_seq TO gaj_rw;


--
-- Name: TABLE com_liberacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_liberacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_liberacion TO gaj_rw;


--
-- Name: SEQUENCE com_liberacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_liberacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_liberacion_id_seq TO gaj_rw;


--
-- Name: TABLE com_lote; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_lote TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_lote TO gaj_rw;


--
-- Name: SEQUENCE com_lote_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_lote_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_lote_id_seq TO gaj_rw;


--
-- Name: TABLE com_loteitem; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_loteitem TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_loteitem TO gaj_rw;


--
-- Name: SEQUENCE com_loteitem_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_loteitem_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_loteitem_id_seq TO gaj_rw;


--
-- Name: TABLE com_oficio; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_oficio TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_oficio TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_id_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_19_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_19_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_19_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2003_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2003_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2003_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2004_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2004_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2004_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2005_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2005_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2005_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2006_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2006_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2006_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2007_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2007_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2007_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2008_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2008_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2008_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2009_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2009_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2009_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2010_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2010_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2010_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2011_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2011_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2011_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2012_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2012_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2012_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2013_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2013_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2013_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2014_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2014_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2014_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2015_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2015_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2015_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2016_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2016_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2016_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2017_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2017_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2017_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2018_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2018_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2018_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2019_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2019_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2019_seq TO gaj_rw;


--
-- Name: SEQUENCE com_oficio_numero_2020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_oficio_numero_2020_seq TO gaj_rw;


--
-- Name: TABLE com_presunto_infractor; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_presunto_infractor TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_presunto_infractor TO gaj_rw;


--
-- Name: TABLE com_presunto_infractor_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_presunto_infractor_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_presunto_infractor_audit TO gaj_rw;


--
-- Name: SEQUENCE com_presunto_infractor_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_presunto_infractor_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_presunto_infractor_id_seq TO gaj_rw;


--
-- Name: TABLE com_proposito_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_proposito_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_proposito_acta TO gaj_rw;


--
-- Name: SEQUENCE com_proposito_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_proposito_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_proposito_acta_id_seq TO gaj_rw;


--
-- Name: SEQUENCE com_punto_domicilio_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT UPDATE ON SEQUENCE sch_gaj.com_punto_domicilio_id_seq TO gaj_r;
GRANT SELECT,USAGE ON SEQUENCE sch_gaj.com_punto_domicilio_id_seq TO gaj_r WITH GRANT OPTION;
GRANT ALL ON SEQUENCE sch_gaj.com_punto_domicilio_id_seq TO gaj_rw WITH GRANT OPTION;


--
-- Name: TABLE com_punto_domicilio; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_punto_domicilio TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_punto_domicilio TO gaj_rw;


--
-- Name: TABLE com_punto_domicilio_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_punto_domicilio_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_punto_domicilio_backup TO gaj_rw;


--
-- Name: TABLE com_punto_domicilio_vieja; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_punto_domicilio_vieja TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_punto_domicilio_vieja TO gaj_rw;


--
-- Name: TABLE com_revision_info; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_revision_info TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_revision_info TO gaj_rw;


--
-- Name: TABLE com_sugerencia_destino; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_sugerencia_destino TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_sugerencia_destino TO gaj_rw;


--
-- Name: SEQUENCE com_sugerencia_destino_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_sugerencia_destino_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_sugerencia_destino_id_seq TO gaj_rw;


--
-- Name: TABLE com_tipo_imagen; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_tipo_imagen TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_tipo_imagen TO gaj_rw;


--
-- Name: SEQUENCE com_tipo_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_tipo_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_tipo_imagen_id_seq TO gaj_rw;


--
-- Name: TABLE com_tipo_objeto; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_tipo_objeto TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_tipo_objeto TO gaj_rw;


--
-- Name: SEQUENCE com_tipo_objeto_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_tipo_objeto_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_tipo_objeto_id_seq TO gaj_rw;


--
-- Name: TABLE com_tipo_oficio; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_tipo_oficio TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_tipo_oficio TO gaj_rw;


--
-- Name: SEQUENCE com_tipo_oficio_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_tipo_oficio_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_tipo_oficio_id_seq TO gaj_rw;


--
-- Name: TABLE com_tipoacta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_tipoacta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_tipoacta TO gaj_rw;


--
-- Name: SEQUENCE com_tipoacta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_tipoacta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_tipoacta_id_seq TO gaj_rw;


--
-- Name: TABLE com_tipoacta_reparticion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.com_tipoacta_reparticion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.com_tipoacta_reparticion TO gaj_rw;


--
-- Name: SEQUENCE com_tipoacta_reparticion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.com_tipoacta_reparticion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.com_tipoacta_reparticion_id_seq TO gaj_rw;


--
-- Name: TABLE cor_actaestado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_actaestado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_actaestado TO gaj_rw;


--
-- Name: SEQUENCE cor_actaestado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_actaestado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_actaestado_id_seq TO gaj_rw;


--
-- Name: TABLE cor_egreso; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_egreso TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_egreso TO gaj_rw;


--
-- Name: SEQUENCE cor_egreso_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_egreso_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_egreso_id_seq TO gaj_rw;


--
-- Name: TABLE cor_finalizartraslado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_finalizartraslado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_finalizartraslado TO gaj_rw;


--
-- Name: SEQUENCE cor_finalizartraslado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_finalizartraslado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_finalizartraslado_id_seq TO gaj_rw;


--
-- Name: TABLE cor_ingreso; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_ingreso TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_ingreso TO gaj_rw;


--
-- Name: SEQUENCE cor_ingreso_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_ingreso_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_ingreso_id_seq TO gaj_rw;


--
-- Name: TABLE cor_iniciotraslado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_iniciotraslado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_iniciotraslado TO gaj_rw;


--
-- Name: SEQUENCE cor_iniciotraslado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_iniciotraslado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_iniciotraslado_id_seq TO gaj_rw;


--
-- Name: TABLE cor_inventario; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_inventario TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_inventario TO gaj_rw;


--
-- Name: SEQUENCE cor_inventario_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_id_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_inventario_nro_inventario_2018_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_nro_inventario_2018_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_nro_inventario_2018_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_inventario_nro_inventario_2019_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_nro_inventario_2019_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_nro_inventario_2019_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_inventario_nro_inventario_2020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_nro_inventario_2020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_inventario_nro_inventario_2020_seq TO gaj_rw;


--
-- Name: TABLE cor_novedad; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_novedad TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_novedad TO gaj_rw;


--
-- Name: SEQUENCE cor_novedad_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_novedad_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_novedad_id_seq TO gaj_rw;


--
-- Name: TABLE cor_recepciontraslado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_recepciontraslado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_recepciontraslado TO gaj_rw;


--
-- Name: SEQUENCE cor_recepciontraslado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_recepciontraslado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_recepciontraslado_id_seq TO gaj_rw;


--
-- Name: TABLE cor_sector; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_sector TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_sector TO gaj_rw;


--
-- Name: SEQUENCE cor_sector_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_sector_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_sector_id_seq TO gaj_rw;


--
-- Name: TABLE cor_tipocorralon; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_tipocorralon TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_tipocorralon TO gaj_rw;


--
-- Name: SEQUENCE cor_tipocorralon_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_tipocorralon_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_tipocorralon_id_seq TO gaj_rw;


--
-- Name: TABLE cor_tipodestino; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_tipodestino TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_tipodestino TO gaj_rw;


--
-- Name: SEQUENCE cor_tipodestino_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_tipodestino_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_tipodestino_id_seq TO gaj_rw;


--
-- Name: TABLE cor_tipoegreso; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_tipoegreso TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_tipoegreso TO gaj_rw;


--
-- Name: SEQUENCE cor_tipoegreso_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_tipoegreso_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_tipoegreso_id_seq TO gaj_rw;


--
-- Name: TABLE cor_tipovehiculoacarreo; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_tipovehiculoacarreo TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_tipovehiculoacarreo TO gaj_rw;


--
-- Name: SEQUENCE cor_tipovehiculoacarreo_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_tipovehiculoacarreo_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_tipovehiculoacarreo_id_seq TO gaj_rw;


--
-- Name: TABLE cor_traslado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_traslado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_traslado TO gaj_rw;


--
-- Name: SEQUENCE cor_traslado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_id_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_traslado_nro_traslado_2018_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_nro_traslado_2018_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_nro_traslado_2018_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_traslado_nro_traslado_2019_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_nro_traslado_2019_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_nro_traslado_2019_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_traslado_nro_traslado_2020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_nro_traslado_2020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_nro_traslado_2020_seq TO gaj_rw;


--
-- Name: TABLE cor_traslado_traslado_inventarios; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_traslado_traslado_inventarios TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_traslado_traslado_inventarios TO gaj_rw;


--
-- Name: SEQUENCE cor_traslado_traslado_inventarios_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_traslado_inventarios_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_traslado_traslado_inventarios_id_seq TO gaj_rw;


--
-- Name: TABLE cor_vehiculoacarreo; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_vehiculoacarreo TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_vehiculoacarreo TO gaj_rw;


--
-- Name: SEQUENCE cor_vehiculoacarreo_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_vehiculoacarreo_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_vehiculoacarreo_id_seq TO gaj_rw;


--
-- Name: TABLE pad_persona; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_persona TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_persona TO gaj_rw;


--
-- Name: TABLE pad_vehiculo; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo TO gaj_rw;


--
-- Name: TABLE cor_vehiculos_egresados; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_vehiculos_egresados TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_vehiculos_egresados TO gaj_rw;


--
-- Name: TABLE cor_vehiculos_en_existencia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_vehiculos_en_existencia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_vehiculos_en_existencia TO gaj_rw;


--
-- Name: TABLE cor_verificaciontecnica; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.cor_verificaciontecnica TO gaj_r;
GRANT ALL ON TABLE sch_gaj.cor_verificaciontecnica TO gaj_rw;


--
-- Name: SEQUENCE cor_verificaciontecnica_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_id_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_verificaciontecnica_numero_2018_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2018_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2018_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_verificaciontecnica_numero_2019_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2019_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2019_seq TO gaj_rw;


--
-- Name: SEQUENCE cor_verificaciontecnica_numero_2020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.cor_verificaciontecnica_numero_2020_seq TO gaj_rw;


--
-- Name: TABLE def_alternativalib; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_alternativalib TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_alternativalib TO gaj_rw;


--
-- Name: SEQUENCE def_alternativalib_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_alternativalib_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_alternativalib_id_seq TO gaj_rw;


--
-- Name: TABLE def_causal_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_causal_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_causal_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_causal_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_causal_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_causal_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_concepto_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_concepto_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_concepto_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_concepto_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_concepto_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_concepto_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_especie_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_especie_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_especie_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_especie_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_especie_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_especie_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_excluida_sugit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_excluida_sugit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_excluida_sugit TO gaj_rw;


--
-- Name: SEQUENCE def_excluida_sugit_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_excluida_sugit_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_excluida_sugit_id_seq TO gaj_rw;


--
-- Name: TABLE def_normativa_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_normativa_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_normativa_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_normativa_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_normativa_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_normativa_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_parametro; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_parametro TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_parametro TO gaj_rw;


--
-- Name: SEQUENCE def_parametro_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_parametro_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_parametro_id_seq TO gaj_rw;


--
-- Name: TABLE def_particularidadlib; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_particularidadlib TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_particularidadlib TO gaj_rw;


--
-- Name: SEQUENCE def_particularidadlib_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_particularidadlib_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_particularidadlib_id_seq TO gaj_rw;


--
-- Name: TABLE def_pena_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_pena_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_pena_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_pena_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_pena_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_pena_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_pena_regla_reincidencia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_pena_regla_reincidencia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_pena_regla_reincidencia TO gaj_rw;


--
-- Name: SEQUENCE def_pena_regla_reincidencia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_pena_regla_reincidencia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_pena_regla_reincidencia_id_seq TO gaj_rw;


--
-- Name: TABLE def_penalidad_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_penalidad_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_penalidad_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_penalidad_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_penalidad_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_penalidad_infraccion_id_seq TO gaj_rw;


--
-- Name: SEQUENCE def_penalidad_infraccion_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_penalidad_infraccion_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_penalidad_infraccion_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_permiso_funcional; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_permiso_funcional TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_permiso_funcional TO gaj_rw;


--
-- Name: SEQUENCE def_permiso_funcional_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_permiso_funcional_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_permiso_funcional_id_seq TO gaj_rw;


--
-- Name: TABLE def_permiso_funcional_usuario; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_permiso_funcional_usuario TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_permiso_funcional_usuario TO gaj_rw;


--
-- Name: SEQUENCE def_permiso_funcional_usuario_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_permiso_funcional_usuario_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_permiso_funcional_usuario_id_seq TO gaj_rw;


--
-- Name: TABLE def_regimen_juzgamiento; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_regimen_juzgamiento TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_regimen_juzgamiento TO gaj_rw;


--
-- Name: SEQUENCE def_regimen_juzgamiento_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_regimen_juzgamiento_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_regimen_juzgamiento_id_seq TO gaj_rw;


--
-- Name: SEQUENCE def_regimen_juzgamiento_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_regimen_juzgamiento_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_regimen_juzgamiento_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_regla_reincidencia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_regla_reincidencia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_regla_reincidencia TO gaj_rw;


--
-- Name: SEQUENCE def_regla_reincidencia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_regla_reincidencia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_regla_reincidencia_id_seq TO gaj_rw;


--
-- Name: TABLE def_regla_reincidencia_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_regla_reincidencia_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_regla_reincidencia_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_regla_reincidencia_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_regla_reincidencia_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_regla_reincidencia_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_reparticion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_reparticion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_reparticion TO gaj_rw;


--
-- Name: SEQUENCE def_reparticion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_reparticion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_reparticion_id_seq TO gaj_rw;


--
-- Name: TABLE def_requisitolib; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_requisitolib TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_requisitolib TO gaj_rw;


--
-- Name: SEQUENCE def_requisitolib_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_requisitolib_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_requisitolib_id_seq TO gaj_rw;


--
-- Name: TABLE def_requisitoslibveh; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_requisitoslibveh TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_requisitoslibveh TO gaj_rw;


--
-- Name: SEQUENCE def_requisitoslibveh_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_requisitoslibveh_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_requisitoslibveh_id_seq TO gaj_rw;


--
-- Name: TABLE def_subespecie_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_subespecie_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_subespecie_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_subespecie_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_subespecie_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_subespecie_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_tipo_pago_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_tipo_pago_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_tipo_pago_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_tipo_pago_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_tipo_pago_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_tipo_pago_infraccion_id_seq TO gaj_rw;


--
-- Name: SEQUENCE def_tipo_pago_infraccion_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_tipo_pago_infraccion_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_tipo_pago_infraccion_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE def_tipo_pena; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_tipo_pena TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_tipo_pena TO gaj_rw;


--
-- Name: SEQUENCE def_tipo_pena_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_tipo_pena_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_tipo_pena_id_seq TO gaj_rw;


--
-- Name: TABLE def_tipovehiculolibera; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_tipovehiculolibera TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_tipovehiculolibera TO gaj_rw;


--
-- Name: SEQUENCE def_tipovehiculolibera_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_tipovehiculolibera_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_tipovehiculolibera_id_seq TO gaj_rw;


--
-- Name: TABLE def_usuario; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_usuario TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_usuario TO gaj_rw;


--
-- Name: SEQUENCE def_usuario_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_usuario_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_usuario_id_seq TO gaj_rw;


--
-- Name: TABLE def_usuario_permiso_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_usuario_permiso_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_usuario_permiso_acta TO gaj_rw;


--
-- Name: SEQUENCE def_usuario_permiso_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_usuario_permiso_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_usuario_permiso_acta_id_seq TO gaj_rw;


--
-- Name: TABLE def_usuario_permiso_notificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_usuario_permiso_notificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_usuario_permiso_notificacion TO gaj_rw;


--
-- Name: SEQUENCE def_usuario_permiso_notificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_usuario_permiso_notificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_usuario_permiso_notificacion_id_seq TO gaj_rw;


--
-- Name: TABLE def_usuario_reparticion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_usuario_reparticion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_usuario_reparticion TO gaj_rw;


--
-- Name: SEQUENCE def_usuario_reparticion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_usuario_reparticion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_usuario_reparticion_id_seq TO gaj_rw;


--
-- Name: TABLE def_usuariofuncion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_usuariofuncion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_usuariofuncion TO gaj_rw;


--
-- Name: SEQUENCE def_usuariofuncion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_usuariofuncion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_usuariofuncion_id_seq TO gaj_rw;


--
-- Name: TABLE def_valor_reincidencia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_valor_reincidencia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_valor_reincidencia TO gaj_rw;


--
-- Name: SEQUENCE def_valor_reincidencia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_valor_reincidencia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_valor_reincidencia_id_seq TO gaj_rw;


--
-- Name: TABLE def_valuacion_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.def_valuacion_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.def_valuacion_infraccion TO gaj_rw;


--
-- Name: SEQUENCE def_valuacion_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.def_valuacion_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.def_valuacion_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE ext_consulta_sugit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.ext_consulta_sugit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.ext_consulta_sugit TO gaj_rw;
GRANT SELECT,INSERT,DELETE ON TABLE sch_gaj.ext_consulta_sugit TO tsugitw1;


--
-- Name: TABLE ext_consulta_sugit_det; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.ext_consulta_sugit_det TO gaj_r;
GRANT ALL ON TABLE sch_gaj.ext_consulta_sugit_det TO gaj_rw;
GRANT SELECT,INSERT,DELETE ON TABLE sch_gaj.ext_consulta_sugit_det TO tsugitw1;


--
-- Name: SEQUENCE ext_consulta_sugit_det_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.ext_consulta_sugit_det_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.ext_consulta_sugit_det_id_seq TO gaj_rw;


--
-- Name: SEQUENCE ext_consulta_sugit_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.ext_consulta_sugit_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.ext_consulta_sugit_id_seq TO gaj_rw;


--
-- Name: TABLE ext_pagos_sugit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.ext_pagos_sugit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.ext_pagos_sugit TO gaj_rw;
GRANT ALL ON TABLE sch_gaj.ext_pagos_sugit TO dgaj_owner;
GRANT SELECT,INSERT,DELETE ON TABLE sch_gaj.ext_pagos_sugit TO tsugitw1;


--
-- Name: SEQUENCE ext_pagos_sugit_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.ext_pagos_sugit_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.ext_pagos_sugit_id_seq TO gaj_rw;
GRANT ALL ON SEQUENCE sch_gaj.ext_pagos_sugit_id_seq TO dgaj_owner;


--
-- Name: TABLE fecha; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.fecha TO gaj_r;
GRANT ALL ON TABLE sch_gaj.fecha TO gaj_rw;


--
-- Name: TABLE for_formulario; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.for_formulario TO gaj_r;
GRANT ALL ON TABLE sch_gaj.for_formulario TO gaj_rw;


--
-- Name: SEQUENCE for_formulario_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.for_formulario_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.for_formulario_id_seq TO gaj_rw;


--
-- Name: SEQUENCE hibernate_sequence; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.hibernate_sequence TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.hibernate_sequence TO gaj_rw;


--
-- Name: TABLE juz_accion_juzgamiento; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_accion_juzgamiento TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_accion_juzgamiento TO gaj_rw;


--
-- Name: SEQUENCE juz_accion_juzgamiento_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_accion_juzgamiento_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_accion_juzgamiento_id_seq TO gaj_rw;


--
-- Name: TABLE juz_acta_juez; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_acta_juez TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_acta_juez TO gaj_rw;


--
-- Name: SEQUENCE juz_acta_juez_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_acta_juez_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_acta_juez_id_seq TO gaj_rw;


--
-- Name: TABLE juz_agravio_apelacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_agravio_apelacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_agravio_apelacion TO gaj_rw;


--
-- Name: SEQUENCE juz_agravio_apelacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_agravio_apelacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_agravio_apelacion_id_seq TO gaj_rw;


--
-- Name: TABLE juz_apelacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_apelacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_apelacion TO gaj_rw;


--
-- Name: TABLE juz_apelacion_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_apelacion_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_apelacion_acta TO gaj_rw;


--
-- Name: TABLE juz_apelacion_acta_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_apelacion_acta_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_apelacion_acta_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_acta_id_seq TO gaj_rw;


--
-- Name: TABLE juz_apelacion_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_apelacion_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_apelacion_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_id_seq TO gaj_rw;


--
-- Name: TABLE juz_apelacion_imagen; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_apelacion_imagen TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_apelacion_imagen TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_imagen_apelacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_imagen_apelacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_imagen_apelacion_id_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_imagen_id_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_imagen_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_imagen_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_imagen_imagen_id_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_numero_2020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_numero_2020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_numero_2020_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_numero_2021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_numero_2021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_numero_2021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_apelacion_numero_2022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_numero_2022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_apelacion_numero_2022_seq TO gaj_rw;


--
-- Name: TABLE juz_audiencia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_audiencia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_audiencia TO gaj_rw;


--
-- Name: SEQUENCE juz_audiencia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_audiencia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_audiencia_id_seq TO gaj_rw;


--
-- Name: TABLE juz_borrador_juzgamiento; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_borrador_juzgamiento TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_borrador_juzgamiento TO gaj_rw;


--
-- Name: SEQUENCE juz_borrador_juzgamiento_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_borrador_juzgamiento_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_borrador_juzgamiento_id_seq TO gaj_rw;


--
-- Name: TABLE juz_camara; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_camara TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_camara TO gaj_rw;


--
-- Name: SEQUENCE juz_camara_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_camara_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_camara_id_seq TO gaj_rw;


--
-- Name: TABLE juz_cambio_infractor; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_cambio_infractor TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_cambio_infractor TO gaj_rw;


--
-- Name: SEQUENCE juz_cambio_infractor_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_cambio_infractor_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_cambio_infractor_id_seq TO gaj_rw;


--
-- Name: TABLE juz_descargo_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_descargo_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_descargo_acta TO gaj_rw;


--
-- Name: SEQUENCE juz_descargo_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_descargo_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_descargo_acta_id_seq TO gaj_rw;


--
-- Name: TABLE juz_desistencia_apelacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_desistencia_apelacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_desistencia_apelacion TO gaj_rw;


--
-- Name: SEQUENCE juz_desistencia_apelacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_desistencia_apelacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_desistencia_apelacion_id_seq TO gaj_rw;


--
-- Name: TABLE juz_deuda_siat; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_deuda_siat TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_deuda_siat TO gaj_rw;


--
-- Name: SEQUENCE juz_deuda_siat_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_deuda_siat_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_deuda_siat_id_seq TO gaj_rw;


--
-- Name: TABLE juz_envio_siat; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_envio_siat TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_envio_siat TO gaj_rw;


--
-- Name: SEQUENCE juz_envio_siat_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_envio_siat_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_envio_siat_id_seq TO gaj_rw;


--
-- Name: TABLE juz_estado_apelacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_estado_apelacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_estado_apelacion TO gaj_rw;


--
-- Name: SEQUENCE juz_estado_apelacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_estado_apelacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_estado_apelacion_id_seq TO gaj_rw;


--
-- Name: TABLE juz_histestape; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_histestape TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_histestape TO gaj_rw;


--
-- Name: SEQUENCE juz_histestape_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_histestape_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_histestape_id_seq TO gaj_rw;


--
-- Name: TABLE juz_histestsenact; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_histestsenact TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_histestsenact TO gaj_rw;


--
-- Name: SEQUENCE juz_histestsenact_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_histestsenact_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_histestsenact_id_seq TO gaj_rw;


--
-- Name: TABLE juz_juez_apelacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_juez_apelacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_juez_apelacion TO gaj_rw;


--
-- Name: TABLE juz_juez_apelacion_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_juez_apelacion_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_juez_apelacion_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_juez_apelacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_juez_apelacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_juez_apelacion_id_seq TO gaj_rw;


--
-- Name: TABLE juz_novedad_siat; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_novedad_siat TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_novedad_siat TO gaj_rw;


--
-- Name: SEQUENCE juz_novedad_siat_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_novedad_siat_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_novedad_siat_id_seq TO gaj_rw;


--
-- Name: TABLE juz_pago_sugit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_pago_sugit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_pago_sugit TO gaj_rw;


--
-- Name: SEQUENCE juz_pago_sugit_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_pago_sugit_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_pago_sugit_id_seq TO gaj_rw;


--
-- Name: TABLE juz_pena_sentencia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_pena_sentencia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_pena_sentencia TO gaj_rw;


--
-- Name: TABLE juz_pena_sentencia_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_pena_sentencia_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_pena_sentencia_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_pena_sentencia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_pena_sentencia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_pena_sentencia_id_seq TO gaj_rw;


--
-- Name: TABLE juz_periodo_cumplimiento_pena; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_periodo_cumplimiento_pena TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_periodo_cumplimiento_pena TO gaj_rw;


--
-- Name: TABLE juz_periodo_cumplimiento_pena_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_periodo_cumplimiento_pena_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_periodo_cumplimiento_pena_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_periodo_cumplimiento_pena_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_periodo_cumplimiento_pena_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_periodo_cumplimiento_pena_id_seq TO gaj_rw;


--
-- Name: TABLE juz_proceso_rebeldia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_proceso_rebeldia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_proceso_rebeldia TO gaj_rw;


--
-- Name: SEQUENCE juz_proceso_rebeldia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_proceso_rebeldia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_proceso_rebeldia_id_seq TO gaj_rw;


--
-- Name: TABLE juz_recibo_siat; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_recibo_siat TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_recibo_siat TO gaj_rw;


--
-- Name: TABLE juz_recibo_siat_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_recibo_siat_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_recibo_siat_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_recibo_siat_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_recibo_siat_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_recibo_siat_id_seq TO gaj_rw;


--
-- Name: TABLE juz_recusacion_excusacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_recusacion_excusacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_recusacion_excusacion TO gaj_rw;


--
-- Name: SEQUENCE juz_recusacion_excusacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_recusacion_excusacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_recusacion_excusacion_id_seq TO gaj_rw;


--
-- Name: TABLE juz_sentencia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia TO gaj_rw;


--
-- Name: TABLE juz_sentencia_acta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_acta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_acta TO gaj_rw;


--
-- Name: TABLE juz_sentencia_acta_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_acta_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_acta_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_acta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_acta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_acta_id_seq TO gaj_rw;


--
-- Name: TABLE juz_sentencia_anulacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_anulacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_anulacion TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_anulacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_anulacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_anulacion_id_seq TO gaj_rw;


--
-- Name: TABLE juz_sentencia_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_id_seq TO gaj_rw;


--
-- Name: TABLE juz_sentencia_imagen; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_imagen TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_imagen TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_imagen_id_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_imagen_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_imagen_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_imagen_imagen_id_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_imagen_sentencia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_imagen_sentencia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_imagen_sentencia_id_seq TO gaj_rw;


--
-- Name: TABLE juz_sentencia_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_infraccion TO gaj_rw;


--
-- Name: TABLE juz_sentencia_infraccion_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_infraccion_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_infraccion_backup TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_infraccion_id_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_02021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_02021_seq TO gaj_rw;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_02021_seq TO gaj_r;


--
-- Name: SEQUENCE juz_sentencia_numero_02022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_02022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_02022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_1002021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_1002021_seq TO gaj_rw;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_1002021_seq TO gaj_r;


--
-- Name: SEQUENCE juz_sentencia_numero_102021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_102021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_102021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_102022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_102022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_102022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_112021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_112021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_112021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_112022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_112022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_112022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_12021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_12021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_12021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_12022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_12022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_12022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_122021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_122021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_122021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_122022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_122022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_122022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_132021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_132021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_132021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_132022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_132022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_132022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_142021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_142021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_142021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_142022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_142022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_142022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_152021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_152021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_152021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_152022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_152022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_152022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_162021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_162021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_162021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_162022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_162022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_162022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_182021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_182021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_182021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_182022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_182022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_182022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_192021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_192021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_192021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_192022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_192022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_192022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_212021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_212021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_212021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_212022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_212022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_212022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_22021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_22021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_22021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_22022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_22022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_22022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_222021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_222021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_222021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_222022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_222022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_222022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_232021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_232021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_232021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_232022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_232022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_232022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_242021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_242021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_242021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_242022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_242022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_242022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_252021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_252021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_252021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_252022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_252022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_252022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_262021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_262021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_262021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_262022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_262022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_262022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_272021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_272021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_272021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_272022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_272022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_272022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_282021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_282021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_282021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_282022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_282022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_282022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_292021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_292021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_292021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_292022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_292022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_292022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_302021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_302021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_302021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_302022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_302022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_302022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_312021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_312021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_312021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_312022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_312022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_312022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_32021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_32021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_32021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_32022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_32022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_32022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_322021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_322021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_322021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_322022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_322022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_322022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_342021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_342021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_342021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_342022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_342022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_342022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_352021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_352021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_352021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_352022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_352022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_352022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_362021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_362021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_362021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_362022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_362022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_362022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_372021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_372021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_372021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_372022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_372022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_372022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_382021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_382021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_382021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_382022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_382022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_382022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_392021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_392021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_392021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_392022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_392022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_392022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_402021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_402021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_402021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_402022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_402022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_402022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_412021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_412021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_412021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_412022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_412022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_412022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_42021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_42021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_42021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_42022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_42022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_42022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_422021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_422021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_422021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_422022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_422022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_422022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_432021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_432021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_432021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_432022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_432022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_432022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_442021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_442021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_442021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_442022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_442022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_442022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_452021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_452021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_452021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_452022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_452022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_452022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_462021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_462021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_462021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_462022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_462022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_462022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_472021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_472021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_472021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_472022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_472022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_472022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_482021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_482021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_482021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_482022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_482022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_482022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_52021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_52021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_52021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_52022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_52022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_52022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_602021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_602021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_602021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_602022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_602022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_602022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_612021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_612021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_612021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_62021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_62021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_62021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_62022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_62022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_62022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_622021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_622021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_622021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_622022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_622022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_622022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_632021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_632021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_632021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_652021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_652021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_652021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_662021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_662021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_662021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_72021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_72021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_72021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_72022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_72022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_72022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_82021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_82021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_82021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_82022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_82022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_82022_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_92021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_92021_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_92021_seq TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_numero_92022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_92022_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_numero_92022_seq TO gaj_rw;


--
-- Name: TABLE juz_sentencia_proceso_rebeldia; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_proceso_rebeldia TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_proceso_rebeldia TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_proceso_rebeldia_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_proceso_rebeldia_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_proceso_rebeldia_id_seq TO gaj_rw;


--
-- Name: TABLE juz_sentencia_tramite; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_sentencia_tramite TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_sentencia_tramite TO gaj_rw;


--
-- Name: SEQUENCE juz_sentencia_tramite_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_tramite_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_sentencia_tramite_id_seq TO gaj_rw;


--
-- Name: TABLE juz_tasa_fotografica; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_tasa_fotografica TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_tasa_fotografica TO gaj_rw;


--
-- Name: SEQUENCE juz_tasa_fotografica_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_tasa_fotografica_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_tasa_fotografica_id_seq TO gaj_rw;


--
-- Name: TABLE juz_tipo_juzgamiento; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_tipo_juzgamiento TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_tipo_juzgamiento TO gaj_rw;


--
-- Name: SEQUENCE juz_tipo_juzgamiento_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_tipo_juzgamiento_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_tipo_juzgamiento_id_seq TO gaj_rw;


--
-- Name: TABLE juz_tribunal_automatico; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_tribunal_automatico TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_tribunal_automatico TO gaj_rw;


--
-- Name: SEQUENCE juz_tribunal_automatico_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_tribunal_automatico_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_tribunal_automatico_id_seq TO gaj_rw;


--
-- Name: TABLE juz_unidad_fija; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.juz_unidad_fija TO gaj_r;
GRANT ALL ON TABLE sch_gaj.juz_unidad_fija TO gaj_rw;


--
-- Name: SEQUENCE juz_unidad_fija_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.juz_unidad_fija_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.juz_unidad_fija_id_seq TO gaj_rw;


--
-- Name: TABLE listado_acarreo_view; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.listado_acarreo_view TO gaj_r;
GRANT ALL ON TABLE sch_gaj.listado_acarreo_view TO gaj_rw;


--
-- Name: TABLE listado_tipo_acarreo_view; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.listado_tipo_acarreo_view TO gaj_r;
GRANT ALL ON TABLE sch_gaj.listado_tipo_acarreo_view TO gaj_rw;


--
-- Name: TABLE pad_tipovehiculo; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_tipovehiculo TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_tipovehiculo TO gaj_rw;


--
-- Name: TABLE listado_vehiculo_view; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.listado_vehiculo_view TO gaj_r;
GRANT ALL ON TABLE sch_gaj.listado_vehiculo_view TO gaj_rw;


--
-- Name: TABLE mig_rel_siat; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.mig_rel_siat TO gaj_r;
GRANT ALL ON TABLE sch_gaj.mig_rel_siat TO gaj_rw;


--
-- Name: TABLE not_areanotificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_areanotificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_areanotificacion TO gaj_rw;


--
-- Name: SEQUENCE not_areanotificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_areanotificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_areanotificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_auxnotificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_auxnotificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_auxnotificacion TO gaj_rw;


--
-- Name: SEQUENCE not_auxnotificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_auxnotificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_auxnotificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_auxnotificaciondetalle; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_auxnotificaciondetalle TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_auxnotificaciondetalle TO gaj_rw;


--
-- Name: SEQUENCE not_auxnotificaciondetalle_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_auxnotificaciondetalle_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_auxnotificaciondetalle_id_seq TO gaj_rw;


--
-- Name: TABLE not_estadonotificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_estadonotificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_estadonotificacion TO gaj_rw;


--
-- Name: SEQUENCE not_estadonotificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_estadonotificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_estadonotificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_grupo_notificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_grupo_notificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_grupo_notificacion TO gaj_rw;


--
-- Name: SEQUENCE not_grupo_notificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_grupo_notificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_grupo_notificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_grupo_notificacion_localidad; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_grupo_notificacion_localidad TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_grupo_notificacion_localidad TO gaj_rw;


--
-- Name: SEQUENCE not_grupo_notificacion_localidad_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_grupo_notificacion_localidad_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_grupo_notificacion_localidad_id_seq TO gaj_rw;


--
-- Name: TABLE not_hisestnot; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_hisestnot TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_hisestnot TO gaj_rw;


--
-- Name: TABLE not_hisestnot_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_hisestnot_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_hisestnot_backup TO gaj_rw;


--
-- Name: SEQUENCE not_hisestnot_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_hisestnot_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_hisestnot_id_seq TO gaj_rw;


--
-- Name: TABLE not_lotenotificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_lotenotificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_lotenotificacion TO gaj_rw;


--
-- Name: SEQUENCE not_lotenotificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_lotenotificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_lotenotificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_notificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_notificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_notificacion TO gaj_rw;


--
-- Name: TABLE not_notificacion_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_notificacion_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_notificacion_backup TO gaj_rw;


--
-- Name: SEQUENCE not_notificacion_codigo_2020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_codigo_2020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_codigo_2020_seq TO gaj_rw;


--
-- Name: SEQUENCE not_notificacion_codigo_2021_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_codigo_2021_seq TO gaj_rw;
GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_codigo_2021_seq TO gaj_r;


--
-- Name: SEQUENCE not_notificacion_codigo_2022_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_codigo_2022_seq TO gaj_rw;
GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_codigo_2022_seq TO gaj_r;


--
-- Name: SEQUENCE not_notificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_notificacion_imagen; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_notificacion_imagen TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_notificacion_imagen TO gaj_rw;


--
-- Name: TABLE not_notificacion_imagen_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_notificacion_imagen_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_notificacion_imagen_backup TO gaj_rw;


--
-- Name: SEQUENCE not_notificacion_imagen_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_imagen_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_notificacion_imagen_id_seq TO gaj_rw;


--
-- Name: TABLE not_notificaciondetalle; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_notificaciondetalle TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_notificaciondetalle TO gaj_rw;


--
-- Name: TABLE not_notificaciondetalle_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_notificaciondetalle_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_notificaciondetalle_backup TO gaj_rw;


--
-- Name: SEQUENCE not_notificaciondetalle_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_notificaciondetalle_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_notificaciondetalle_id_seq TO gaj_rw;


--
-- Name: TABLE not_notificador; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_notificador TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_notificador TO gaj_rw;


--
-- Name: SEQUENCE not_notificador_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_notificador_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_notificador_id_seq TO gaj_rw;


--
-- Name: TABLE not_procesonotificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_procesonotificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_procesonotificacion TO gaj_rw;


--
-- Name: SEQUENCE not_procesonotificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_procesonotificacion_infraccion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_procesonotificacion_infraccion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_procesonotificacion_infraccion TO gaj_rw;


--
-- Name: SEQUENCE not_procesonotificacion_infraccion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_infraccion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_infraccion_id_seq TO gaj_rw;


--
-- Name: TABLE not_procesonotificacion_objeto; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_procesonotificacion_objeto TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_procesonotificacion_objeto TO gaj_rw;


--
-- Name: SEQUENCE not_procesonotificacion_objeto_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_objeto_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_objeto_id_seq TO gaj_rw;


--
-- Name: TABLE not_procesonotificacion_reparticion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_procesonotificacion_reparticion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_procesonotificacion_reparticion TO gaj_rw;


--
-- Name: SEQUENCE not_procesonotificacion_reparticion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_reparticion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_reparticion_id_seq TO gaj_rw;


--
-- Name: TABLE not_procesonotificacion_zona; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_procesonotificacion_zona TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_procesonotificacion_zona TO gaj_rw;


--
-- Name: SEQUENCE not_procesonotificacion_zona_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_zona_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_procesonotificacion_zona_id_seq TO gaj_rw;


--
-- Name: TABLE not_registro_servicios_publicos; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_registro_servicios_publicos TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_registro_servicios_publicos TO gaj_rw;


--
-- Name: SEQUENCE not_registro_servicios_publicos_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_registro_servicios_publicos_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_registro_servicios_publicos_id_seq TO gaj_rw;


--
-- Name: TABLE not_tipobjnot; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_tipobjnot TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_tipobjnot TO gaj_rw;


--
-- Name: SEQUENCE not_tipobjnot_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_tipobjnot_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_tipobjnot_id_seq TO gaj_rw;


--
-- Name: TABLE not_tiponotificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_tiponotificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_tiponotificacion TO gaj_rw;


--
-- Name: SEQUENCE not_tiponotificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_tiponotificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_tiponotificacion_id_seq TO gaj_rw;


--
-- Name: TABLE not_zonanotificacion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.not_zonanotificacion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.not_zonanotificacion TO gaj_rw;


--
-- Name: SEQUENCE not_zonanotificacion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.not_zonanotificacion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.not_zonanotificacion_id_seq TO gaj_rw;


--
-- Name: TABLE pad_agente; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_agente TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_agente TO gaj_rw;


--
-- Name: TABLE novedad_libro_view; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.novedad_libro_view TO gaj_r;
GRANT ALL ON TABLE sch_gaj.novedad_libro_view TO gaj_rw;


--
-- Name: SEQUENCE pad_agente_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_agente_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_agente_id_seq TO gaj_rw;


--
-- Name: TABLE pad_agente_reparticion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_agente_reparticion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_agente_reparticion TO gaj_rw;


--
-- Name: SEQUENCE pad_agente_reparticion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_agente_reparticion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_agente_reparticion_id_seq TO gaj_rw;


--
-- Name: TABLE pad_autorizado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_autorizado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_autorizado TO gaj_rw;


--
-- Name: SEQUENCE pad_autorizado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_autorizado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_autorizado_id_seq TO gaj_rw;


--
-- Name: TABLE pad_juez; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_juez TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_juez TO gaj_rw;


--
-- Name: SEQUENCE pad_juez_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_juez_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_juez_id_seq TO gaj_rw;


--
-- Name: TABLE pad_juzgado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_juzgado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_juzgado TO gaj_rw;


--
-- Name: SEQUENCE pad_juzgado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_juzgado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_juzgado_id_seq TO gaj_rw;


--
-- Name: TABLE pad_persona_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_persona_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_persona_backup TO gaj_rw;


--
-- Name: SEQUENCE pad_persona_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_persona_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_persona_id_seq TO gaj_rw;


--
-- Name: SEQUENCE pad_tipovehiculo_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_tipovehiculo_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_tipovehiculo_id_seq TO gaj_rw;


--
-- Name: TABLE pad_titular; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_titular TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_titular TO gaj_rw;


--
-- Name: SEQUENCE pad_titular_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_titular_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_titular_id_seq TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_audit TO gaj_rw;


--
-- Name: SEQUENCE pad_vehiculo_audit_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_audit_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_audit_id_seq TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_autorizado; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_autorizado TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_autorizado TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_autorizado_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_autorizado_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_autorizado_audit TO gaj_rw;


--
-- Name: SEQUENCE pad_vehiculo_autorizado_audit_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_autorizado_audit_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_autorizado_audit_id_seq TO gaj_rw;


--
-- Name: SEQUENCE pad_vehiculo_autorizado_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_autorizado_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_autorizado_id_seq TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_backup TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_hist; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_hist TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_hist TO gaj_rw;


--
-- Name: SEQUENCE pad_vehiculo_hist_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_hist_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_hist_id_seq TO gaj_rw;


--
-- Name: SEQUENCE pad_vehiculo_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_id_seq TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_titular; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_titular TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_titular TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_titular_audit; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_titular_audit TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_titular_audit TO gaj_rw;


--
-- Name: SEQUENCE pad_vehiculo_titular_audit_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_titular_audit_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_titular_audit_id_seq TO gaj_rw;


--
-- Name: TABLE pad_vehiculo_titular_backup; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pad_vehiculo_titular_backup TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pad_vehiculo_titular_backup TO gaj_rw;


--
-- Name: SEQUENCE pad_vehiculo_titular_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_titular_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pad_vehiculo_titular_id_seq TO gaj_rw;


--
-- Name: TABLE pro_corrida; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_corrida TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_corrida TO gaj_rw;


--
-- Name: SEQUENCE pro_corrida_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_corrida_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_corrida_id_seq TO gaj_rw;


--
-- Name: TABLE pro_estadocorrida; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_estadocorrida TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_estadocorrida TO gaj_rw;


--
-- Name: SEQUENCE pro_estadocorrida_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_estadocorrida_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_estadocorrida_id_seq TO gaj_rw;


--
-- Name: TABLE pro_filecorrida; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_filecorrida TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_filecorrida TO gaj_rw;


--
-- Name: SEQUENCE pro_filecorrida_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_filecorrida_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_filecorrida_id_seq TO gaj_rw;


--
-- Name: TABLE pro_logcorrida; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_logcorrida TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_logcorrida TO gaj_rw;


--
-- Name: SEQUENCE pro_logcorrida_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_logcorrida_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_logcorrida_id_seq TO gaj_rw;


--
-- Name: TABLE pro_pasocorrida; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_pasocorrida TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_pasocorrida TO gaj_rw;


--
-- Name: SEQUENCE pro_pasocorrida_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_pasocorrida_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_pasocorrida_id_seq TO gaj_rw;


--
-- Name: TABLE pro_proceso; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_proceso TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_proceso TO gaj_rw;


--
-- Name: SEQUENCE pro_proceso_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_proceso_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_proceso_id_seq TO gaj_rw;


--
-- Name: TABLE pro_procesoatrval; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_procesoatrval TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_procesoatrval TO gaj_rw;


--
-- Name: SEQUENCE pro_procesoatrval_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_procesoatrval_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_procesoatrval_id_seq TO gaj_rw;


--
-- Name: TABLE pro_procesoparval; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_procesoparval TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_procesoparval TO gaj_rw;


--
-- Name: SEQUENCE pro_procesoparval_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_procesoparval_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_procesoparval_id_seq TO gaj_rw;


--
-- Name: TABLE pro_procesotablas; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_procesotablas TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_procesotablas TO gaj_rw;


--
-- Name: TABLE pro_tipoejecucion; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_tipoejecucion TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_tipoejecucion TO gaj_rw;


--
-- Name: SEQUENCE pro_tipoejecucion_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_tipoejecucion_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_tipoejecucion_id_seq TO gaj_rw;


--
-- Name: TABLE pro_tipoprogejec; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_tipoprogejec TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_tipoprogejec TO gaj_rw;


--
-- Name: SEQUENCE pro_tipoprogejec_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_tipoprogejec_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_tipoprogejec_id_seq TO gaj_rw;


--
-- Name: TABLE pro_unifcta; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.pro_unifcta TO gaj_r;
GRANT ALL ON TABLE sch_gaj.pro_unifcta TO gaj_rw;


--
-- Name: SEQUENCE pro_unifcta_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.pro_unifcta_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.pro_unifcta_id_seq TO gaj_rw;


--
-- Name: TABLE tmp_ctrl; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON TABLE sch_gaj.tmp_ctrl TO dgaj_owner;
GRANT SELECT ON TABLE sch_gaj.tmp_ctrl TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tmp_ctrl TO gaj_rw;


--
-- Name: TABLE tmp_datos_domicilio; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tmp_datos_domicilio TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tmp_datos_domicilio TO gaj_rw;


--
-- Name: TABLE tmp_pate_prov; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tmp_pate_prov TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tmp_pate_prov TO gaj_rw;


--
-- Name: TABLE tmp_unl_actas; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

REVOKE ALL ON TABLE sch_gaj.tmp_unl_actas FROM gaj_owner;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE sch_gaj.tmp_unl_actas TO gaj_owner;
GRANT SELECT ON TABLE sch_gaj.tmp_unl_actas TO gaj_owner WITH GRANT OPTION;
GRANT SELECT ON TABLE sch_gaj.tmp_unl_actas TO gaj_r WITH GRANT OPTION;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLE sch_gaj.tmp_unl_actas TO gaj_rw;
GRANT SELECT ON TABLE sch_gaj.tmp_unl_actas TO gaj_rw WITH GRANT OPTION;


--
-- Name: TABLE tmp_unl_agentes; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tmp_unl_agentes TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tmp_unl_agentes TO gaj_rw;


--
-- Name: TABLE tmp_unl_agentes2; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tmp_unl_agentes2 TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tmp_unl_agentes2 TO gaj_rw;


--
-- Name: TABLE tra_estado_notificacion_tramite; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tra_estado_notificacion_tramite TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tra_estado_notificacion_tramite TO gaj_rw;


--
-- Name: SEQUENCE tra_estado_notificacion_tramite_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_estado_notificacion_tramite_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_estado_notificacion_tramite_id_seq TO gaj_rw;


--
-- Name: SEQUENCE tra_libremulta_numero_112020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_112020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_112020_seq TO gaj_rw;


--
-- Name: SEQUENCE tra_libremulta_numero_222020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_222020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_222020_seq TO gaj_rw;


--
-- Name: SEQUENCE tra_libremulta_numero_82020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_82020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_82020_seq TO gaj_rw;


--
-- Name: SEQUENCE tra_libremulta_numero_92020_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_92020_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_numero_92020_seq TO gaj_rw;


--
-- Name: TABLE tra_libremulta_tramite; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tra_libremulta_tramite TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tra_libremulta_tramite TO gaj_rw;


--
-- Name: SEQUENCE tra_libremulta_tramite_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_tramite_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_libremulta_tramite_id_seq TO gaj_rw;


--
-- Name: TABLE tra_notificacion_tramite; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tra_notificacion_tramite TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tra_notificacion_tramite TO gaj_rw;


--
-- Name: SEQUENCE tra_notificacion_tramite_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_notificacion_tramite_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_notificacion_tramite_id_seq TO gaj_rw;


--
-- Name: TABLE tra_usuario_tramite; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.tra_usuario_tramite TO gaj_r;
GRANT ALL ON TABLE sch_gaj.tra_usuario_tramite TO gaj_rw;


--
-- Name: SEQUENCE tra_usuario_tramite_id_seq; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT ALL ON SEQUENCE sch_gaj.tra_usuario_tramite_id_seq TO gaj_r;
GRANT ALL ON SEQUENCE sch_gaj.tra_usuario_tramite_id_seq TO gaj_rw;


--
-- Name: TABLE w_borrar; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.w_borrar TO gaj_r;
GRANT ALL ON TABLE sch_gaj.w_borrar TO gaj_rw;


--
-- Name: TABLE zzz_juz_recibo_siat; Type: ACL; Schema: sch_gaj; Owner: gaj_owner
--

GRANT SELECT ON TABLE sch_gaj.zzz_juz_recibo_siat TO gaj_r;
GRANT ALL ON TABLE sch_gaj.zzz_juz_recibo_siat TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: sch_gaj; Owner: gaj_owner
--

ALTER DEFAULT PRIVILEGES FOR ROLE gaj_owner IN SCHEMA sch_gaj GRANT SELECT ON SEQUENCES  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE gaj_owner IN SCHEMA sch_gaj GRANT ALL ON SEQUENCES  TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: sch_gaj; Owner: cbasel0
--

ALTER DEFAULT PRIVILEGES FOR ROLE cbasel0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE cbasel0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE cbasel0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: sch_gaj; Owner: chernan0
--

ALTER DEFAULT PRIVILEGES FOR ROLE chernan0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE chernan0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE chernan0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: sch_gaj; Owner: pgrigio0
--

ALTER DEFAULT PRIVILEGES FOR ROLE pgrigio0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE pgrigio0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE pgrigio0 IN SCHEMA sch_gaj GRANT ALL ON FUNCTIONS  TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: sch_gaj; Owner: gaj_owner
--

ALTER DEFAULT PRIVILEGES FOR ROLE gaj_owner IN SCHEMA sch_gaj GRANT SELECT ON TABLES  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE gaj_owner IN SCHEMA sch_gaj GRANT ALL ON TABLES  TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: sch_gaj; Owner: cbasel0
--

ALTER DEFAULT PRIVILEGES FOR ROLE cbasel0 IN SCHEMA sch_gaj GRANT ALL ON TABLES  TO gaj_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE cbasel0 IN SCHEMA sch_gaj GRANT SELECT ON TABLES  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE cbasel0 IN SCHEMA sch_gaj GRANT ALL ON TABLES  TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: sch_gaj; Owner: chernan0
--

ALTER DEFAULT PRIVILEGES FOR ROLE chernan0 IN SCHEMA sch_gaj GRANT ALL ON TABLES  TO gaj_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE chernan0 IN SCHEMA sch_gaj GRANT SELECT ON TABLES  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE chernan0 IN SCHEMA sch_gaj GRANT ALL ON TABLES  TO gaj_rw;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: sch_gaj; Owner: pgrigio0
--

ALTER DEFAULT PRIVILEGES FOR ROLE pgrigio0 IN SCHEMA sch_gaj GRANT ALL ON TABLES  TO gaj_owner;
ALTER DEFAULT PRIVILEGES FOR ROLE pgrigio0 IN SCHEMA sch_gaj GRANT SELECT ON TABLES  TO gaj_r;
ALTER DEFAULT PRIVILEGES FOR ROLE pgrigio0 IN SCHEMA sch_gaj GRANT ALL ON TABLES  TO gaj_rw;


--
-- PostgreSQL database dump complete
--

