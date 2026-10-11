# flight-sql

[![Language](https://img.shields.io/badge/Language-SQL-336791)](db.sql)
[![Database](https://img.shields.io/badge/Database-Oracle-F80000)](db.sql)
[![Status](https://img.shields.io/badge/Status-Academic%20Project-blue)]()

A set of seven Oracle SQL queries over an airline booking database, each one analyzed and tuned through execution plans.

## Table of Contents

- [What This Project Does](#what-this-project-does)
- [Why This Project Is Useful](#why-this-project-is-useful)
- [Getting Started](#getting-started)
- [Usage Examples](#usage-examples)
- [Project Structure](#project-structure)
- [Where To Get Help](#where-to-get-help)
- [Maintainers and Contributions](#maintainers-and-contributions)

## What This Project Does

`flight-sql` contains the SQL used to:

- Copy the `TAB_AIR_*` tables (airlines, airplanes, airports, flights, schedules, passengers, bookings) into your own Oracle schema.
- Run seven queries of increasing complexity (joins, filters, `IN` lists, aggregation with `HAVING`, `LEFT JOIN`, `NOT EXISTS`, case-insensitive search).
- Capture the execution plan before and after each optimization with `EXPLAIN PLAN` and `DBMS_XPLAN`.
- Test an optimization strategy per query, mostly composite and function-based indexes.

| Q | Query | Expected rows | Indexes tested |
|---|-------|---------------|----------------|
| 1 | Bookings of passenger 17638 on 2023 flights, with flight, airline and airports | 5 | `BOOKINGS(passenger_id, flight_id)`, `FLIGHTS(departure, flight_id, flightno)` |
| 2 | Passengers booked on airline 47 flights, Jan–Mar 2023 | 248 | `SCHEDULES(airline_id, flightno)`, `FLIGHTS(departure, flightno, flight_id)`, `BOOKINGS(flight_id, passenger_id)` |
| 3 | Five given passengers with bookings and flights | 37 | `PASSENGERS(passenger_id)`, `FLIGHTS(flight_id, flightno, departure)` |
| 4 | Passengers with 10+ bookings and total paid ≥ 1,500 | 99 | `PASSENGERS(passenger_id, firstname, lastname)`, `BOOKINGS(passenger_id, price, booking_id)` |
| 5 | March 2023 flights with booking count, total and average (including flights without bookings) | 27 | `FLIGHTS(departure, flightno, flight_id, airplane_id)`, `BOOKINGS(flight_id, booking_id, price)` |
| 6 | Airports never used as origin or destination | 7,382 | `SCHEDULES(from_airport_id)`, `SCHEDULES(to_airport_id)` |
| 7 | Passengers with last name SMITH, any letter case | not specified | `PASSENGERS(UPPER(lastname), passenger_id, firstname)` |

## Why This Project Is Useful

- Demonstrates how to read an Oracle execution plan: cost, cardinality, access methods, join methods, sorting and grouping.
- Shows the effect (or lack of effect) of composite, covering and function-based indexes.
- Provides a lightweight template for documenting query tuning, including attempts that did not help.

## Getting Started

### Prerequisites

- Access to an Oracle database with a client such as SQL*Plus, SQL Developer or SQLcl.
- Access to a schema to copy the tables. Otherwise, load the `.tsv` files from the data package with `create_air_tables.sql`.

### Run

1. Connect to Oracle with your own user.
2. Run `db.sql` (or each question block, one at a time).

> **Warning:** the first block of `db.sql` drops **every table in the connected schema** (`DROP TABLE ... CASCADE CONSTRAINTS` for all rows of `USER_TABLES`). Run it only in a schema dedicated to this assignment.

After the copy, check the row counts:

| Table | Rows |
|-------|------|
| `TAB_AIR_AIRLINES` | 113 |
| `TAB_AIR_AIRPLANE_TYPES` | 342 |
| `TAB_AIR_AIRPLANES` | 5,583 |
| `TAB_AIR_AIRPORTS` | 9,854 |
| `TAB_AIR_AIRPORTS_GEO` | 9,854 |
| `TAB_AIR_FLIGHTS_SCHEDULES` | 1,424 |
| `TAB_AIR_FLIGHTS` | 1,498 |
| `TAB_AIR_PASSENGERS` | 36,095 |
| `TAB_AIR_PASSENGERS_DETAILS` | 36,095 |
| `TAB_AIR_BOOKINGS` | 122,244 |

Loading from the `.tsv` files instead? Note that prices use a decimal comma, dates use `DD/MM/YY`, and in `TAB_AIR_BOOKINGS.tsv` the columns are ordered `BOOKING_ID, FLIGHT_ID, PASSENGER_ID`, while `create_air_tables.sql` declares `PASSENGER_ID` before `FLIGHT_ID`. Map the columns explicitly when loading.

## Usage Examples

Get the plan of a query (always clear `PLAN_TABLE` first):

```sql
DELETE FROM PLAN_TABLE;

EXPLAIN PLAN FOR
SELECT p.passenger_id,
       p.firstname || ' ' || p.lastname AS nome_completo,
       pd.city, pd.zip, pd.country
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_PASSENGERS_DETAILS pd ON p.passenger_id = pd.passenger_id
WHERE UPPER(p.lastname) = 'SMITH'
ORDER BY nome_completo;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

Create a structure and refresh statistics, then get the plan again:

```sql
CREATE INDEX idx_pass_upper_lastname
ON TAB_AIR_PASSENGERS (UPPER(lastname), passenger_id, firstname);

BEGIN
  DBMS_STATS.GATHER_TABLE_STATS(ownname => USER, tabname => 'TAB_AIR_PASSENGERS', cascade => TRUE);
END;
/
```

Optional: compare estimated and actual rows (`E-Rows` vs `A-Rows`) with real execution statistics:

```sql
SELECT /*+ GATHER_PLAN_STATISTICS */ ... FROM ...;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
```

Per question, `db.sql` is organized in six blocks: original SQL, original plan, tested structures and notes, index creation, SQL after optimization, and optimized plan.

The cost reported by `EXPLAIN PLAN` is a relative measure used by the optimizer, not a time in milliseconds. A lower cost does not mean a proportionally faster query.

## Project Structure

```text
.
├── README.md
└── db.sql        # Table copy, row counts, and the 7 questions (queries, plans, indexes)
```

## Where To Get Help

- Inspect [db.sql](db.sql); each question starts with a `-- QUESTAO N` header and follows the same six blocks.
- The assignment statement lists the expected row counts and the required report structure.

## Maintainers and Contributions

Maintainer:

- [@kydoa](https://github.com/kydoa)
