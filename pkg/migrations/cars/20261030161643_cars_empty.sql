-- +goose Up
-- +goose StatementBegin
CREATE SCHEMA IF NOT EXISTS cars;

CREATE TABLE IF NOT EXISTS cars.car (
    id uuid PRIMARY KEY,
    mark text NOT NULL,
    model text NOT NULL,
    build_year text NOT NULL,
    power int NOT NULL,
    type_power cars.car_power NOT NULL,
    owers int,
    condition cars.car_conditions,
    steering_wheel cars.car_steering_wheel,
    color text,
    descriptions text NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    release bool DEFAULT TRUE,
    images jsonb NOT NULL,
    VIN text NOT NULL,
    kilometre int
);

CREATE TYPE cars.car_power AS ENUM (
    'horsepower',
    'electro‑forces',
);

CREATE TYPE cars.car_conditions AS ENUM (
    'new',
    'used'
);

CREATE TYPE cars.car_steering_wheel AS ENUM (
    'front-wheel',
    'rear-wheel',
    'all-wheel'
);

CREATE TABLE IF NOT EXISTS cars.car_price (
    car_id uuid NOT NULL,
    price int NOT NULL,
    FOREIGN KEY (car_id) REFERENCES cars.car (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cars.gos_info (
    car_id uuid NOT NULL,
    verified bool DEFAULT TRUE,
    FOREIGN KEY (car_id) REFERENCES cars.car (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cars.user_cars (
    car_id uuid NOT NULL,
    user_id uuid NOT NULL,
    FOREIGN KEY (car_id) REFERENCES cars.car (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cars.favorite_carse (
    car_id uuid NOT NULL,
    user_id uuid NOT NULL,
    FOREIGN KEY (car_id) REFERENCES cars.car (id) ON DELETE CASCADE
);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
SELECT
    'down SQL query';

-- +goose StatementEnd
