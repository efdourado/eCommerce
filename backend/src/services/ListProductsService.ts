import db from '../database';

export interface IProduct {
  id: number;
  name: string;
  price: string;
  qty_in_stock: number;
  category_name: string;
  supplier_name: string;
}

class ListProductsService {
  public async execute(): Promise<IProduct[]> {
    const queryResult = await db.query(
      `SELECT
          p.id,
          p.name,
          p.price,
          p.qty_in_stock,
          c.name as category_name,
          s.name as supplier_name
       FROM product p
       JOIN category c ON p.category_id = c.id
       JOIN supplier s ON p.supplier_id = s.id
       ORDER BY p.name ASC`
    );

    return queryResult.rows;
} }

export default ListProductsService;