import { Request, Response } from 'express';
import CreateOrderService from '../services/CreateOrderService';

class OrderController {
  public async create(request: Request, response: Response): Promise<Response> {
    const { userId, addressId, paymentMethodId, products } = request.body;
    const createOrder = new CreateOrderService();

    try {
      await createOrder.execute({ userId, addressId, paymentMethodId, products });
      return response.status(201).json({ message: 'Order created successfully!' });
    } catch (error) {
      if (error instanceof Error) {
        return response.status(400).json({ message: error.message });
      }
      return response.status(500).json({ message: 'Internal Server Error' });
} } }

export default OrderController;