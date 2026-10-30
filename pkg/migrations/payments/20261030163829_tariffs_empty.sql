-- +goose Up
-- +goose StatementBegin
CREATE SCHEMA IF NOT EXISTS tariffs;

CREATE TABLE IF NOT EXISTS tariffs.tariffs (
    id int PRIMARY KEY,
    descriptions text NOT NULL,
    price int NOT NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    updated_at timestamptz NOT NULL DEFAULT NOW()
);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
SELECT
    'down SQL query';

-- +goose StatementEnd
