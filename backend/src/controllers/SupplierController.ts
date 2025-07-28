import { Request, Response } from 'express';
import GetSupplierSalesService from '../services/GetSupplierSalesService';

class SupplierController {
  public async getSales(request: Request, response: Response): Promise<Response> {
    const { id } = request.params;
    const getSupplierSales = new GetSupplierSalesService();

    try {
      const sales = await getSupplierSales.execute(Number(id));
      return response.status(200).json(sales);
    } catch (error) {
      if (error instanceof Error) {
        return response.status(400).json({ message: error.message });
      }
      return response.status(500).json({ message: 'Internal Server Error' });
} } }

export default SupplierController;