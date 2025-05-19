-- 创建 Skills 表
CREATE TABLE t_skills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at DATETIME NOT NULL,
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    is_available BOOLEAN NOT NULL,
    name TEXT NOT NULL,
    descriptions TEXT NOT NULL
);

-- 创建 SkillClass 表
CREATE TABLE t_skill_classes(
    uuid TEXT NOT NULL CHECK (LENGTH(uuid) >= 1),
    created_at DATETIME NOT NULL,
    last_updated_at DATETIME NOT NULL,
    deleted_at DATETIME,
    skill_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    specification TEXT NOT NULL,
    feature TEXT NOT NULL,
    is_customerized BOOLEAN NOT NULL,
    PRIMARY KEY (uuid)
);