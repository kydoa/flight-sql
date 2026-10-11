BEGIN
   FOR i IN (SELECT table_name FROM user_tables)
   LOOP
      EXECUTE IMMEDIATE 'DROP TABLE "' || i.table_name || '" CASCADE CONSTRAINTS';
   END LOOP;
END;
/   

CREATE TABLE TAB_AIR_AIRLINES AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_AIRLINES;
CREATE TABLE TAB_AIR_AIRPLANE_TYPES AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_AIRPLANE_TYPES;
CREATE TABLE TAB_AIR_AIRPLANES AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_AIRPLANES;
CREATE TABLE TAB_AIR_AIRPORTS AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_AIRPORTS;
CREATE TABLE TAB_AIR_AIRPORTS_GEO AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_AIRPORTS_GEO;
CREATE TABLE TAB_AIR_FLIGHTS_SCHEDULES AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_FLIGHTS_SCHEDULES;
CREATE TABLE TAB_AIR_FLIGHTS AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_FLIGHTS;
CREATE TABLE TAB_AIR_PASSENGERS AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_PASSENGERS;
CREATE TABLE TAB_AIR_PASSENGERS_DETAILS AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_PASSENGERS_DETAILS;
CREATE TABLE TAB_AIR_BOOKINGS AS
SELECT * FROM DENISEBANDEIRA.TAB_AIR_BOOKINGS;

SELECT 'AIRLINES' TABELA, COUNT(*) REGISTROS
FROM TAB_AIR_AIRLINES
UNION ALL
SELECT 'AIRPLANE_TYPES', COUNT(*) FROM TAB_AIR_AIRPLANE_TYPES
UNION ALL
SELECT 'AIRPLANES', COUNT(*) FROM TAB_AIR_AIRPLANES
UNION ALL
SELECT 'AIRPORTS', COUNT(*) FROM TAB_AIR_AIRPORTS
UNION ALL
SELECT 'AIRPORTS_GEO', COUNT(*) FROM TAB_AIR_AIRPORTS_GEO
UNION ALL
SELECT 'FLIGHTS_SCHEDULES', COUNT(*) FROM TAB_AIR_FLIGHTS_SCHEDULES
UNION ALL
SELECT 'FLIGHTS', COUNT(*) FROM TAB_AIR_FLIGHTS
UNION ALL
SELECT 'PASSENGERS', COUNT(*) FROM TAB_AIR_PASSENGERS
UNION ALL
SELECT 'PASSENGERS_DETAILS', COUNT(*) FROM TAB_AIR_PASSENGERS_DETAILS
UNION ALL
SELECT 'BOOKINGS', COUNT(*) FROM TAB_AIR_BOOKINGS;

-- ============================================================================
-- QUESTAO 1
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SQL ORIGINAL
-- ----------------------------------------------------------------------------
SELECT 
    b.booking_id,
    b.passenger_id,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_BOOKINGS b
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE b.passenger_id = 17638
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2024-01-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC;

-- ----------------------------------------------------------------------------
-- 2. PLANO DE EXECUÇÃO ORIGINAL
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    b.booking_id,
    b.passenger_id,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_BOOKINGS b
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE b.passenger_id = 17638
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2024-01-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------------------------
-- 3. ESTRUTURAS OU COMANDOS TESTADOS / NOTAS DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
-- - Identificadas as colunas corretas da TAB_AIR_FLIGHTS_SCHEDULES: FLIGHTNO (relacionamento), FROM_AIRPORT_ID e TO_AIRPORT_ID.
-- - Testado o filtro por intervalo exato do ano de 2023 para o passageiro 17638.

-- ----------------------------------------------------------------------------
-- 4. CRIAÇÃO DE ÍNDICES DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
CREATE INDEX idx_bookings_passenger_flight 
ON TAB_AIR_BOOKINGS (passenger_id, flight_id);

CREATE INDEX idx_flights_dept_flightno 
ON TAB_AIR_FLIGHTS (departure, flight_id, flightno);

-- ----------------------------------------------------------------------------
-- 5. SQL APÓS OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
SELECT 
    b.booking_id,
    b.passenger_id,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_BOOKINGS b
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE b.passenger_id = 17638
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2024-01-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC;

-- ----------------------------------------------------------------------------
-- 6. PLANO DE EXECUÇÃO OTIMIZADO
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    b.booking_id,
    b.passenger_id,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_BOOKINGS b
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE b.passenger_id = 17638
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2024-01-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================================
-- QUESTAO 2
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SQL ORIGINAL
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname,
    p.lastname,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
