import { Router } from 'express';
import OrderController from '../controllers/OrderController';

const orderRoutes = Router();
const orderController = new OrderController();

orderRoutes.post('/', orderController.create);

export default orderRoutes;