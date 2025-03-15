create database SportShop;
use SportShop;


--creating database part

create table Productsss (
	ProductId int primary key identity(1,1),
	Name nvarchar(100) not null,
	Type nvarchar(50) not null,
	Quantity int not null,
	Cost money not null,
	Manufacturer nvarchar(100),
	SellingPrice money not null
);

create table Employees (
	EmployeeId int primary key identity(1,1),
	Name nvarchar(100) not null,
	Position nvarchar(50) not null,
	HireDate date not null,
	Gender nvarchar(10) not null,
	Salary money not null
);

create table Clientss(
	ClientId int primary key identity(1,1),
	Name nvarchar(100) not null,
	Email nvarchar(100),
	Phone nvarchar(15),
	Gender nvarchar(10) not null,
	OrderHistory nvarchar(max),
	DiscountPercentage int,
	IsSubcribed bit not null
);

create table Sales (
	Id int primary key identity(1,1),
	ProductId int foreign key references Productsss(ProductId),
	SellingPrice money not null,
	Quantity int not null,
	SaleDate date not null,
	EmployeeId int foreign key references Employees(EmployeeId),
	ClientId int foreign key references Clientss(ClientId),
	
);

create table SalesHistory (
	Id int primary key identity(1,1),
	ProductId int,
	SellingPrice money not null,
	Quantity int not null,
	SaleDate date not null,
	EmployeeId int,
	ClientId int
);

create table ArchivedProducts (
	ProductId int primary key ,
	Name nvarchar(100) not null,
	Type nvarchar(50) not null,
	Quantity int not null,
	Cost money not null,
	Manufacturer nvarchar(100),
	SellingPrice money not null
);

create table LastProducts (
	ProductId int primary key ,
	Name nvarchar(100) not null,
	Type nvarchar(50) not null,
	Quantity int not null,
	Cost money not null,
	Manufacturer nvarchar(100),
	SellingPrice money not null
);
--insert(chatgpt) part
INSERT INTO Productsss (Name, Type, Quantity, Cost, Manufacturer, SellingPrice) VALUES
('Laptop', 'Electronics', 10, 1000.00, 'Dell', 1200.00),
('Smartphone', 'Electronics', 20, 600.00, 'Samsung', 800.00),
('Headphones', 'Accessories', 50, 30.00, 'Sony', 50.00),
('Monitor', 'Electronics', 15, 200.00, 'LG', 300.00),
('Keyboard', 'Accessories', 30, 20.00, 'Logitech', 50.00);

-- Insert data into Employees table
INSERT INTO Employees (Name, Position, HireDate, Gender, Salary) VALUES
('John Smith', 'Manager', '2020-06-15', 'Male', 5000.00),
('Alice Johnson', 'Sales Representative', '2021-03-20', 'Female', 3500.00),
('Robert Brown', 'Technician', '2019-11-05', 'Male', 4000.00),
('Emily Davis', 'Accountant', '2018-09-12', 'Female', 4500.00),
('Michael Wilson', 'HR Specialist', '2022-07-25', 'Male', 3800.00);

-- Insert data into Clientss table
INSERT INTO Clientss (Name, Email, Phone, Gender, OrderHistory, DiscountPercentage, IsSubcribed) VALUES
('David White', 'david.white@email.com', '123-456-7890', 'Male', 'Laptop, Smartphone', 10, 1),
('Sophia Green', 'sophia.green@email.com', '987-654-3210', 'Female', 'Headphones, Monitor', 15, 1),
('Mark Adams', 'mark.adams@email.com', '555-123-4567', 'Male', 'Keyboard', 5, 0),
('Emma Roberts', 'emma.roberts@email.com', '444-987-6543', 'Female', 'Smartphone, Headphones', 20, 1),
('James Miller', 'james.miller@email.com', '333-222-1111', 'Male', 'Monitor', 10, 0);

-- Insert data into Sales table
INSERT INTO Sales (ProductId, SellingPrice, Quantity, SaleDate, EmployeeId, ClientId) VALUES
(1, 1200.00, 1, '2024-03-10', 1, 1),
(2, 800.00, 2, '2024-03-11', 2, 2),
(3, 50.00, 3, '2024-03-12', 3, 3),
(4, 300.00, 1, '2024-03-13', 4, 4),
(5, 50.00, 2, '2024-03-14', 5, 5);

