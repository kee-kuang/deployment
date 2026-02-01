create table public.pro_adorn
(
    id          bigserial
        primary key,
    create_time bigint      default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                     ((1000)::bigint)::double precision) not null,
    enabled     boolean     default false                                not null,
    shop_id     bigint,
    store_id    bigint      default 0                                    not null,
    is_deleted  integer     default 0                                    not null,
    version     integer     default 0                                    not null,
    update_time bigint      default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                     ((1000)::bigint)::double precision) not null,
    name        varchar(50) default ''::character varying                not null,
    type        integer     default 0                                    not null
);

comment on column public.pro_adorn.create_time is '创建时间(自动填充)';

comment on column public.pro_adorn.shop_id is '商城ID';

comment on column public.pro_adorn.store_id is '店铺ID';

comment on column public.pro_adorn.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn.version is '版本号(乐观锁)';

comment on column public.pro_adorn.update_time is '修改时间(自动填充)';

comment on column public.pro_adorn.type is '装修类型：1为商城，2为店铺';

alter table public.pro_adorn
    owner to postgres;

create table public.pro_adorn_advert
(
    id          bigserial
        primary key,
    category_id bigint,
    create_time bigint,
    link        varchar(200),
    member_id   bigint,
    name        varchar(15),
    pic_url     varchar(200),
    role_id     bigint,
    sort        smallint,
    adorn_id    bigint,
    type        smallint,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_adorn_advert.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_advert.version is '版本号(乐观锁)';

comment on column public.pro_adorn_advert.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_advert
    owner to postgres;

create table public.pro_adorn_brand
(
    id          bigserial
        primary key,
    brand_ids   jsonb,
    category_id bigint,
    adorn_id    bigint,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    create_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null,
    template_id bigint
);

comment on column public.pro_adorn_brand.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_brand.version is '版本号(乐观锁)';

comment on column public.pro_adorn_brand.create_time is '创建时间(自动填充)';

comment on column public.pro_adorn_brand.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_brand
    owner to postgres;

create table public.pro_adorn_category
(
    id               bigserial
        primary key,
    advert_pic_url   text,
    category_id      bigint,
    is_show          smallint,
    member_id        bigint,
    role_id          bigint,
    adorn_id         bigint,
    two_category_ids jsonb,
    template_id      bigint,
    is_deleted       integer default 0                                    not null,
    version          integer default 0                                    not null,
    create_time      bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                      ((1000)::bigint)::double precision) not null,
    update_time      bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                      ((1000)::bigint)::double precision) not null
);

comment on column public.pro_adorn_category.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_category.version is '版本号(乐观锁)';

comment on column public.pro_adorn_category.create_time is '创建时间(自动填充)';

comment on column public.pro_adorn_category.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_category
    owner to postgres;

create table public.pro_adorn_column
(
    id           bigserial
        primary key,
    column_list  jsonb,
    member_id    bigint,
    role_id      bigint,
    adorn_id     bigint,
    type         smallint,
    template_id  bigint,
    columnbolist jsonb,
    is_deleted   integer default 0                                                                                  not null,
    version      integer default 0                                                                                  not null,
    create_time  bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                  ((1000)::bigint)::double precision)                                               not null,
    update_time  bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                  ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_adorn_column.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_column.version is '版本号(乐观锁)';

comment on column public.pro_adorn_column.create_time is '创建时间(自动填充)';

comment on column public.pro_adorn_column.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_column
    owner to postgres;

create table public.pro_adorn_commodity
(
    id                bigserial
        primary key,
    category_id       bigint,
    commodity_id_list jsonb,
    member_id         bigint,
    role_id           bigint,
    adorn_id          bigint,
    is_deleted        integer default 0                                    not null,
    version           integer default 0                                    not null,
    create_time       bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                       ((1000)::bigint)::double precision) not null,
    update_time       bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                       ((1000)::bigint)::double precision) not null
);

comment on column public.pro_adorn_commodity.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_commodity.version is '版本号(乐观锁)';

comment on column public.pro_adorn_commodity.create_time is '创建时间(自动填充)';

comment on column public.pro_adorn_commodity.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_commodity
    owner to postgres;