WHERE fs.airline_id = 47
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC, p.firstname ASC, p.lastname ASC;

-- ----------------------------------------------------------------------------
-- 2. PLANO DE EXECUÇÃO ORIGINAL
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname,
    p.lastname,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
WHERE fs.airline_id = 47
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC, p.firstname ASC, p.lastname ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------------------------
-- 3. ESTRUTURAS OU COMANDOS TESTADOS / NOTAS DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
-- - Junção da tabela TAB_AIR_PASSENGERS com TAB_AIR_BOOKINGS para vincular o passageiro à reserva.
-- - Junção de TAB_AIR_FLIGHTS com TAB_AIR_FLIGHTS_SCHEDULES via FLIGHTNO para filtrar pelo AIRLINE_ID = 47.

-- ----------------------------------------------------------------------------
-- 4. CRIAÇÃO DE ÍNDICES DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
CREATE INDEX idx_schedules_airline 
ON TAB_AIR_FLIGHTS_SCHEDULES (airline_id, flightno);

CREATE INDEX idx_flights_dept_sched 
ON TAB_AIR_FLIGHTS (departure, flightno, flight_id);

CREATE INDEX idx_bookings_flight_passenger 
ON TAB_AIR_BOOKINGS (flight_id, passenger_id);

-- ----------------------------------------------------------------------------
-- 5. SQL APÓS OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname,
    p.lastname,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
WHERE fs.airline_id = 47
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC, p.firstname ASC, p.lastname ASC;

-- ----------------------------------------------------------------------------
-- 6. PLANO DE EXECUÇÃO OTIMIZADO
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname,
    p.lastname,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
