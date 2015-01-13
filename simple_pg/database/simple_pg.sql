--
-- created on 10-11-2014 by Mill
--
drop database if exists simple_pg;
create database simple_pg with encoding 'UTF-8';

\c simple_pg;


CREATE TABLE standard_user( 
       user_id INTEGER not null,
       username TEXT not null default '',
       password TEXT default '',
       type1 INTEGER,
       type2 INTEGER,
       a_bigint BIGINT,
       a_real DOUBLE PRECISION,
       a_decimal DECIMAL(12, 2),
       a_double DOUBLE PRECISION,
       a_boolean INTEGER,
       a_varchar TEXT,
       a_date TIMESTAMP default TIMESTAMP '1901-01-01 00:00:00.000000',
       PRIMARY KEY( user_id )
);

CREATE TABLE standard_group( 
       name TEXT not null default 'SATTSIM',
       description TEXT,
       PRIMARY KEY( name )
);

CREATE TABLE group_members( 
       group_name TEXT not null default '',
       user_id INTEGER not null,
       PRIMARY KEY( group_name, user_id ),
       CONSTRAINT group_members_FK_0 FOREIGN KEY( group_name) references standard_group( name ) on delete CASCADE on update cascade,
       CONSTRAINT group_members_FK_1 FOREIGN KEY( user_id) references standard_user( user_id ) on delete CASCADE on update cascade
);