create table public.pro_adorn_first_category
(
    id            bigserial
        primary key,
    category_id   bigint,
    category_name varchar(100),
    is_show       smallint default 1,
    member_id     bigint,
    role_id       bigint,
    shop_id       bigint,
    sort          integer,
    adorn_id      bigint,
    template_id   bigint,
    is_deleted    integer  default 0                                    not null,
    version       integer  default 0                                    not null,
    create_time   bigint   default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                    ((1000)::bigint)::double precision) not null,
    update_time   bigint   default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                    ((1000)::bigint)::double precision) not null
);

comment on column public.pro_adorn_first_category.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_first_category.version is '版本号(乐观锁)';

comment on column public.pro_adorn_first_category.create_time is '创建时间(自动填充)';

comment on column public.pro_adorn_first_category.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_first_category
    owner to postgres;

create table public.pro_adorn_main_portal
(
    id          bigserial
        primary key,
    create_time bigint,
    list        jsonb,
    adorn_id    bigint,
    template_id bigint,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_adorn_main_portal.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_main_portal.version is '版本号(乐观锁)';

comment on column public.pro_adorn_main_portal.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_main_portal
    owner to postgres;


create table public.pro_adorn_store
(
    id            bigserial
        primary key,
    category_id   bigint,
    shop_id_list  jsonb,
    adorn_id      bigint,
    store_id_list jsonb   default '[]'::jsonb                                                                        not null,
    is_deleted    integer default 0                                                                                  not null,
    version       integer default 0                                                                                  not null,
    create_time   bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                   ((1000)::bigint)::double precision)                                               not null,
    update_time   bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                   ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_adorn_store.store_id_list is '店铺ID列表';

comment on column public.pro_adorn_store.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_adorn_store.version is '版本号(乐观锁)';

comment on column public.pro_adorn_store.create_time is '创建时间(自动填充)';

comment on column public.pro_adorn_store.update_time is '修改时间(自动填充)';

alter table public.pro_adorn_store
    owner to postgres;

create table public.pro_app_adorn
(
    id                     bigserial
        primary key,
    adorn_content          jsonb,
    category_adorn_content jsonb,
    create_time            bigint,
    member_id              bigint,
    role_id                bigint,
    adorn_id               bigint,
    template_id            bigint,
    is_deleted             integer default 0                                    not null,
    version                integer default 0                                    not null,
    update_time            bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                            ((1000)::bigint)::double precision) not null
);

comment on column public.pro_app_adorn.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_app_adorn.version is '版本号(乐观锁)';

comment on column public.pro_app_adorn.update_time is '修改时间(自动填充)';

alter table public.pro_app_adorn
    owner to postgres;

