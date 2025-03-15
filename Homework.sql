create database SportShop;
use SportShop;


--creating database part
create table Productss (
	Id int primary key identity(1,1),
	ProductName nvarchar(100) not null,
	Quantity int not null,
	Price money not null
);

create table Employees (
	Id int primary key identity(1,1),
	EmployeeName nvarchar(100) not null,
	Position nvarchar(50) not null,
	HireDate date not null,
	DismissalDate date
);
create table ArchivedEmployees (
	Id int primary key identity(1,1),
	EmployeeName nvarchar(100) not null,
	Position nvarchar(50) not null,
	HireDate date not null,
	DismissalDate date
);

create table Sellers(
	Id int primary key identity(1,1),
	SellerName nvarchar(100) not null
);

--insert(chatgpt) part
-- Insert data into Products table
INSERT INTO Productss (ProductName, Quantity, Price) VALUES
('Laptop', 10, 1200.00),
('Smartphone', 25, 800.00),
('Headphones', 50, 150.00),
('Monitor', 15, 300.00),
('Keyboard', 30, 50.00);

-- Insert data into Employees table
INSERT INTO Employees (EmployeeName, Position, HireDate, DismissalDate) VALUES
('John Smith', 'Manager', '2020-06-15', NULL),
('Alice Johnson', 'Sales Representative', '2021-03-20', NULL),
('Robert Brown', 'Technician', '2019-11-05', NULL),
('Emily Davis', 'Accountant', '2018-09-12', '2024-01-10'),
('Michael Wilson', 'HR Specialist', '2022-07-25', NULL);

-- Insert data into ArchivedEmployees table
INSERT INTO ArchivedEmployees (EmployeeName, Position, HireDate, DismissalDate) VALUES
('Emily Davis', 'Accountant', '2018-09-12', '2024-01-10'),
('David White', 'Technician', '2017-05-30', '2023-12-15'),
('Sophia Green', 'Sales Representative', '2016-08-10', '2022-06-20');

-- Insert data into Sellers table
INSERT INTO Sellers (SellerName) VALUES
('BestBuy'),
('Amazon'),
('Walmart'),
('Newegg'),
('Target');

---triggers
go
create trigger UpdateProductQuantity
on Productss instead of insert
as
begin
	if Exists(Select 1 from Productss p join inserted i on p.ProductName = i.ProductName and p.Price = i.Price)
	begin
		update p
		set p.Quantity = p.Quantity + i.Quantity
		from Productss p
		join inserted i on p.ProductName = i.ProductName and p.Price = i.Price;
	end
	else
	begin
		insert into Productss(ProductName,Quantity,Price)
		select ProductName,Quantity,Price from inserted;
	end
end;
go
create trigger ArchiveEmployee
on Employees after update
as 
begin
	if update(DismissalDate)
	begin
		insert into ArchivedEmployees(Id, EmployeeName, Position, HireDate, DismissalDate)
		select Id,EmployeeName, Position, HireDate, DismissalDate from inserted where DismissalDate is not null;
	end
end
go
create trigger CheckSellerCount on Sellers
instead of insert
as 
begin
	declare @SellerCount int;
	select @SellerCount = Count(*) from Sellers;

	if @SellerCount >= 6
	begin
		Raiserror('The number of sellers cannot be six or bigger',0,1);
		rollback;
	end
	else
	begin
		insert into Sellers (SellerName) select SellerName from inserted;
	end
end
go

--testing
INSERT INTO Productss (ProductName, Quantity, Price) VALUES
('Monitor', 10, 1200.00)

update Employees
set DismissalDate = getdate() where Id = 1;

insert into Sellers (SellerName) values
('Testing Seller');


drop table Sellers;
drop table Employees;
drop table Products;
drop table ArchivedEmployees;

use master;
drop database Sportshop;
