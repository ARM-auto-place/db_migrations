-- +goose Up
-- +goose StatementBegin
CREATE TYPE message_status AS ENUM (
    '0', --Отправлено
    '1', --Прочитано
    '2' --Удалено
);




CREATE TABLE chats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    seller_user_id UUID NOT NULL,
    car_id UUID NOT NULL,
    last_read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chats_distinct_participants_check CHECK (user_id <> seller_user_id),
    CONSTRAINT chats_user_car_id_uk UNIQUE (user_id, car_id)
);

CREATE INDEX idx_chats_seller_created_at
    ON chats (seller_user_id, created_at DESC);


CREATE TABLE support_chat (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    support_user_id UUID,
    support_subject TEXT,
    last_read_at TIMESTAMPTZ,
    bot_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
);

CREATE INDEX idx_support_chat_user_created_at
    ON support_chat (user_id, created_at DESC);

CREATE INDEX idx_support_chat_queue
    ON support_chat (support_status, dialog_started_at DESC, created_at DESC);


CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    client_msg_id UUID NOT NULL DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    edited_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT messages_sender_client_msg_uk UNIQUE (sender_id, client_msg_id)
);

CREATE TABLE messages_support (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL,
    client_msg_id UUID NOT NULL DEFAULT gen_random_uuid(),
    text TEXT NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    edited_at TIMESTAMPTZ,
    deleted_at TIMESTAMPTZ,
    CONSTRAINT messages_support_sender_client_msg_uk UNIQUE (sender_id, client_msg_id)
);

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_id UUID NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    message_id UUID NOT NULL UNIQUE REFERENCES messages(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL,
    message_status message_status NOT NULL DEFAULT '0'
);

CREATE INDEX idx_chat_messages_chat_id ON chat_messages(chat_id);
CREATE INDEX idx_chat_messages_recipient_status
    ON chat_messages (recipient_id, message_status);

CREATE TABLE support_chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    support_chat_id UUID NOT NULL REFERENCES support_chat(id) ON DELETE CASCADE,
    message_id UUID NOT NULL UNIQUE REFERENCES messages_support(id) ON DELETE CASCADE,
    recipient_id UUID NOT NULL,
    message_status message_status NOT NULL DEFAULT '0'
);

CREATE INDEX idx_support_chat_messages_chat_id
    ON support_chat_messages(support_chat_id);

CREATE INDEX idx_support_chat_messages_recipient_status
    ON support_chat_messages (recipient_id, message_status);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP TABLE IF EXISTS support_chat_messages;
DROP TABLE IF EXISTS chat_messages;
DROP TABLE IF EXISTS messages_support;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS support_chat;
DROP TABLE IF EXISTS chats;
DROP TYPE IF EXISTS support_chat_status;
DROP TYPE IF EXISTS message_status;
-- +goose StatementEnd
