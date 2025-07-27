import { Request, Response } from 'express';
import ListProductsService from '../services/ListProductsService';

class ProductController {
  public async list(request: Request, response: Response): Promise<Response> {
    const listProductsService = new ListProductsService();

    try {
      const products = await listProductsService.execute();
      return response.status(200).json(products);
    } catch (error) {

        if (error instanceof Error) {
        return response.status(400).json({ message: error.message });
      }
      return response.status(500).json({ message: 'Internal Server Error' });
} } }

export default ProductController;