create table public.pro_country_area
(
    id          bigserial
        primary key,
    code        varchar(10)                                                                                        not null,
    create_time bigint,
    name        varchar(50)                                                                                        not null,
    name_en     varchar(50)                                                                                        not null,
    status      boolean default true                                                                               not null,
    tel_code    varchar(10)                                                                                        not null,
    tel_length  integer                                                                                            not null,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_country_area.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_country_area.version is '版本号(乐观锁)';

comment on column public.pro_country_area.update_time is '修改时间(自动填充)';

alter table public.pro_country_area
    owner to postgres;

create table public.pro_currency
(
    id          bigserial
        primary key,
    create_time bigint,
    name        varchar(50)                                                                                        not null,
    name_en     varchar(50)                                                                                        not null,
    status      boolean default true                                                                               not null,
    symbol      varchar(10)                                                                                        not null,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_currency.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_currency.version is '版本号(乐观锁)';

comment on column public.pro_currency.update_time is '修改时间(自动填充)';

alter table public.pro_currency
    owner to postgres;

create table public.pro_language
(
    id          bigserial
        primary key,
    create_time bigint,
    name        varchar(50)                                                                                        not null,
    name_en     varchar(50)                                                                                        not null,
    status      boolean default true                                                                               not null,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_language.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_language.version is '版本号(乐观锁)';

comment on column public.pro_language.update_time is '修改时间(自动填充)';

alter table public.pro_language
    owner to postgres;

create table public.pro_member_content
(
    id      bigserial
        primary key,
    content text
);

alter table public.pro_member_content
    owner to postgres;

create table public.pro_member_logistics
(
    id                     bigserial
        primary key,
    about_seo              jsonb,
    album_name             varchar(128),
    album_url              varchar(200),
    area_list              jsonb,
    areas                  varchar(500),
    avg_trade_comment_star smallint,
    business_licence       varchar(500),
    city_code_list         text,
    company_pics           jsonb,
    create_time            bigint,
    credit_point           integer,
    describe               varchar(400),
    establishment_date     varchar(128),
    honor_pics             jsonb,
    level_tag              varchar(64),
    logo                   varchar(200),
    main_business          jsonb,
    member_id              bigint,
    member_name            varchar(200),
    provinces_code_list    text,
    register_address       varchar(255),
    register_area          varchar(255),
    register_years         integer,
    registered_capital     varchar(128),
    role_id                bigint,
    slideshow_list         jsonb,
    status                 smallint,
    is_deleted             integer default 0                                    not null,
    version                integer default 0                                    not null,
    update_time            bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                            ((1000)::bigint)::double precision) not null
);

comment on column public.pro_member_logistics.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_member_logistics.version is '版本号(乐观锁)';

comment on column public.pro_member_logistics.update_time is '修改时间(自动填充)';

alter table public.pro_member_logistics
    owner to postgres;

create index pro_member_logistics_member_id_idx
    on public.pro_member_logistics (member_id);

create index pro_member_logistics_role_id_idx
    on public.pro_member_logistics (role_id);

create table public.pro_member_logistics_collect
(
    id           bigserial
        primary key,
    create_time  bigint,
    logistics_id bigint,
    member_id    bigint,
    user_id      bigint
);

alter table public.pro_member_logistics_collect
    owner to postgres;

create table public.pro_member_process
(
    id                     bigserial
        primary key,
    about_seo              jsonb,
    album_name             varchar(128),
    album_url              varchar(200),
    area_list              jsonb,
    areas                  varchar(500),
    avg_trade_comment_star smallint,
    business_licence       varchar(500),
    category_list          jsonb,
    city_code_list         text,
    company_pics           jsonb,
    create_time            bigint,
    credit_point           integer,
    describe               varchar(400),
    establishment_date     varchar(128),
    honor_pics             jsonb,
    level_tag              varchar(64),
    logo                   varchar(200),
    member_id              bigint,
    member_name            varchar(200),
    plant_area             integer,
    provinces_code_list    text,
    register_address       varchar(255),
    register_area          varchar(255),
    register_years         integer,
    registered_capital     varchar(128),
    role_id                bigint,
    slideshow_list         jsonb,
    staff_num              integer,
    status                 smallint,
    year_process_amount    integer,
    is_deleted             integer default 0                                    not null,
    version                integer default 0                                    not null,
    update_time            bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                            ((1000)::bigint)::double precision) not null
);

comment on column public.pro_member_process.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_member_process.version is '版本号(乐观锁)';

comment on column public.pro_member_process.update_time is '修改时间(自动填充)';

alter table public.pro_member_process
    owner to postgres;

create index pro_member_process_member_id_idx
    on public.pro_member_process (member_id);

create index pro_member_process_role_id_idx
    on public.pro_member_process (role_id);

create table public.pro_member_process_collect
(
    id          bigserial
        primary key,
    create_time bigint,
    member_id   bigint,
    process_id  bigint,
    user_id     bigint
);

alter table public.pro_member_process_collect
    owner to postgres;

create table public.pro_member_purchase
(
    id                     bigserial
        primary key,
    advert_pics            jsonb,
    album_name             varchar(128),
    album_url              varchar(200),
    area_list              jsonb,
    areas                  varchar(500),
    avg_trade_comment_star smallint,
    business_licence       varchar(500),
    city_code_list         text,
    city_name              varchar(255),
    company_pics           jsonb,
    create_time            bigint,
    credit_point           integer,
    describe               varchar(400),
    establishment_date     varchar(128),
    honor_pics             jsonb,
    level_tag              varchar(64),
    logo                   varchar(200),
    member_id              bigint,
    member_name            varchar(200),
    province_name          varchar(255),
    provinces_code_list    text,
    register_address       varchar(255),
    register_area          varchar(255),
    register_years         integer,
    registered_capital     varchar(128),
    role_id                bigint,
    slideshow_list         jsonb,
    status                 smallint,
    is_deleted             integer default 0                                    not null,
    version                integer default 0                                    not null,
    update_time            bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                            ((1000)::bigint)::double precision) not null
);

