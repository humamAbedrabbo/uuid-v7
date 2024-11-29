# UUID Version 7 Generator

A SQL function to generate version 7 UUIDs from an origin unique identifier.

## Overview

This repository contains a SQL function `uuid7` that generates a version 7 UUID from an origin unique identifier. The function combines a timestamp and a random number to create a unique identifier.

## Features

* Generates version 7 UUIDs from an origin unique identifier
* Uses a timestamp and a random number to ensure uniqueness
* Compatible with SQL Server

## Installation

To use the `uuid7` function, simply create the function in your SQL Server database using the provided SQL script `uuid-v7.sql`.

## Usage

To generate a version 7 UUID, call the `uuid7` function and pass the origin unique identifier as an argument:
```sql
DECLARE @origin uniqueidentifier = NewID();
DECLARE @new_uuid uniqueidentifier = dbo.uuid7(@origin);
SELECT @new_uuid;