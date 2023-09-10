--total revenue
select sum(total_price) as Total_Revenue
from pizza_sales

--average order value
select sum(total_price) / count(distinct order_id) as Avg_Order_Value
from pizza_sales

--total pizza sold
select sum(quantity) as Total_Pizza_Sold
from pizza_sales

--total orders
select count(distinct order_id) as Total_Orders
from pizza_sales

--average pizza per order
select cast(cast(sum(quantity) as decimal(10,2)) / cast(count(distinct order_id) as decimal(10,2)) as decimal(10,2)) as Avg_Pizzas_Per_Order
from pizza_sales

--daily record for total orders
select datename(dw, order_date) as Order_Day, count(distinct order_id) as Daily_Total_Orders
from pizza_sales
group by datename(dw, order_date)

--monthly record for total orders
select datename(month, order_date) as Month_Name, count(distinct order_id) as Monthly_Total_Orders
from pizza_sales
group by datename(month, order_date)
order by Monthly_Total_Orders desc

--percentage of sales by pizza category
select pizza_category, sum(total_price) as Total_Sales, sum(total_price) * 100 / (select sum(total_price) from pizza_sales) as PCT
from pizza_sales
group by pizza_category

--percentage of sales of January by pizza category
select pizza_category, sum(total_price) as Total_Sales, sum(total_price) * 100 / (select sum(total_price) from pizza_sales where month(order_date) = 1) as PCJT
from pizza_sales
where month(order_date) = 1
group by pizza_category

--percentage of sales by pizza size
select pizza_size, cast(sum(total_price) as decimal(10,2)) as Total_Sales, cast(sum(total_price) * 100 / (select sum(total_price) from pizza_sales) as decimal(10,2)) as PCT
from pizza_sales
group by pizza_size
order by PCT desc

--percentage of sales by pizza size first quarter
select pizza_size, cast(sum(total_price) as decimal(10,2)) as Total_Sales, cast(sum(total_price) * 100 / (select sum(total_price) from pizza_sales where datepart(quarter,order_date)=1) as decimal(10,2)) as PCT
from pizza_sales
where datepart(quarter,order_date)=1
group by pizza_size
order by PCT desc

--top 5 by best seller revenue,quantity,order
select top 5 pizza_name, sum(total_price) as Total_Revenue
from pizza_sales
group by pizza_name
order by Total_Revenue desc

select top 5 pizza_name, sum(quantity) as Total_Quantity
from pizza_sales
group by pizza_name
order by Total_Quantity desc

select top 5 pizza_name, count(distinct order_id) as Total_Orders
from pizza_sales
group by pizza_name
order by Total_Orders desc

--bottom 5 by best seller revenue,quantity,order
select top 5 pizza_name, sum(total_price) as Total_Revenue
from pizza_sales
group by pizza_name
order by Total_Revenue

select top 5 pizza_name, sum(quantity) as Total_Quantity
from pizza_sales
group by pizza_name
order by Total_Quantity

select top 5 pizza_name, count(distinct order_id) as Total_Orders
from pizza_sales
group by pizza_name
order by Total_Orders