comment on column public.pro_member_purchase.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_member_purchase.version is '版本号(乐观锁)';

comment on column public.pro_member_purchase.update_time is '修改时间(自动填充)';

alter table public.pro_member_purchase
    owner to postgres;

create index pro_member_purchase_member_id_idx
    on public.pro_member_purchase (member_id);

create index pro_member_purchase_role_id_idx
    on public.pro_member_purchase (role_id);

create table public.pro_member_purchase_collect
(
    id          bigserial
        primary key,
    create_time bigint,
    member_id   bigint,
    purchase_id bigint,
    user_id     bigint
);

alter table public.pro_member_purchase_collect
    owner to postgres;

create table public.pro_member_self
(
    id                     bigserial
        primary key,
    address                varchar(120),
    album_name             varchar(128),
    album_url              varchar(200),
    areas                  varchar(500),
    avg_trade_comment_star smallint,
    business_licence       varchar(500),
    city_code_list         text,
    create_time            bigint,
    credit_point           integer,
    describe               varchar(400),
    establishment_date     varchar(128),
    honor_pics             jsonb,
    level_tag              varchar(64),
    member_id              bigint,
    member_name            varchar(200),
    member_shop_areas      jsonb,
    phone                  varchar(16),
    provinces_code_list    text,
    register_address       varchar(255),
    register_area          varchar(255),
    register_years         integer,
    registered_capital     varchar(128),
    role_id                bigint,
    shop_id                bigint,
    status                 smallint,
    url                    varchar(512),
    workshop_pics          jsonb,
    area_list              jsonb,
    is_deleted             integer default 0                                    not null,
    version                integer default 0                                    not null,
    update_time            bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                            ((1000)::bigint)::double precision) not null
);

comment on column public.pro_member_self.area_list is '地市';

comment on column public.pro_member_self.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_member_self.version is '版本号(乐观锁)';

comment on column public.pro_member_self.update_time is '修改时间(自动填充)';

alter table public.pro_member_self
    owner to postgres;

create index pro_member_self_member_id_idx
    on public.pro_member_self (member_id);

create index pro_member_self_role_id_idx
    on public.pro_member_self (role_id);

create table public.pro_member_template
(
    id            bigserial
        primary key,
    content_id    bigint,
    member_id     bigint,
    menu_path     varchar(400) not null,
    role_id       bigint,
    status        integer,
    template_name varchar(150)
);

alter table public.pro_member_template
    owner to postgres;

create table public.pro_self_shop_model
(
    id          bigserial
        primary key,
    name        varchar(20)  default ''::character varying                not null,
    environment integer      default 0                                    not null,
    property    integer      default 0                                    not null,
    logo_url    varchar(255) default ''::character varying                not null,
    describe    varchar(80)  default ''::character varying                not null,
    currency_id bigint       default 0                                    not null,
    country_id  bigint       default 0                                    not null,
    language_id bigint       default 0                                    not null,
    is_deleted  integer      default 0                                    not null,
    version     integer      default 0                                    not null,
    create_time bigint       default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                      ((1000)::bigint)::double precision) not null,
    update_time bigint       default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                      ((1000)::bigint)::double precision) not null,
    url         varchar(255) default ''::character varying                not null
);

comment on table public.pro_self_shop_model is '自营商城模型表(用于创建自营商城时获取默认数据)';

comment on column public.pro_self_shop_model.name is '商城名称';

comment on column public.pro_self_shop_model.environment is '商城环境: 1.web 2.H5 3.小程序 4.APP';

comment on column public.pro_self_shop_model.property is '商城属性: 1.B端商城 2.C端商城';

comment on column public.pro_self_shop_model.logo_url is '商城LOGO';

comment on column public.pro_self_shop_model.describe is '商城描述';

comment on column public.pro_self_shop_model.currency_id is '币种';

comment on column public.pro_self_shop_model.country_id is '国家';

comment on column public.pro_self_shop_model.language_id is '语言';

comment on column public.pro_self_shop_model.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_self_shop_model.version is '版本号(乐观锁)';

comment on column public.pro_self_shop_model.create_time is '创建时间(自动填充)';

