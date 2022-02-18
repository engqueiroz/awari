/* 1. Retorne a quantidade de itens vendidos em cada categoria por estado em que o cliente se encontra, 
mostrando somente categorias que tenham vendido uma quantidade de items acima de 1000.*/

SELECT olist_customers_dataset.customer_state,olist_products_dataset.product_category_name, 
count(olist_order_payments_dataset.payment_type) as "Itens Vendidos"
FROM olist_customers_dataset
inner JOIN olist_orders_dataset on olist_orders_dataset.customer_id = olist_customers_dataset.customer_id
inner JOIN olist_order_payments_dataset on olist_orders_dataset.order_id = olist_order_payments_dataset.order_id
inner join olist_order_items_dataset on olist_order_payments_dataset.order_id = olist_order_items_dataset.order_id
inner join  olist_products_dataset on olist_products_dataset.product_id = olist_order_items_dataset.product_id
GROUP by olist_customers_dataset.customer_state, olist_products_dataset.product_category_name
HAVING "Itens Vendidos" > 1000;




/* 2. Mostre os 5 clientes (customer_id) que gastaram mais dinheiro em compras, 
qual foi o valor total de todas as compras deles, quantidade de compras, 
e valor médio gasto por compras. 
Ordene os mesmos por ordem decrescente pela média do valor de compra.*/


SELECT olist_customers_dataset.customer_id,count(olist_order_payments_dataset.payment_type) as "Total itens comprados",
sum(olist_order_payments_dataset.payment_value) as "Total Compras",
avg(olist_order_payments_dataset.payment_value) as "Valor medio de compras"
FROM olist_customers_dataset
inner JOIN olist_orders_dataset on olist_orders_dataset.customer_id = olist_customers_dataset.customer_id
inner JOIN olist_order_payments_dataset on olist_orders_dataset.order_id = olist_order_payments_dataset.order_id
GROUP by olist_customers_dataset.customer_id
ORDER by sum(olist_order_payments_dataset.payment_value) DESC,
avg(olist_order_payments_dataset.payment_value) DESC
LIMIT 5;




/* 3. mostre o valor vendido total de cada vendedor (seller_id) em cada uma das categorias de produtos, 
somente retornando os vendedores que nesse somatório e agrupamento venderam mais de $1000. 
Desejamos ver a categoria do produto e os vendedores. 
Para cada uma dessas categorias, mostre seus valores de venda de forma decrescente. */

SELECT olist_sellers_dataset.seller_id,olist_products_dataset.product_category_name, 
sum(olist_order_payments_dataset.payment_value) as "total"
FROM olist_sellers_dataset
INNER JOIN olist_order_items_dataset on olist_sellers_dataset.seller_id = olist_order_items_dataset.seller_id
INNER join olist_order_payments_dataset	on olist_order_items_dataset.order_id = olist_order_payments_dataset.order_id
INNER JOIN olist_products_dataset on olist_products_dataset.product_id = olist_order_items_dataset.product_id
GROUP by olist_sellers_dataset.seller_id, olist_products_dataset.product_category_name
HAVING sum(olist_order_payments_dataset.payment_value) > 1000
ORDER by sum(olist_order_payments_dataset.payment_value) DESC;