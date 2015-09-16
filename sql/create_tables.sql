-- DROP DATABASE IF EXISTS trellocation;
-- CREATE DATABASE trellocation;

DROP TABLE IF EXISTS cards;
CREATE TABLE cards(
id serial primary key,
card_number int,
title text,
tag text,
points float,
url text,
board_name text,
team text,
bucket text
);