comment on column public.pro_self_shop_model.update_time is '修改时间(自动填充)';

comment on column public.pro_self_shop_model.url is '商城子域名';

alter table public.pro_self_shop_model
    owner to postgres;

create table public.pro_seo
(
    id          bigserial
        primary key,
    create_time bigint,
    description varchar(200),
    door_id     bigint,
    door_type   smallint,
    keywords    varchar(100),
    link        varchar(256),
    name        varchar(25),
    status      smallint,
    title       varchar(50),
    type        smallint,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_seo.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_seo.version is '版本号(乐观锁)';

comment on column public.pro_seo.update_time is '修改时间(自动填充)';

alter table public.pro_seo
    owner to postgres;

create index pro_seo_door_id_idx
    on public.pro_seo (door_id);

create table public.pro_store
(
    id                     bigserial
        primary key,
    address                varchar(120),
    album_name             varchar(128),
    album_url              varchar(200),
    areas                  varchar(500),
    avg_trade_comment_star smallint,
    business_licence       varchar(500),
    city_code_list         text,
    create_time            bigint,
    credit_point           integer,
    describe               varchar(400),
    establishment_date     varchar(128),
    honor_pics             jsonb,
    lat                    varchar(64),
    level_tag              varchar(64),
    lng                    varchar(64),
    logo                   varchar(200),
    member_id              bigint,
    member_name            varchar(200),
    area_list              jsonb,
    name                   varchar(200),
    phone                  varchar(16),
    promotion_pic          varchar(256),
    provinces_code_list    text,
    register_address       varchar(255),
    register_area          varchar(255),
    register_years         integer,
    registered_capital     varchar(128),
    role_id                bigint,
    status                 smallint,
    workshop_pics          jsonb,
    is_deleted             smallint default 0                                    not null,
    version                integer  default 0                                    not null,
    update_time            bigint   default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                             ((1000)::bigint)::double precision) not null,
    adorn_id               bigint   default 0                                    not null,
    is_open_mro            boolean                                               not null
);

comment on column public.pro_store.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_store.version is '版本号(乐观锁)';

comment on column public.pro_store.update_time is '修改时间(自动填充)';

comment on column public.pro_store.adorn_id is '模板ID';

comment on column public.pro_store.is_open_mro is '是否启用商城MRO筛选模';

alter table public.pro_store
    owner to postgres;

create table public.pro_store_collect
(
    id          bigserial
        primary key,
    create_time bigint,
    member_id   bigint,
    store_id    bigint,
    user_id     bigint,
    is_deleted  integer default 0                                                                                  not null,
    version     integer default 0                                                                                  not null,
    update_time bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                 ((1000)::bigint)::double precision)                                               not null
);

comment on column public.pro_store_collect.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_store_collect.version is '版本号(乐观锁)';

comment on column public.pro_store_collect.update_time is '修改时间(自动填充)';

alter table public.pro_store_collect
    owner to postgres;

create table public.pro_unit
(
    id                 bigserial
        primary key,
    status             boolean                                              not null,
    is_deleted         integer default 0                                    not null,
    version            integer default 0                                    not null,
    create_time        bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                        ((1000)::bigint)::double precision) not null,
    update_time        bigint  default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                        ((1000)::bigint)::double precision) not null
);

comment on column public.pro_unit.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_unit.version is '版本号(乐观锁)';

comment on column public.pro_unit.create_time is '创建时间(自动填充)';

comment on column public.pro_unit.update_time is '修改时间(自动填充)';

alter table public.pro_unit
    owner to postgres;

create table public.pro_shop
(
    id                 bigserial
        primary key,
    country_id         bigint       default 0                     not null,
    create_time        bigint       default 0                     not null,
    currency_id        bigint       default 0                     not null,
    describe           varchar(80)  default ''::character varying not null,
    environment        integer      default 0                     not null,
    is_default         boolean      default false                 not null,
    language_id        bigint       default 0                     not null,
    logo_url           varchar(255) default ''::character varying not null,
    is_member_operate  boolean      default false                 not null,
    name               varchar(20)  default ''::character varying not null,
    is_open_mro        boolean      default false                 not null,
    property           integer      default 0                     not null,
    is_self            boolean      default false                 not null,
    state              integer      default 0                     not null,
    type               integer      default 0                     not null,
    url                varchar(255) default ''::character varying not null,
    update_time        bigint,
    is_deleted         bigint       default 0                     not null,
    version            bigint,
    member_id          bigint,
    member_role_id     bigint,
    member_name        varchar(50),
    self_shop_model_id bigint,
    adorn_id           bigint,
    shop_model_id      bigint,
    enabled            boolean      default false                 not null,
    member_operate     integer      default 0                     not null,
    open_mro           integer      default 0                     not null,
    self               integer      default 0                     not null,
    help_info_enable   boolean      default false                 not null
);

