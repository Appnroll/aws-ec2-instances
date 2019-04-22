--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1
-- Dumped by pg_dump version 11.1
-- run:
-- psql aws_instances -f sql/aws_rds_instances.sql

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;


CREATE TABLE public.aws_rds (
    id serial PRIMARY KEY,
    dbi_resource_id VARCHAR (32) UNIQUE,
    instance_class VARCHAR (32),
    identifier VARCHAR (32),
    region VARCHAR (32),
    profile VARCHAR (32)
);


COPY public.aws_rds (dbi_resource_id, instance_class, identifier, region, profile) FROM stdin;
\.

--
-- PostgreSQL database dump complete
--