WHERE fs.airline_id = 47
  AND f.departure >= TO_DATE('2023-01-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
ORDER BY f.departure ASC, p.firstname ASC, p.lastname ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================================
-- QUESTAO 3
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SQL ORIGINAL
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE p.passenger_id IN (18473, 26605, 13653, 12041, 17638)
ORDER BY p.passenger_id ASC, f.departure ASC;

-- ----------------------------------------------------------------------------
-- 2. PLANO DE EXECUÇÃO ORIGINAL
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE p.passenger_id IN (18473, 26605, 13653, 12041, 17638)
ORDER BY p.passenger_id ASC, f.departure ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------------------------
-- 3. ESTRUTURAS OU COMANDOS TESTADOS / NOTAS DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
-- - Filtro IN no PASSENGER_ID para restringir a consulta aos 5 passageiros especificados.
-- - Concatenação de p.firstname e p.lastname vindo diretamente da TAB_AIR_PASSENGERS, dispensando o JOIN desnecessário com PASSENGERS_DETAILS.
-- - Junção via TAB_AIR_FLIGHTS_SCHEDULES com TAB_AIR_AIRPORTS para obter aeroportos de origem e destino.

-- ----------------------------------------------------------------------------
-- 4. CRIAÇÃO DE ÍNDICES DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
CREATE INDEX idx_passengers_id_q3 
ON TAB_AIR_PASSENGERS (passenger_id);

CREATE INDEX idx_flights_flightno_dept 
ON TAB_AIR_FLIGHTS (flight_id, flightno, departure);

-- ----------------------------------------------------------------------------
-- 5. SQL APÓS OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE p.passenger_id IN (18473, 26605, 13653, 12041, 17638)
ORDER BY p.passenger_id ASC, f.departure ASC;

-- ----------------------------------------------------------------------------
-- 6. PLANO DE EXECUÇÃO OTIMIZADO
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    b.booking_id,
    b.seat,
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
JOIN TAB_AIR_FLIGHTS f 
    ON b.flight_id = f.flight_id
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
WHERE p.passenger_id IN (18473, 26605, 13653, 12041, 17638)
ORDER BY p.passenger_id ASC, f.departure ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================================
-- QUESTAO 4
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SQL ORIGINAL
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    COUNT(b.booking_id) AS qtd_reservas,
    SUM(b.price) AS valor_total_pago,
    ROUND(AVG(b.price), 2) AS valor_medio_reserva
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
GROUP BY 
    p.passenger_id, 
    p.firstname,
    p.lastname
HAVING COUNT(b.booking_id) >= 10
   AND SUM(b.price) >= 1500
ORDER BY SUM(b.price) DESC;

-- ----------------------------------------------------------------------------
-- 2. PLANO DE EXECUÇÃO ORIGINAL
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    COUNT(b.booking_id) AS qtd_reservas,
    SUM(b.price) AS valor_total_pago,
    ROUND(AVG(b.price), 2) AS valor_medio_reserva
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
GROUP BY 
    p.passenger_id, 
    p.firstname,
    p.lastname
HAVING COUNT(b.booking_id) >= 10
   AND SUM(b.price) >= 1500
ORDER BY SUM(b.price) DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------------------------
-- 3. ESTRUTURAS OU COMANDOS TESTADOS / NOTAS DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
-- - Agrupamento por passageiro (PASSENGER_ID, FIRSTNAME e LASTNAME) utilizando GROUP BY diretamente da TAB_AIR_PASSENGERS.
-- - Remoção do JOIN desnecessário com TAB_AIR_PASSENGERS_DETAILS, reduzindo o custo de I/O da consulta.
-- - Aplicação do HAVING com filtros combinados sobre contagem e soma dos preços das reservas.

-- ----------------------------------------------------------------------------
-- 4. CRIAÇÃO DE ÍNDICES DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
CREATE INDEX idx_passengers_id_names 
ON TAB_AIR_PASSENGERS (passenger_id, firstname, lastname);

CREATE INDEX idx_bookings_pass_price 
ON TAB_AIR_BOOKINGS (passenger_id, price, booking_id);

-- ----------------------------------------------------------------------------
-- 5. SQL APÓS OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    COUNT(b.booking_id) AS qtd_reservas,
    SUM(b.price) AS valor_total_pago,
    ROUND(AVG(b.price), 2) AS valor_medio_reserva
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
GROUP BY 
    p.passenger_id, 
    p.firstname,
    p.lastname
HAVING COUNT(b.booking_id) >= 10
   AND SUM(b.price) >= 1500
ORDER BY SUM(b.price) DESC;

-- ----------------------------------------------------------------------------
-- 6. PLANO DE EXECUÇÃO OTIMIZADO
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_passageiro,
    COUNT(b.booking_id) AS qtd_reservas,
    SUM(b.price) AS valor_total_pago,
    ROUND(AVG(b.price), 2) AS valor_medio_reserva
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_BOOKINGS b 
    ON p.passenger_id = b.passenger_id
GROUP BY 
    p.passenger_id, 
    p.firstname,
    p.lastname
HAVING COUNT(b.booking_id) >= 10
   AND SUM(b.price) >= 1500
ORDER BY SUM(b.price) DESC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================================
-- QUESTAO 5
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SQL ORIGINAL
-- ----------------------------------------------------------------------------
SELECT 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id AS aeronave,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino,
    COUNT(b.booking_id) AS qtd_reservas,
    NVL(SUM(b.price), 0) AS valor_total_pago,
    NVL(AVG(b.price), 0) AS valor_medio_reserva
FROM TAB_AIR_FLIGHTS f
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
LEFT JOIN TAB_AIR_AIRPLANES ap 
    ON f.airplane_id = ap.airplane_id
LEFT JOIN TAB_AIR_BOOKINGS b 
    ON f.flight_id = b.flight_id
WHERE f.departure >= TO_DATE('2023-03-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
GROUP BY 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id,
    orig.name,
    dest.name
ORDER BY f.departure ASC, f.flightno ASC;

-- ----------------------------------------------------------------------------
-- 2. PLANO DE EXECUÇÃO ORIGINAL
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id AS aeronave,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino,
    COUNT(b.booking_id) AS qtd_reservas,
    NVL(SUM(b.price), 0) AS valor_total_pago,
    NVL(AVG(b.price), 0) AS valor_medio_reserva
FROM TAB_AIR_FLIGHTS f
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
LEFT JOIN TAB_AIR_AIRPLANES ap 
    ON f.airplane_id = ap.airplane_id
LEFT JOIN TAB_AIR_BOOKINGS b 
    ON f.flight_id = b.flight_id
WHERE f.departure >= TO_DATE('2023-03-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
GROUP BY 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id,
    orig.name,
    dest.name
ORDER BY f.departure ASC, f.flightno ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------------------------
-- 3. ESTRUTURAS OU COMANDOS TESTADOS / NOTAS DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
-- - Utilizado LEFT JOIN com TAB_AIR_BOOKINGS para incluir os voos sem reservas (retornando contagem igual a 0).
-- - Utilizado LEFT JOIN com TAB_AIR_AIRPLANES relacionando via f.airplane_id para tratar voos sem aeronave atribuída.

-- ----------------------------------------------------------------------------
-- 4. CRIAÇÃO DE ÍNDICES DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
CREATE INDEX idx_flights_dept_flno_q5 
ON TAB_AIR_FLIGHTS (departure, flightno, flight_id, airplane_id);

CREATE INDEX idx_bookings_flight_id 
ON TAB_AIR_BOOKINGS (flight_id, booking_id, price);

-- ----------------------------------------------------------------------------
-- 5. SQL APÓS OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
SELECT 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id AS aeronave,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino,
    COUNT(b.booking_id) AS qtd_reservas,
    NVL(SUM(b.price), 0) AS valor_total_pago,
    NVL(AVG(b.price), 0) AS valor_medio_reserva
FROM TAB_AIR_FLIGHTS f
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
LEFT JOIN TAB_AIR_AIRPLANES ap 
    ON f.airplane_id = ap.airplane_id
LEFT JOIN TAB_AIR_BOOKINGS b 
    ON f.flight_id = b.flight_id
WHERE f.departure >= TO_DATE('2023-03-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
GROUP BY 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id,
    orig.name,
    dest.name
ORDER BY f.departure ASC, f.flightno ASC;

-- ----------------------------------------------------------------------------
-- 6. PLANO DE EXECUÇÃO OTIMIZADO
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id AS aeronave,
    orig.name AS aeroporto_origem,
    dest.name AS aeroporto_destino,
    COUNT(b.booking_id) AS qtd_reservas,
    NVL(SUM(b.price), 0) AS valor_total_pago,
    NVL(AVG(b.price), 0) AS valor_medio_reserva
FROM TAB_AIR_FLIGHTS f
JOIN TAB_AIR_FLIGHTS_SCHEDULES fs 
    ON f.flightno = fs.flightno
JOIN TAB_AIR_AIRLINES al 
    ON fs.airline_id = al.airline_id
JOIN TAB_AIR_AIRPORTS orig 
    ON fs.from_airport_id = orig.airport_id
JOIN TAB_AIR_AIRPORTS dest 
    ON fs.to_airport_id = dest.airport_id
LEFT JOIN TAB_AIR_AIRPLANES ap 
    ON f.airplane_id = ap.airplane_id
LEFT JOIN TAB_AIR_BOOKINGS b 
    ON f.flight_id = b.flight_id
WHERE f.departure >= TO_DATE('2023-03-01', 'YYYY-MM-DD')
  AND f.departure <  TO_DATE('2023-04-01', 'YYYY-MM-DD')
GROUP BY 
    f.flight_id,
    f.flightno,
    f.departure,
    f.arrival,
    al.airline_name,
    ap.airplane_id,
    orig.name,
    dest.name
ORDER BY f.departure ASC, f.flightno ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================================
-- QUESTAO 6
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SQL ORIGINAL
-- ----------------------------------------------------------------------------
SELECT
    a.airport_id,
    a.name AS nome_aeroporto,
    g.city,
    g.country
FROM TAB_AIR_AIRPORTS a
JOIN TAB_AIR_AIRPORTS_GEO g 
    ON a.airport_id = g.airport_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs1 
    WHERE fs1.from_airport_id = a.airport_id
)
AND NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs2 
    WHERE fs2.to_airport_id = a.airport_id
)
ORDER BY g.country ASC, g.city ASC, a.name ASC;

-- ----------------------------------------------------------------------------
-- 2. PLANO DE EXECUÇÃO ORIGINAL
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT
    a.airport_id,
    a.name AS nome_aeroporto,
    g.city,
    g.country
FROM TAB_AIR_AIRPORTS a
JOIN TAB_AIR_AIRPORTS_GEO g 
    ON a.airport_id = g.airport_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs1 
    WHERE fs1.from_airport_id = a.airport_id
)
AND NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs2 
    WHERE fs2.to_airport_id = a.airport_id
)
ORDER BY g.country ASC, g.city ASC, a.name ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------------------------
-- 3. ESTRUTURAS OU COMANDOS TESTADOS / NOTAS DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
-- - Inclusão do JOIN com TAB_AIR_AIRPORTS_GEO para resgatar as colunas geográficas (CITY e COUNTRY).
-- - Ordenação alfabética por país, cidade e nome do aeroporto conforme os requisitos informados.

