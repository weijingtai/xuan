-- 创建 DivinationTypes 表
CREATE TABLE t_divination_types (
    uuid TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    is_customized BOOLEAN NOT NULL,
    is_available BOOLEAN NOT NULL,
    PRIMARY KEY (uuid)
);

-- 创建 SubDivinationTypes 表
CREATE TABLE t_sub_divination_types (
    uuid TEXT NOT NULL,
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    hidden_at DATETIME,
    name TEXT NOT NULL,
    is_customized BOOLEAN NOT NULL,
    is_available BOOLEAN NOT NULL,
    PRIMARY KEY (uuid)
);

-- 创建 QueryTypesAndSubQueryTypesMapper 表
CREATE TABLE t_divination_types_sub_divination_types_mapper (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    divination_uuid TEXT NOT NULL,
    sub_divination_type_uuid TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    PRIMARY KEY (divination_uuid, sub_divination_type_uuid)
);