create table RESTAURANTS_CHAIN(
	ChainPK integer primary key,
	DirectorFK integer,
	Name varchar(40),
	Type varchar(20) check(type in ('фаст-фуд', 'середні руки',
	'елітний')),
	Address varchar(200),
	Phone varchar(15) unique,
	Costs number(10,3) check(Costs > 0),
	Income number(10,3) check(Income > 0),
	constraint director_constr foreign key(DirectorFK) references STAFF(StaffPK)
);

create table RESTAURANT(
	RestPK integer primary key,
	WarehouseFK integer,
	ChainFK integer,
	Capacity integer check(Capacity > 72),
	CheckMid number(10,3) check(Checkmid > 0),
	LastInspection data,
	Address varchar(200),
	Phone varchar(15) unique,
	Costs number(10,3) check(Costs > 0),
	Income number(10,3) check(Income > 0),
	constraint chain_constr foreign key(ChainFK) references RESTAURANTS_CHAIN(ChainPK)
	constraint warehouse_constr foreign key(WarehouseFK) references WAREHOUSE(WarehousePK)
);

create table STAFF(
	StaffPK integer primary key,
	RestFK integer,
	Name varchar(100),
	Post varchar(50) check(Post in ('власник','керівник','кухар',
	'помічник кухаря','офіціант','прибиральник')),
	Phone varchar(15) unique,
	Hiredate date,
	Salary number(6,2) check(Salary > 0),
	Commission number(6,2) check(Commission > 0),
	constraint restaurant_constr foreign key(RestFK) references RESTAURANT(RestPK)
);

create table VENDOR(
	VendorPK integer primary key,
	ChainFK integer,
	ProductFK integer,
	Name varchar(100),
	Address varchar(200),
	Phone varchar(15) unique,
	DeliveryType varchar(14) check(DeliveryType in ('доставка постачальником',
	'самовивіз')),
	DeliveryPrice number(6,2) check(DeliveryPrice > 0),
	constraint chain_constr foreign key(ChainFK) references RESTAURANTS_CHAIN(ChainPK)
	constraint product_constr foreign key(ProductFK) references PRODUCT(ProductPK)
); 

create table WAREHOUSE(
	WarehousePK integer primary key,
	ProductFK integer,
	Address varchar(200),
	constraint product_constr foreign key(ProductFK) references PRODUCT(ProductPK)
);

create table PRODUCT(
	ProductPK integer primary key,
	VendorFK integer,
	WarehouseFK integer,
	Name varchar(100),
	Type varchar(14) check(Type in('їжа','кухонні прилади','меблі',
	'техніка')),
	Weight number(10,3) check(Weight > 0),
	Price number(10,3) check(Price > 0),
	constraint warehouse_constr foreign key(WarehouseFK) references WAREHOUSE(WarehousePK),
	constraint vendor_constr foreign key(VendorFK) references VENDOR(VendorPK)
);

create table MENU(
	ChainFK integer,
	ChiefFK integer,
	Name varchar(100),
	Weight number(10,3) check(Weight > 0),
	Price number(10,2) check(Price > 0),
	constraint chain_constr foreign key(ChainFK) references RESTAURANTS_CHAIN(ChainPK),
	constraint chief_constr foreign key(ChiefFK) references STAFF(StaffPK)
);

Скільки ресторанів входить до мережі
select count(r.Address) 
from RESTAURANTS_CHAIN rc, RESTAURANT r
where rc.ChainPK = r.ChainFK;

Номер телефону власника мережі ресторанів
select s.Phone as 
from RESTAURANTS_CHAIN rc, STAFF s
where rc.DirectorPK = s.StaffFK and lower(s.Post) = 'власник'

ПІБ шеф-повара, який склав меню для мережі ресторанів
select s.name 
from RESTAURANTS_CHAIN rc, STAFF s, MENU m
where rc.ChainPK = m.ChainFK and s.StaffPK = m.ChiefFK and lower(s.Post) = 'шеф-повар'; 

Найдорожча техніка в ресторані за адресом: просп. Перемоги, 45, Київ, 03057 та входить до мережі ресторанів «Євразія»
select max(p.Price) 
from RESTAURANTS_CHAIN rc, RESTAURANT r, WAREHOUSE w, PRODUCT p
where rc.ChainPK = r.ChainFK and w.WarehousePK = r.WarehouseFK and p.ProductPK = w.ProductFK and 
	  r.Address = 'просп. Перемоги, 45, Київ, 03057' and p.Type = 'техніка' and rc.name = 'Євразія';
	  
Скільки грошей іде на доставку та купівлю продуктів мережі ресторанів «Мафія»
select sum(p.Price + v.DeliveryPrice) 
from RESTAURANTS_CHAIN rc, PRODUCT p, VENDOR v
where rc.ChainPK = v.ChainFK and p.ProductPK = v.ProductFK and 
	  p.Type = 'продукт' and rc.Name = 'Мафія';
	  
Адреса та номер телефону ресторану, який не приносить прибутків та входить до мережі ресторанів «Мафія»
select r.Phone, r.Address
from RESTAURANTS_CHAIN rc, RESTAURANT r
where rc.ChainPK = r.ChainFK and rc.Name = 'Мафія' and r.Income = 0;

Яка кількість товарів на складі ресторану, який належить до мережі «Va Bene». Ресторан розміщений за адресою вул. Б. Хмельницкого, 19-21, Київ, 02000
select count(p.name)
from RESTAURANTS_CHAIN rc, RESTAURANT r, WAREHOUSE w, PRODUCT p
where rc.ChainPK = r.ChainFK and w.WarehousePK = r.WarehouseFK and p.ProductPK = w.ProductFK and 
	  r.Address = 'вул. Б. Хмельницкого, 19-21, Київ, 02000' and rc.name = 'Va Bene';
	  
Відношення прибутку ресторану до затрат на працівників мережі ресторанів типу середні руки
select (r.income/(s.salary+s.commission))*100
from RESTAURANTS_CHAIN rc, RESTAURANT r, STAFF s
where rc.ChainPK = r.ChainFK and r.RestPK = s.RestFK and rc.type = 'середні руки';