/*1. Crie uma tabela analítica de todos os itens que foram vendidos, mostrando somente pedidos interestaduais. 
Queremos saber quantos dias os fornecedores demoram para postar o produto, se o produto chegou ou não no prazo. */

SELECT 
	olist_orders_dataset.order_id
	,olist_sellers_dataset.seller_state
	,olist_customers_dataset.customer_state
	,round(julianday(olist_orders_dataset.order_delivered_carrier_date)
	-julianday(olist_orders_dataset.order_approved_at), 0) AS "Dias_Postagem"
	,CASE WHEN ROUND(JULIANDAY(olist_orders_dataset.order_delivered_customer_date) 
	-JULIANDAY(olist_orders_dataset.order_estimated_delivery_date),0)>0 
THEN "No Prazo" ELSE "Fora Prazo" END "STATUS_PRAZO" 
FROM olist_orders_dataset 
JOIN olist_order_items_dataset ON olist_orders_dataset.order_id = olist_order_items_dataset.order_id
JOIN olist_sellers_dataset ON olist_order_items_dataset.seller_id = olist_sellers_dataset.seller_id
JOIN olist_customers_dataset ON olist_orders_dataset.customer_id = olist_customers_dataset.customer_id
WHERE olist_customers_dataset.customer_state != olist_sellers_dataset.seller_state
GROUP BY olist_orders_dataset.order_id 




/* 2.Retorne todos os pagamentos do cliente, com suas datas de aprovação, 
valor da compra e o valor total que o cliente já gastou em todas as suas compras, 
mostrando somente os clientes onde o valor da compra é diferente do valor total já gasto. */
SELECT 
	olist_customers_dataset.customer_id as cliente
	,olist_order_payments_dataset.order_id as compras
	,olist_orders_dataset.order_approved_at as data_aprovacao
	,olist_order_payments_dataset.payment_value as valor_compra
	,sum(olist_order_payments_dataset.payment_value) as Total_Comprado FROM olist_customers_dataset 
JOIN olist_orders_dataset ON olist_customers_dataset.customer_id = olist_orders_dataset.customer_id
JOIN olist_order_payments_dataset ON olist_orders_dataset.order_id = olist_order_payments_dataset.order_id
GROUP BY olist_customers_dataset.customer_id 
HAVING olist_order_payments_dataset.payment_value != sum(olist_order_payments_dataset.payment_value);




/* 3.Retorne as categorias válidas, suas somas totais dos valores de vendas, um ranqueamento de maior 
valor para menor valor junto com o somatório acumulado dos valores pela mesma regra do ranqueamento. */
SELECT	categoria
	,soma_vendas
	,ranking
	,sum(soma_vendas)
	OVER (PARTITION BY ''	ORDER BY soma_vendas DESC) AS soma_acumulada
FROM 
	(SELECT product_category_name AS categoria, sum(price) AS soma_vendas,rank()
	OVER(PARTITION BY '' order by sum(price)DESC) AS ranking
FROM olist_order_items_dataset AS items 
JOIN olist_products_dataset AS products ON products.product_id = items.product_id
WHERE products.product_category_name IS NOT NULL
GROUP BY product_category_name
ORDER BY sum(price) desc) AS Dados