comment on column public.pro_shop.update_time is '修改时间(自动填充)';

comment on column public.pro_shop.is_deleted is '是否删除(逻辑删除标志:1代表已删除)';

comment on column public.pro_shop.version is '版本号(乐观锁)';

comment on column public.pro_shop.member_id is '会员ID';

comment on column public.pro_shop.member_role_id is '会员ID';

comment on column public.pro_shop.member_name is '会员名称';

comment on column public.pro_shop.self_shop_model_id is '商城模型id';

comment on column public.pro_shop.adorn_id is '模板ID';

comment on column public.pro_shop.enabled is '启用状态：true启用 false禁用';

comment on column public.pro_shop.help_info_enable is '帮助信息的开关';

alter table public.pro_shop
    owner to postgres;

create table public.pro_shop_help_info
(
    id           bigserial
        primary key,
    parent_id    bigint       default 0                     not null,
    shop_id      bigint       default 0                     not null,
    sort         bigint       default 0                     not null,
    name         varchar(32)  default ''::character varying not null,
    skip_type    integer      default 0                     not null,
    skip_url     varchar(200) default ''::character varying not null,
    help_title   varchar(80)  default ''::character varying not null,
    help_content text         default ''::character varying not null,
    level        integer      default 0                     not null,
    is_deleted   integer      default 0                     not null,
    version      integer      default 0                     not null,
    create_time  bigint       default (date_part('epoch'::text, CURRENT_TIMESTAMP) *
                                       ((1000)::bigint)::double precision),
    update_time  bigint       default (date_part('epoch'::text, CURRENT_TIMESTAMP) * ((1000)::bigint)::double precision)
);

comment on column public.pro_shop_help_info.id is '主键';

comment on column public.pro_shop_help_info.parent_id is '父ID，关联到ShopHelpInfoDO';

comment on column public.pro_shop_help_info.shop_id is '商城ID，关联到ShopDO';

comment on column public.pro_shop_help_info.sort is '排序';

comment on column public.pro_shop_help_info.name is '标题 - 列表标题，树节点名称';

comment on column public.pro_shop_help_info.skip_type is '跳转类型：1-站内，2-站外';

comment on column public.pro_shop_help_info.skip_url is '跳转路径';

comment on column public.pro_shop_help_info.help_title is '帮助信息页标题';

comment on column public.pro_shop_help_info.help_content is '帮助信息页内容';

comment on column public.pro_shop_help_info.level is '层级：默认为一级';

comment on column public.pro_shop_help_info.is_deleted is '是否删除（逻辑删除标志：1代表已删除）';

comment on column public.pro_shop_help_info.version is '版本号（乐观锁）';

comment on column public.pro_shop_help_info.create_time is '创建时间（自动填充）';

comment on column public.pro_shop_help_info.update_time is '修改时间（自动填充）';

alter table public.pro_shop_help_info
    owner to postgres;

DROP TABLE IF EXISTS pro_unit_name;
CREATE TABLE pro_unit_name(
    id BIGSERIAL NOT NULL,
    unit_id BIGINT NOT NULL,
    language VARCHAR(20) NOT NULL,
    name VARCHAR(255) NOT NULL DEFAULT  true,
    PRIMARY KEY (id)
);

COMMENT ON TABLE pro_unit_name IS '单位名称';
COMMENT ON COLUMN pro_unit_name.id IS '主键id';
COMMENT ON COLUMN pro_unit_name.unit_id IS '关联的单位Id';
COMMENT ON COLUMN pro_unit_name.language IS '语言';
COMMENT ON COLUMN pro_unit_name.name IS '名称翻译';