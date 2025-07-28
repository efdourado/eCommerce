import { Router } from 'express';
import SupplierController from '../controllers/SupplierController';

const supplierRoutes = Router();
const supplierController = new SupplierController();

supplierRoutes.get('/:id/sales', supplierController.getSales);

export default supplierRoutes;