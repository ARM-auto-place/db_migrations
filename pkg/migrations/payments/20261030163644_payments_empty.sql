
-- +goose Up
-- +goose StatementBegin

CREATE SCHEMA IF NOT EXISTS payments;
CREATE SCHEMA IF NOT EXISTS migrations;

CREATE TYPE payments.payments_status_check AS ENUM (
    'pending',
    'succeeded',
    'failed'
);

CREATE TABLE IF NOT EXISTS payments.payments (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    price INT NOT NULL CHECK (price >= 0),
    currency VARCHAR(3) NOT NULL,
    status payments.payments_status_check NOT NULL DEFAULT 'pending',
    tariff_id INT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_payments_user_id
    ON payments.payments(user_id);

CREATE INDEX idx_payments_status
    ON payments.payments(status);

-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin

DROP TABLE IF EXISTS payments.payments;
DROP TYPE IF EXISTS payments.payments_status_check;

-- +goose StatementEnd
