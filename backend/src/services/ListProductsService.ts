import db from '../database';

export interface IProduct {
  product_id: number;
  product_name: string;
  price: string;
  qty_in_stock: number;
  category_name: string;
  supplier_name: string;
}

class ListProductsService {
  public async execute(): Promise<IProduct[]> {
    const queryResult = await db.query(
      'SELECT product_id, product_name, price, qty_in_stock, category_name, supplier_name FROM vw_detailed_products ORDER BY product_name ASC'
    );

    return queryResult.rows;
} }

export default ListProductsService;