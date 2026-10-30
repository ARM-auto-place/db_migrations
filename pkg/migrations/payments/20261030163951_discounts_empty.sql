-- +goose Up
-- +goose StatementBegin
CREATE SCHEMA IF NOT EXISTS discounts;

CREATE TABLE IF NOT EXISTS discounts.discounts (
    id int PRIMARY KEY,
    descriptions text NOT NULL,
    value int NOT NULL,
    created_dt timestamptz DEFAULT now() NOT NULL,
    end_dt timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS discounts.user_discounts (
    id uuid PRIMARY KEY,
    user_id uuid NOT NULL,
    discount_id int NOT NULL,
    created_dt timestamptz DEFAULT now() NOT NULL,
    start_dt timestamptz NULL,
    end_dt timestamptz NOT NULL,
    FOREIGN KEY (discount_id) REFERENCES discounts.discounts (id) ON DELETE CASCADE
);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
SELECT
    'down SQL query';

-- +goose StatementEnd
