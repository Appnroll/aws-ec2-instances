--
-- PostgreSQL database dump
--

-- Dumped from database version 11.1
-- Dumped by pg_dump version 11.1
-- run:
-- psql aws_instances -f sql/aws_lightsail.sql

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


CREATE TABLE public.aws_lightsail (
    id serial PRIMARY KEY,
    arn VARCHAR (128) UNIQUE,
    state VARCHAR (32),
    name VARCHAR (32),
    username VARCHAR (32),
    ssh_key_name VARCHAR (32),
    created_at VARCHAR (32),
    profile VARCHAR (32),
    region VARCHAR (32),
    public_ip_address VARCHAR (64)
);


COPY public.aws_lightsail (state, name, arn, username, ssh_key_name, region, profile, created_at, public_ip_address) FROM stdin;
\.

--
-- PostgreSQL database dump complete
--