-- ----------------------------------------------------------------------------
-- 4. CRIAÇÃO DE ÍNDICES DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
CREATE INDEX idx_schedules_from_airport 
ON TAB_AIR_FLIGHTS_SCHEDULES (from_airport_id);

CREATE INDEX idx_schedules_to_airport 
ON TAB_AIR_FLIGHTS_SCHEDULES (to_airport_id);

-- ----------------------------------------------------------------------------
-- 5. SQL APÓS OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
SELECT 
    a.airport_id,
    a.name AS nome_aeroporto,
    g.city,
    g.country
FROM TAB_AIR_AIRPORTS a
JOIN TAB_AIR_AIRPORTS_GEO g 
    ON a.airport_id = g.airport_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs1 
    WHERE fs1.from_airport_id = a.airport_id
)
AND NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs2 
    WHERE fs2.to_airport_id = a.airport_id
)
ORDER BY g.country ASC, g.city ASC, a.name ASC;

-- ----------------------------------------------------------------------------
-- 6. PLANO DE EXECUÇÃO OTIMIZADO
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    a.airport_id,
    a.name AS nome_aeroporto,
    g.city,
    g.country
FROM TAB_AIR_AIRPORTS a
JOIN TAB_AIR_AIRPORTS_GEO g 
    ON a.airport_id = g.airport_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs1 
    WHERE fs1.from_airport_id = a.airport_id
)
AND NOT EXISTS (
    SELECT 1 
    FROM TAB_AIR_FLIGHTS_SCHEDULES fs2 
    WHERE fs2.to_airport_id = a.airport_id
)
ORDER BY g.country ASC, g.city ASC, a.name ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ============================================================================
-- QUESTAO 7
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SQL ORIGINAL
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_completo,
    pd.city,
    pd.zip,
    pd.country
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_PASSENGERS_DETAILS pd 
    ON p.passenger_id = pd.passenger_id
