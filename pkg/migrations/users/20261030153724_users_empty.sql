-- +goose Up
-- +goose StatementBegin
CREATE SCHEMA IF NOT EXISTS users;

CREATE TABLE IF NOT EXISTS users.user (
    id uuid PRIMARY KEY,
    name text NOT NULL,
    middle_name text,
    sure_name text,
    phone text NOT NULL,
    email text NOT NULL,
    photo_path varchar(255),
    age int,
    city text,
    address text
);

CREATE TABLE IF NOT EXISTS users.user_role (
    user_id uuid NOT NULL,
    ROLE users.user_roles NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users.user (id) ON DELETE CASCADE
);

CREATE TYPE users.user_roles AS ENUM (
    'admin',
    'owner',
    'seller'
);

CREATE TABLE IF NOT EXISTS users.user_settings (
    user_id uuid NOT NULL,
    dark_mode bool DEFAULT FALSE NOT NULL,
    private_data bool DEFAULT FALSE NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users.user (id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS users.user_favorites (
    user_id uuid NOT NULL,
    tag jsonb NULL,
    FOREIGN KEY (user_id) REFERENCES users.user (id) ON DELETE CASCADE
);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
SELECT
    'down SQL query';

-- +goose StatementEnd
