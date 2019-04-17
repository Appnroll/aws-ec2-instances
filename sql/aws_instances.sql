--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1
-- Dumped by pg_dump version 11.1

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


CREATE TABLE public.aws_instances (
    id serial PRIMARY KEY,
    instance_id VARCHAR (32) UNIQUE,
    state VARCHAR (32),
    name VARCHAR (32),
    type VARCHAR (32),
    public_ip VARCHAR (32),
    region VARCHAR (32),
    profile VARCHAR (32),
    launch_time VARCHAR (32),
    publicdnsname VARCHAR (64)
);


COPY public.aws_instances (state, name, type, instance_id, public_ip, region, profile, launch_time, publicdnsname) FROM stdin;
\.

--
-- PostgreSQL database dump complete
--

