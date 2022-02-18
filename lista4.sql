/* 1. Crie uma view (SELLER_STATS) para mostrar por fornecedor, a quantidade de itens enviados, 
o tempo médio de postagem após a aprovação da compra, a quantidade total de pedidos de cada Fornecedor, 
note que trabalharemos na mesma query com 2 granularidades diferentes. */
CREATE view SELLER_STATS as 
SELECT 	tbsellers.seller_id as fornecedores
	,count(tborders.order_delivered_carrier_date) as itens_enviados
	,round(avg(julianday(tborders.order_delivered_carrier_date)	- julianday(tborders.order_approved_at)),0) as dias_ate_postagem
	, count(DISTINCT tborders.order_id) as total_pedidos
	, count(distinct case when order_delivered_carrier_date is not null then order_id END) as pedidos_enviados
/* over (PARTITION by tbsellers.seller_id) as total_pedidos */
from	
	olist_sellers_dataset as tbsellers
LEFT JOIN olist_order_items_dataset as tborderitems USING (seller_id)	
LEFT JOIN olist_orders_dataset as tborders USING (order_id)	
GROUP by seller_id
order by total_pedidos DESC




/* 2. Queremos dar um cupom de 10% do valor da última compra do cliente. 
Porém os clientes elegíveis a este cupom devem ter feito uma compra anterior a última 
(a partir da data de aprovação do pedido) que tenha sido maior ou igual o valor da última compra.
Crie uma querie que retorne os valores dos cupons para cada um dos clientes elegíveis. */
SELECT	
	CLIENTES
	,sum(case when ranking=1 then ultimo_pedido else 0 end) as ultimo
	,sum(case when ranking=2 then ultimo_pedido else 0 end) as penultimo
	,(sum(case when ranking=1 then ultimo_pedido else 0 end) * 0.10) AS DESCONTO
FROM
	(SELECT	
		CLIENTES.customer_unique_id AS CLIENTES,ORDENS.order_id
		,payment_value AS ULTIMO_PEDIDO
		,row_number() OVER(PARTITION BY CLIENTES.customer_unique_id ORDER by order_purchase_timestamp desc) as ranking
	FROM  olist_orders_dataset ORDENS
	JOIN olist_order_payments_dataset PAGAMENTOS USING(order_id)
	JOIN olist_customers_dataset CLIENTES USING(customer_id)
	WHERE order_approved_at is not NULL
	)
group by clientes
having  ranking  >= ULTIMO_PEDIDO
ORDER BY CLIENTES