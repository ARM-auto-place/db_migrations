
-- +goose Up
-- +goose StatementBegin

CREATE SCHEMA IF NOT EXISTS cars;
CREATE SCHEMA IF NOT EXISTS migrations;

CREATE TYPE cars.car_power AS ENUM (
    'horsepower',
    'electro-forces'
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

CREATE TABLE IF NOT EXISTS cars.car (
    id UUID PRIMARY KEY,
    mark TEXT NOT NULL,
    model TEXT NOT NULL,
    build_year SMALLINT NOT NULL,
    power INT NOT NULL,
    type_power cars.car_power NOT NULL,
    owners INT,
    condition cars.car_conditions,
    steering_wheel cars.car_steering_wheel,
    color TEXT,
    descriptions TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    release BOOLEAN NOT NULL DEFAULT TRUE,
    images JSONB NOT NULL DEFAULT '[]'::jsonb,
    vin VARCHAR(17) NOT NULL UNIQUE,
    kilometre INT,

    CONSTRAINT car_power_positive CHECK (power >= 0),
    CONSTRAINT car_owners_positive CHECK (owners IS NULL OR owners >= 0),
    CONSTRAINT car_year_valid CHECK (build_year BETWEEN 1886 AND 2100),
    CONSTRAINT car_kilometre_positive CHECK (kilometre IS NULL OR kilometre >= 0)
);

CREATE TABLE IF NOT EXISTS cars.car_price (
    car_id UUID PRIMARY KEY REFERENCES cars.car(id) ON DELETE CASCADE,
    price INT NOT NULL CHECK (price >= 0)
);

CREATE TABLE IF NOT EXISTS cars.gos_info (
    car_id UUID PRIMARY KEY REFERENCES cars.car(id) ON DELETE CASCADE,
    verified BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS cars.user_cars (
    car_id UUID PRIMARY KEY REFERENCES cars.car(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_user_cars_user_id
    ON cars.user_cars(user_id);

CREATE TABLE IF NOT EXISTS cars.favorite_cars (
    car_id UUID NOT NULL REFERENCES cars.car(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    PRIMARY KEY (car_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_favorite_cars_user_id
    ON cars.favorite_cars(user_id);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS cars.favorite_cars;
DROP TABLE IF EXISTS cars.user_cars;
DROP TABLE IF EXISTS cars.gos_info;
DROP TABLE IF EXISTS cars.car_price;
DROP TABLE IF EXISTS cars.car;

DROP TYPE IF EXISTS cars.car_steering_wheel;
DROP TYPE IF EXISTS cars.car_conditions;
DROP TYPE IF EXISTS cars.car_power;

-- +goose StatementEnd
