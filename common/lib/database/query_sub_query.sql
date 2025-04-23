-- 创建 QueryTypes 表
CREATE TABLE QueryTypes (
    uuid TEXT NOT NULL CHECK (LENGTH(uuid) >= 1),
    created_at DATETIME NOT NULL,
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    is_customized BOOLEAN NOT NULL,
    is_available BOOLEAN NOT NULL,
    PRIMARY KEY (uuid)
);

-- 创建 SubQueryTypes 表
CREATE TABLE SubQueryTypes (
    uuid TEXT NOT NULL CHECK (LENGTH(uuid) >= 1),
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    hidden_at DATETIME,
    name TEXT NOT NULL,
    is_customized BOOLEAN NOT NULL,
    is_available BOOLEAN NOT NULL,
    PRIMARY KEY (uuid)
);

-- 创建 QueryTypesAndSubQueryTypesMapper 表
CREATE TABLE QueryTypesAndSubQueryTypesMapper (
    query_uuid TEXT NOT NULL,
    sub_query_type_uuid TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    PRIMARY KEY (query_uuid, sub_query_type_uuid)
);