WHERE UPPER(p.lastname) = 'SMITH'
ORDER BY nome_completo ASC;

-- ----------------------------------------------------------------------------
-- 2. PLANO DE EXECUÇÃO ORIGINAL
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_completo,
    pd.city,
    pd.zip,
    pd.country
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_PASSENGERS_DETAILS pd 
    ON p.passenger_id = pd.passenger_id
WHERE UPPER(p.lastname) = 'SMITH'
ORDER BY nome_completo ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- ----------------------------------------------------------------------------
-- 3. ESTRUTURAS OU COMANDOS TESTADOS / NOTAS DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
-- - Utilização da função UPPER na coluna p.lastname para garantir a busca case-insensitive exata do sobrenome 'SMITH'.
-- - Concatenação de p.firstname e p.lastname para formatação do nome completo.
-- - Junção via PASSENGER_ID com TAB_AIR_PASSENGERS_DETAILS para resgatar os dados de localização (cidade, CEP e país).
-- - Substituição da ordenação pelo alias 'nome_completo' pelas colunas diretas (p.firstname ASC, p.lastname ASC) no SQL otimizado para melhor suporte por índice.

-- ----------------------------------------------------------------------------
-- 4. CRIAÇÃO DE ÍNDICES DE OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
CREATE INDEX idx_pass_upper_lastname 
ON TAB_AIR_PASSENGERS (UPPER(lastname), passenger_id, firstname);

-- ----------------------------------------------------------------------------
-- 5. SQL APÓS OTIMIZAÇÃO
-- ----------------------------------------------------------------------------
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_completo,
    pd.city,
    pd.zip,
    pd.country
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_PASSENGERS_DETAILS pd 
    ON p.passenger_id = pd.passenger_id
WHERE UPPER(p.lastname) = 'SMITH'
ORDER BY p.firstname ASC, p.lastname ASC;

-- ----------------------------------------------------------------------------
-- 6. PLANO DE EXECUÇÃO OTIMIZADO
-- ----------------------------------------------------------------------------
EXPLAIN PLAN FOR
SELECT 
    p.passenger_id,
    p.firstname || ' ' || p.lastname AS nome_completo,
    pd.city,
    pd.zip,
    pd.country
FROM TAB_AIR_PASSENGERS p
JOIN TAB_AIR_PASSENGERS_DETAILS pd 
    ON p.passenger_id = pd.passenger_id
WHERE UPPER(p.lastname) = 'SMITH'
ORDER BY p.firstname ASC, p.lastname ASC;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);