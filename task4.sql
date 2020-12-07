-- Создание таблиц для работы пакета

-- Таблица поваров
CREATE TABLE COOK
(
    ID NUMBER NOT NULL,
    NAME VARCHAR2(100) NOT NULL,
    START_DATE DATE NOT NULL,
    END_DATE DATE,
    
    CONSTRAINT COOK_PK PRIMARY KEY (ID)
);
COMMENT ON COLUMN COOK.ID IS 'ID повара';
COMMENT ON COLUMN COOK.NAME IS 'Имя повара';
COMMENT ON COLUMN COOK.START_DATE IS 'Дата найма';
COMMENT ON COLUMN COOK.END_DATE IS 'Дата увольнения';


-- Таблица блюд
CREATE TABLE DISH 
(
    ID NUMBER NOT NULL,
    NAME VARCHAR2(50) NOT NULL,
    
    CONSTRAINT DISH_PK PRIMARY KEY (ID)
);
COMMENT ON COLUMN DISH.ID IS 'ID блюда';
COMMENT ON COLUMN DISH.NAME IS 'Название блюда';


-- Таблица M2M для поваров и блюд
CREATE TABLE COOK_DISH
(
    COOK_ID NUMBER NOT NULL,
    DISH_ID NUMBER NOT NULL,
    START_DATE DATE NOT NULL,
    
    CONSTRAINT COOK_DISH_UK1 UNIQUE (COOK_ID, DISH_ID),
    CONSTRAINT COOK_DISH_FK1 FOREIGN KEY (COOK_ID)
        REFERENCES COOK (ID),
    CONSTRAINT COOK_DISH_FK2 FOREIGN KEY (DISH_ID)
        REFERENCES DISH (ID)
);
COMMENT ON COLUMN COOK_DISH.COOK_ID IS 'ID повара';
COMMENT ON COLUMN COOK_DISH.DISH_ID IS 'ID блюда';
COMMENT ON COLUMN COOK_DISH.START_DATE IS 'Дата освоения навыка поваром';






-- Header

create or replace PACKAGE KITCHEN_API AS 

-- создание повара
procedure p_cook_create(pr_name in varchar2);

-- создание блюда
procedure p_dish_create(pr_name in varchar2);

-- увольнение повара
procedure p_cook_dismiss(pr_id in integer, pr_date in date default sysdate);

-- добавление навыка повару
procedure p_cook_add_dish(pr_cook_id in integer, pr_dish_id in integer);

-- получить поваров, которые умеют готовить заданное блюда на указанную дату (уволенные уже не умеют)
function f_get_cooks_by_dish(pr_dish_id in integer, pr_date in date default sysdate) return varchar2;

-- получить блюда, которые умеет готовить заданный повар на указанную дату (уволенные уже ничего не умеют)
function f_get_dishes_by_cook(pr_cook_name in varchar2, pr_date in date default sysdate) return varchar2;


END KITCHEN_API;
/




-- Body

CREATE OR REPLACE
PACKAGE BODY KITCHEN_API AS

procedure p_cook_create(pr_name in varchar2) AS
    l_new_id integer;
BEGIN
    select nvl(max(id), 0) + 1 into l_new_id from cook;
    insert into cook (id, name, start_date) values (l_new_id, pr_name, sysdate);
    commit;
END p_cook_create;


procedure p_dish_create(pr_name in varchar2) AS
    l_new_id integer;
BEGIN
    select nvl(max(id), 0) + 1 into l_new_id from dish;
    insert into dish (id, name) values (l_new_id, pr_name);
    commit;
END p_dish_create;


procedure p_cook_dismiss(pr_id in integer, pr_date in date default sysdate) AS
BEGIN
    update cook set end_date = pr_date where id = pr_id;
    commit;
END p_cook_dismiss;


procedure p_cook_add_dish(pr_cook_id in integer, pr_dish_id in integer) AS
BEGIN
    insert into cook_dish (cook_id, dish_id, start_date) values (pr_cook_id, pr_dish_id, sysdate);
    commit;
END p_cook_add_dish;


function f_get_cooks_by_dish(pr_dish_id in integer, pr_date in date default sysdate) return varchar2 AS
    l_result varchar2(4000);
BEGIN
    select listagg(cook.name, ',') within group (order by name)
    into l_result
    from cook
    inner join cook_dish cd
        on cd.cook_id = cook.id
    where cook.start_date <= pr_date
        and ((cook.end_date >= pr_date) or (cook.end_date is null))
        and cd.start_date <= pr_date
        and cd.dish_id = pr_dish_id;
return l_result;
END f_get_cooks_by_dish;


function f_get_dishes_by_cook(pr_cook_name in varchar2, pr_date in date default sysdate) return varchar2 AS
    l_result varchar2(4000);
BEGIN
    select listagg(dish.name, ',') within group (order by dish.name)
    into l_result
    from dish
    inner join cook_dish cd
        on cd.dish_id = dish.id
    inner join cook
        on cook.id = cd.cook_id
    where cook.start_date <= pr_date
        and ((cook.end_date >= pr_date) or (cook.end_date is null))
        and cd.start_date <= pr_date
        and cook.name = pr_cook_name;
return l_result;    
END f_get_dishes_by_cook;

END KITCHEN_API;