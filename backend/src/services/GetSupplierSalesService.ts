import db from '../database';

class GetSupplierSalesService {
  public async execute(supplierId: number): Promise<{ total_sales: string }> {
    const queryResult = await db.query(
      'SELECT get_supplier_total_sales($1::INT) as total_sales',
      [supplierId]
    );

    return queryResult.rows[0];
} }

export default GetSupplierSalesService;