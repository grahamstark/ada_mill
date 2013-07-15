--
-- created on 11-06-2013 by Mill
--
drop database if exists simple_pg;
create database simple_pg with encoding 'UTF-8';

\c simple_pg;


CREATE TABLE standard_user( 
       user_id INTEGER not null,
       username VARCHAR(16) not null default '',
       password VARCHAR(32) default '',
       type1 INTEGER,
       type2 INTEGER,
       date_created TIMESTAMP default TIMESTAMP '1901-01-01 00:00:00.000000',
       PRIMARY KEY( user_id )
);

CREATE TABLE standard_group( 
       name VARCHAR(30) not null default 'SATTSIM',
       description VARCHAR(120),
       PRIMARY KEY( name )
);

CREATE TABLE group_members( 
       group_name VARCHAR(30) not null default '',
       user_id INTEGER not null,
       PRIMARY KEY( group_name, user_id ),
       CONSTRAINT group_members_FK_0 FOREIGN KEY( group_name) references standard_group( name ) on delete CASCADE on update cascade,
       CONSTRAINT group_members_FK_1 FOREIGN KEY( user_id) references standard_user( user_id ) on delete CASCADE on update cascade
);

