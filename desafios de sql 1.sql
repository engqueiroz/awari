/* 
Tarefa: Desafios de SQL 1
1.selecione os dados da tabela de pagamentos onde só apareçam os tipos de pagamento “VOUCHER” e “BOLETO” */
Select * 
FROM olist_order_payments_dataset
WHERE payment_type LIKE'BOLETO' OR payment_type LIKE'VOUCHER';


/* 2.retorne os campos da tabela de produtos e calcule o volume de cada produto em um novo campo */
SELECT product_id,
       product_category_name,
       product_name_lenght,
       product_description_lenght,
       (product_height_cm * product_width_cm *product_length_cm) AS product_volume
FROM olist_products_dataset;


/* 3.retorne somente os reviews que não tem comentários */
select *
FROM olist_order_reviews_dataset
WHERE review_comment_message ISNULL;


/* 4.retorne pedidos que foram feitos somente no ano de 2017 */
SELECT *
FROM olist_orders_dataset
WHERE order_purchase_timestamp BETWEEN '2017-01-01 00:00:00' AND '2017-12-31 23:59:59';


/* 5.encontre os clientes do estado de SP e que não morem na cidade de São Paulo */
SELECT *
FROM olist_customers_dataset
WHERE customer_state LIKE 'SP' AND customer_city <> 'sao paulo';