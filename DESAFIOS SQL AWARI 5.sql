 -- DESAFIO 5
 /*Crie os índices apropriadaos para as atbelas do nosso modelo de dados com o intuito de melhorar a performance.*/
   
  CREATE INDEX INDICE_PRODUTOS ON olist_products_dataset(product_category_name)
  CREATE INDEX INDICE_UF_CUSTOMER ON olist_customers_dataset(customer_state)
  CREATE INDEX INDICE_VENDAS ON olist_order_items_dataset(price)
  CREATE INDEX INDICE_STATUS_VENDAS ON olist_orders_dataset(order_status)
  CREATE INDEX INDICE_VENDEDOR_ID ON olist_sellers_dataset(seller_id)
  CREATE INDEX INDICE_REVIEW ON olist_order_reviews_dataset (review_score)