-- Insert data into SalesHistory table
INSERT INTO SalesHistory (ProductId, SellingPrice, Quantity, SaleDate, EmployeeId, ClientId) VALUES
(1, 1200.00, 1, '2024-02-01', 1, 1),
(2, 800.00, 1, '2024-02-05', 2, 2),
(3, 50.00, 2, '2024-02-10', 3, 3),
(4, 300.00, 1, '2024-02-15', 4, 4),
(5, 50.00, 1, '2024-02-20', 5, 5);

-- Insert data into ArchivedProducts table
INSERT INTO ArchivedProducts (ProductId, Name, Type, Quantity, Cost, Manufacturer, SellingPrice) VALUES
(6, 'Tablet', 'Electronics', 0, 300.00, 'Apple', 500.00),
(7, 'Smartwatch', 'Accessories', 0, 150.00, 'Garmin', 250.00);

-- Insert data into LastProducts table
INSERT INTO LastProducts (ProductId, Name, Type, Quantity, Cost, Manufacturer, SellingPrice) VALUES
(8, 'Gaming Mouse', 'Accessories', 10, 40.00, 'Razer', 70.00),
(9, 'Wireless Charger', 'Accessories', 15, 20.00, 'Anker', 35.00);


--triggers
--1
go
create trigger insertToHistorySales
on Sales
after insert
as
begin
	insert into SalesHistory (ProductId,SellingPrice,Quantity,SaleDate,EmployeeId,ClientId)
	select ProductId,SellingPrice,Quantity,SaleDate,EmployeeId,ClientId from inserted;
end;
--2
go
create trigger moveToArchiveProducts
on Productsss
after update
as
begin
	insert into ArchivedProducts(ProductId,Name,Type,Quantity, Cost, Manufacturer,SellingPrice)
	select p.ProductId,p.Name,p.Type,p.Quantity,p.Cost,p.Manufacturer,p.SellingPrice from Productsss p
	join inserted i on p.ProductId = i.ProductId
	where i.Quantity = 0;

	delete from Productsss
	where ProductId in (select ProductId from inserted where Quantity = 0);
end;
--3
go
create trigger AvoidDuplicateUser
on Clientss
instead of insert as
begin
	if exists (select 1 from Clientss c join inserted i on c.Name = i.Name and c.Email = i.Email)
	begin
		Raiserror('A client with this Name and Email already registered',16,1);
		rollback;
	end
	else
	begin
	insert into Clientss(Name,Email,Phone,Gender,OrderHistory,DiscountPercentage,IsSubcribed)
	select Name,Email,Phone,Gender,OrderHistory,DiscountPercentage,IsSubcribed from inserted;
	end
end;
--4
go
create trigger PreventDeletion on Clientss
instead of delete
as
begin
	Raiserror('Deleting Clients is forbidden',0,1);
end;
--5
go
create trigger PreventDeletionEmployees
on Employees
instead of delete
as
begin
	if exists( select 1 from deleted where HireDate < '2015-01-01')
	begin
		raiserror('Employees hired before 2015 cannot be deleted',0,1);
		rollback;
	end
	else
	begin
		delete from Employees where EmployeeId in (Select EmployeeId from deleted);
	end
end;
--6
go
create trigger ChangeClientDiscount
on Sales
after insert as
begin
	update Clientss
	set DiscountPercentage = 15
	where ClientId in (Select s.ClientId from Sales s join inserted i on s.ClientId = i.ClientId
	group by s.ClientId having sum(s.SellingPrice * s.Quantity) > 50000);
end;
--8
go
create trigger checkLastUnit
on Productsss
after update
as
begin
	insert into LastProducts (ProductId,Name,Type,Quantity,Cost,Manufacturer,SellingPrice)
	select p.ProductId, p.Name,p.Type,p.Quantity,p.Cost,p.Manufacturer,p.SellingPrice from Productsss p
	join inserted i on p.ProductId = i.ProductId where i.Quantity = 1;
end;
go

use master;
drop database Sportshop;
