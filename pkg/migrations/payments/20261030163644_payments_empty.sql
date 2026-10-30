-- +goose Up
-- +goose StatementBegin
CREATE SCHEMA IF NOT EXISTS payments;

CREATE TABLE IF NOT EXISTS payments.payments (
    id uuid PRIMARY KEY,
    user_id uuid NOT NULL,
    price int NOT NULL,
    currency varchar(3) NOT NULL,
    status payments.payments_status_check NOT NULL DEFAULT 'new,' tariff_id int NOT NULL,
    created_at timestamptz DEFAULT now() NOT NULL
);

CREATE TYPE payments.payments_status_check AS ENUM (
    'pending',
    'succeeded',
    'failed'
);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
SELECT
    'down SQL query';

-- +goose StatementEnd
